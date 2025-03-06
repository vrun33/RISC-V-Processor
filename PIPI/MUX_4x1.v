`include "MUX_2x1.v"

module mux_4x1(in3, in2, in1, in0, s, y);

    
    input wire [63:0] in0;
    input wire [63:0] in1;
    input wire [63:0] in2;
    input wire [63:0] in3;
    input wire [1:0] s;
    output wire [63:0] y;

    wire [63:0] mux1, mux2;

    mux_2x1 Mux1(in0, in1, s[0], mux1);
    mux_2x1 Mux2(in2, in3, s[0], mux2);
    mux_2x1 Mux3(mux1, mux2, s[1], y);

endmodule