// wb_master_bfm.sv
// Simulation-only Wishbone B4 master for IP core verification
// Author: Michael B

module wb_master_bfm #(
        parameter WB_ADDRESS_WIDTH = 32,
        parameter WB_DATA_WIDTH = 32,
        parameter WB_DATA_GRANULARITY = 8
    ) (
        input wire logic clk,
        input wire logic rst,

        output logic[WB_ADDRESS_WIDTH-1:0] o_wb_addr,
        output logic[WB_DATA_WIDTH-1:0] o_wb_dat,
        input wire logic[WB_DATA_WIDTH-1:0] i_wb_dat,

        output logic o_wb_cyc,
        output logic o_wb_stb,
        output logic o_wb_we,
        output logic[(WB_DATA_WIDTH/WB_DATA_GRANULARITY)-1:0] o_wb_sel,

        input wire logic i_wb_ack,
        input wire logic i_wb_stall,
        input wire logic i_wb_err
    );

    initial
    begin
        o_wb_addr = '0;
        o_wb_dat = '0;
        o_wb_we = '0;
        o_wb_sel = '1;
        o_wb_stb = '0;
        o_wb_cyc = '0;
    end

    task automatic single_write(
            input logic [WB_ADDRESS_WIDTH-1:0] addr,
            input logic [WB_DATA_WIDTH-1:0] data,
            input logic [(WB_DATA_WIDTH/WB_DATA_GRANULARITY)-1:0] sel = '1
        );
        begin
            @(posedge clk);
            o_wb_addr = addr;
            o_wb_dat = data;
            o_wb_we = 1;
            o_wb_sel = sel;
            o_wb_cyc = 1;
            o_wb_stb = 1;

            @(posedge clk);
            o_wb_stb = 0;
            wait (i_wb_ack || i_wb_err);

            @(posedge clk);
            o_wb_cyc = 0;
        end
    endtask

    task automatic single_read(
            input logic [WB_ADDRESS_WIDTH-1:0] addr,
            output logic [WB_DATA_WIDTH-1:0] data,
            input logic [(WB_DATA_WIDTH/WB_DATA_GRANULARITY)-1:0] sel = '1
        );
        begin
            @(posedge clk);
            o_wb_addr = addr;
            o_wb_we = 0;
            o_wb_sel = sel;
            o_wb_cyc = 1;
            o_wb_stb = 1;

            @(posedge clk);
            o_wb_stb = 0;
            wait (i_wb_ack || i_wb_err);

            @(posedge clk);
            data = i_wb_dat;
            o_wb_cyc = 0;
        end
    endtask

    always @(negedge clk)
    begin
        if (o_wb_stb && o_wb_cyc)
            $display("%t [WB MASTER] Access: %s Addr: 0x%08x Data: 0x%08x Sel: 0x%0x",
                     $time,
                     o_wb_we ? "WRITE" : "READ",
                     o_wb_addr, o_wb_we ? o_wb_dat : i_wb_dat, o_wb_sel);
    end


endmodule;
