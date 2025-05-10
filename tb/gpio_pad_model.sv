module gpio_pad_model #(
        parameter int WIDTH = 32
    ) (
        inout wire[WIDTH-1:0] pad,
        input wire[WIDTH-1:0] dir, // 1-model drive pad, 0-pad left floating
        input wire[WIDTH-1:0] dout, // data to drive out
        output wire[WIDTH-1:0] din // value seen at the pad
    );
    genvar i;
    generate
        for(i = 0; i < WIDTH; i++) begin : gpio_model
            assign pad[i] = dir[i] ? dout[i] : 1'bz;
//            assign pad[i] = dir[i] ? 1'bz : dout[i];
            assign din[i] = pad[i];
        end
    endgenerate
endmodule
