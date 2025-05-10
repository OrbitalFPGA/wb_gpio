module tb_wb_gpio();

    //    // Parameters
    //    localparam int ADDR_WIDTH = 32;
    //    localparam int DATA_WIDTH = 32;
    localparam logic[31:0] ADDRESS = 32'h4001_0000;
    localparam logic[31:0] VERSION = 32'h0001_0000;
    localparam logic[31:0] DEVICE_ID = 32'h000A_0000;


    logic clk;
    logic rst;

    initial
        $timeformat(-9, 0, " ns", 10);

    initial
    begin
        clk = 0;
        rst = 1;
        #10 rst = 0;
    end

    always #5 clk = ~clk;

    tri[31:0] gpio;
    logic interrupt;

    logic [31:0] wb_addr, wb_m_data, wb_s_data;
    logic wb_we, wb_cyc, wb_stb, wb_ack, wb_stall;
    logic [3:0] wb_sel;

    wb_gpio #(
                .WB_BASE_ADDRESS(ADDRESS),
                .IP_VERSION(VERSION),
                .IP_DEVICE_ID(DEVICE_ID)
            )dut(
                .i_wb_clk(clk),
                .i_wb_rst(rst),
                .i_wb_cyc(wb_cyc),   // Connect master's output to slave's input
                .i_wb_stb(wb_stb),   // Connect master's output to slave's input
                .i_wb_we(wb_we),     // Connect master's output to slave's input
                .i_wb_addr(wb_addr),  // Connect master's output to slave's input
                .i_wb_dat(wb_m_data),   // Connect master's output to slave's input
                .i_wb_sel(wb_sel),   // Connect master's output to slave's input
                .o_wb_dat(wb_s_data),   // Connect slave's output to master's input
                .o_wb_stall(wb_stall), // Connect slave's output to master's input
                .o_wb_ack(wb_ack),   // Connect slave's output to master's input

                .io_gpio(gpio),
                .o_interrupt(interrupt)

            );

    wb_master_bfm master(
                      .clk(clk),
                      .rst(rst),
                      .o_wb_addr(wb_addr),
                      .o_wb_dat(wb_m_data),
                      .i_wb_dat(wb_s_data),
                      .o_wb_cyc(wb_cyc),
                      .o_wb_stb(wb_stb),
                      .o_wb_we(wb_we),
                      .o_wb_sel(wb_sel),
                      .i_wb_ack(wb_ack),
                      .i_wb_stall(wb_stall),
                      .i_wb_err()
                  );

    logic[31:0] gpio_din;
    logic[31:0] gpio_dout;
    logic[31:0] gpio_dir;
    logic[31:0] rd_data;


    initial
    begin
        gpio_dout = '0;
        gpio_dir = '1;
        rd_data = '0;

    end

    gpio_pad_model pad_model(gpio, gpio_dir, gpio_dout, gpio_din);

    task automatic change_direction(input[31:0] direction);
        gpio_dir = '0;
        master.single_write(32'h4001_0020, direction);
        gpio_dir = direction;

    endtask

    function check_result(input[31:0] expected, input [31:0] received);
        if(expected != received)
        begin
            $display("%t: Expected 0x%08x, got 0x%08x", $time, expected, received);
        end
    endfunction

    initial
    begin
        #100;
        $display("Testing if standard registers can be read");
        master.single_read(ADDRESS, rd_data);
        check_result(VERSION, rd_data);

        master.single_read(ADDRESS | 32'h4, rd_data);
        check_result(DEVICE_ID, rd_data);

        master.single_read(ADDRESS | 32'h8, rd_data);
        check_result('0, rd_data);

        master.single_read(ADDRESS | 32'hC, rd_data);
        check_result('0, rd_data);

        master.single_read(ADDRESS | 32'h10, rd_data);
        check_result('0, rd_data);

        master.single_read(ADDRESS | 32'h14, rd_data);
        check_result('0, rd_data);

        $display("Testing if ip registers can be read");
        master.single_read(ADDRESS | 32'h20, rd_data);
        check_result('1, rd_data);

        master.single_read(ADDRESS | 32'h24, rd_data);
        check_result('0, rd_data);

        $display("Check if direction can be toggeled");
        change_direction(32'h00000000);
        master.single_read(ADDRESS | 32'h20, rd_data);
        check_result('0, rd_data);

        change_direction(32'hA5A5A5A5);
        master.single_read(ADDRESS | 32'h20, rd_data);
        check_result(32'hA5A5A5A5, rd_data);

        $display("Check ablity to set pint output when configured as an output");
        change_direction(32'h00000000);
        master.single_write(ADDRESS | 32'h24, 32'hAAAAAAAA);
        check_result(32'hAAAAAAAA, gpio);
        #50; // Need to provide a pause to let output pins to go through syncronizor
        master.single_read(ADDRESS | 32'h24, rd_data);
        check_result(32'hAAAAAAAA, rd_data);

        master.single_write(ADDRESS | 32'h24, 32'h55555555);
        check_result(32'h55555555, gpio);
        #50; // Need to provide a pause to let output pins to go through syncronizor
        master.single_read(ADDRESS | 32'h24, rd_data);
        check_result(32'h55555555, rd_data);

        master.single_write(ADDRESS | 32'h24, 32'hFFFFFFFF);
        check_result(32'hFFFFFFFF, gpio);
        #50; // Need to provide a pause to let output pins to go through syncronizor
        master.single_read(ADDRESS | 32'h24, rd_data);
        check_result(32'hFFFFFFFF, rd_data);

        master.single_write(ADDRESS | 32'h24, 32'h00000000);
        check_result(32'h00000000, gpio);
        #50; // Need to provide a pause to let output pins to go through syncronizor
        master.single_read(ADDRESS | 32'h24, rd_data);
        check_result(32'h00000000, rd_data);

        $display("Check if will not drive pins driven as input");
        gpio_dout = 32'h00000000;
        change_direction(32'hFFFFFFFF);
        master.single_write(ADDRESS | 32'h24, 32'hFFFFFFFF);
        check_result(32'h00000000, gpio_din);

        $display("Check if return correct value when reading GPIO in input mode");
        gpio_dout = 32'hAAAAAAAA;
        #50; // Wait for input to go through syncronizor
        master.single_read(ADDRESS | 32'h24, rd_data);
        check_result(32'hAAAAAAAA, rd_data);

        gpio_dout = 32'h12345678;
        #50; // Wait for input to go through syncronizor
        master.single_read(ADDRESS | 32'h24, rd_data);
        check_result(32'h12345678, rd_data);

        $display("Check interrupts work correctly");
        gpio_dout = 32'h00000000;
        if(interrupt != 1'b0)
            $display("%t: Expected interrupt to be low", $time); // No interrupts should have been generated since globel interrupt enable is low

        master.single_read(ADDRESS | 32'h10, rd_data);
        check_result(32'h00000000, rd_data);

        master.single_write(ADDRESS | 32'h8, 32'h80000000); // This enables globel interrupts. Pin level interrupt should still be disabled
        gpio_dout = 32'hFFFFFFFF;
        #50;
        master.single_read(ADDRESS | 32'h10, rd_data);
        check_result(32'h00000000, rd_data);
        if(interrupt != 1'b0)
            $display("%t: Expected interrupt to be low", $time);
        gpio_dout = 32'h00000000;
        #50;
        master.single_write(ADDRESS | 32'hC, 32'hFFFFFFFF); // This enables all pin level interrupts



        gpio_dout = 32'h00000001;
        #50; // Wait for input to go through syncronizor
        if(interrupt != 1'b1)
            $display("%t: Expected interrupt to be high", $time);
        master.single_read(ADDRESS | 32'h10, rd_data);
        check_result(32'h00000001, rd_data);
        gpio_dout = 32'h00000000;
        #50; // Wait for input to go through syncronizor
        master.single_write(ADDRESS | 32'h10, 32'hFFFFFFFF); // Clear interrupt
        if(interrupt != 1'b0)
            $display("%t: Expected interrupt to be low", $time);


        gpio_dout = 32'hAAAAAAAA;
        #50; // Wait for input to go through syncronizor
        if(interrupt != 1'b1)
            $display("%t: Expected interrupt to be high", $time);
        master.single_read(ADDRESS | 32'h10, rd_data);
        check_result(32'hAAAAAAAA, rd_data);
        gpio_dout = 32'h00000000;
        #50; // Wait for input to go through syncronizor
        master.single_write(ADDRESS | 32'h10, 32'hFFFFFFFF); // Clear interrupt
        if(interrupt != 1'b0)
            $display("%t: Expected interrupt to be low", $time);

        gpio_dout = 32'h55555555;
        #50; // Wait for input to go through syncronizor
        if(interrupt != 1'b1)
            $display("%t: Expected interrupt to be high", $time);
        master.single_read(ADDRESS | 32'h10, rd_data);
        check_result(32'h55555555, rd_data);
        gpio_dout = 32'h00000000;
        #50; // Wait for input to go through syncronizor
        master.single_write(ADDRESS | 32'h10, 32'hFFFFFFFF); // Clear interrupt
        if(interrupt != 1'b0)
            $display("%t: Expected interrupt to be low", $time);

        master.single_write(ADDRESS | 32'hC, 32'h0000FFFF); // Only enable lower 16 pins for intterrupts
        gpio_dout = 32'hFFFFFFFF;
        #50; // Wait for input to go through syncronizor
        if(interrupt != 1'b1)
            $display("%t: Expected interrupt to be high", $time);
        master.single_read(ADDRESS | 32'h10, rd_data);
        check_result(32'h0000FFFF, rd_data);




        $finish;
    end

endmodule
