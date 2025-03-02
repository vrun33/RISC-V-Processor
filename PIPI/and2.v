// 2-bit AND Gate
module and2 (
    input wire in1,
    input wire in2,
    output wire out
);
    and (out, in1, in2);
endmodule