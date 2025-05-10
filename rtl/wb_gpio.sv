module wb_gpio #(
        parameter WB_ADDRESS_WIDTH = 32,
        parameter logic[63:0] WB_BASE_ADDRESS = 64'h0000_0000_4001_0000,
        parameter WB_REGISTER_ADDRESS_WIDTH = 16,
        parameter WB_DATA_WIDTH = 32,
        parameter WB_DATA_GRANULARITY = 8,
        parameter logic[31:0] IP_VERSION = 32'h0001_0000,
        parameter logic[31:0] IP_DEVICE_ID = 32'h0001_0001,
        parameter logic[127:0] DEFAULT_GPIO_DIRECTION_FULL = 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF,
        parameter logic[127:0] DEFAULT_GPIO_OUTPUT_FULL = 128'h0000_0000_0000_0000_0000_0000_0000_0000,
        localparam WB_SEL_WIDTH = WB_DATA_WIDTH / WB_DATA_GRANULARITY

    )
    (
        input wire logic i_wb_clk,
        input wire logic i_wb_rst,
        input wire logic i_wb_cyc,
        input wire logic i_wb_stb,
        input wire logic i_wb_we,
        input wire logic [WB_ADDRESS_WIDTH-1:0] i_wb_addr,
        input wire logic [WB_DATA_WIDTH-1:0] i_wb_dat,
        input wire logic [WB_SEL_WIDTH-1:0] i_wb_sel,
        output logic[WB_DATA_WIDTH-1:0] o_wb_dat,
        output logic o_wb_stall,
        output logic o_wb_ack,

        inout wire logic[WB_DATA_WIDTH-1:0] io_gpio,
        output logic o_interrupt
    );

    localparam GLOBEL_IRQ_ENABLE_BIT = 31;
    logic[WB_REGISTER_ADDRESS_WIDTH-1:0] ip_address;
    logic[WB_DATA_WIDTH-1:0] ip_rdata;
    logic[WB_DATA_WIDTH-1:0] ip_wdata;
    logic ip_read_enable;
    logic ip_write_enable;
    logic ip_ack;
    logic ip_stall;
    logic[WB_DATA_WIDTH-1:0] control;
    logic[WB_DATA_WIDTH-1:0] bit_change;
    logic[WB_DATA_WIDTH-1:0] bit_change_mask;
    logic[WB_DATA_WIDTH-1:0] irq;

    wb_subordinate_interface #(
                                 .WB_ADDRESS_WIDTH(WB_ADDRESS_WIDTH),
                                 .WB_BASE_ADDRESS(WB_BASE_ADDRESS),
                                 .WB_REGISTER_ADDRESS_WIDTH(WB_REGISTER_ADDRESS_WIDTH),
                                 .WB_DATA_WIDTH(WB_DATA_WIDTH),
                                 .WB_DATA_GRANULARITY(WB_DATA_GRANULARITY),
                                 .IP_VERSION(IP_VERSION),
                                 .IP_DEVICE_ID(IP_DEVICE_ID)
                             ) wb_interface (
                                 .i_wb_clk(i_wb_clk),
                                 .i_wb_rst(i_wb_rst),
                                 .i_wb_addr(i_wb_addr),
                                 .i_wb_dat(i_wb_dat),
                                 .o_wb_dat(o_wb_dat),
                                 .i_wb_cyc(i_wb_cyc),
                                 .i_wb_stb(i_wb_stb),
                                 .i_wb_we(i_wb_we),
                                 .i_wb_sel(i_wb_sel),
                                 .o_wb_stall(o_wb_stall),
                                 .o_wb_ack(o_wb_ack),
                                 .o_ip_address(ip_address),
                                 .i_ip_rdata(ip_rdata),
                                 .o_ip_wdata(ip_wdata),
                                 .o_ip_read_en(ip_read_enable),
                                 .o_ip_write_en(ip_write_enable),
                                 .i_ip_ack(ip_ack),
                                 .i_ip_stall(ip_stall),
                                 .o_ip_control(control),
                                 .i_ip_status(0),
                                 .i_ip_irq(bit_change_mask),
                                 .o_ip_irq(irq)
                             );

    gpio #(
             .WB_REGISTER_ADDRESS_WIDTH(WB_REGISTER_ADDRESS_WIDTH),
             .WB_DATA_WIDTH(WB_DATA_WIDTH),
             .DEFAULT_GPIO_DIRECTION_FULL(DEFAULT_GPIO_DIRECTION_FULL),
             .DEFAULT_GPIO_OUTPUT_FULL(DEFAULT_GPIO_OUTPUT_FULL)
         ) gpio_inst (
             .i_clk(i_wb_clk),
             .i_reset(i_wb_rst),
             .i_ip_address(ip_address),
             .o_ip_rdata(ip_rdata),
             .i_ip_read_en(ip_read_enable),
             .i_ip_wdata(ip_wdata),
             .i_ip_write_en(ip_write_enable),
             .o_ip_ack(ip_ack),
             .o_ip_stall(ip_stall),
             .io_gpio(io_gpio),
             .o_pin_change(bit_change)
         );

    assign bit_change_mask = (control[GLOBEL_IRQ_ENABLE_BIT] == 1'b1) ? bit_change : 0;
    assign o_interrupt = |irq;

endmodule
