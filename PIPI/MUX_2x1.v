// 2x1 MUX

module mux_2x1(in1, in2, s0, y);

    input wire [63:0]in1;
    input wire [63:0]in2;
    input wire s0;
    output wire [63:0]y;

    assign y = s0 ? in2 : in1;

endmodule