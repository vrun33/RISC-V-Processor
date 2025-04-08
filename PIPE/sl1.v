// Module for shifting left by 1

module sl1(
    input [63:0] in,   
    output [63:0] out
);
    assign out = {in[62:0], 1'b0};
endmodule