// SLT for ALU
module slt64(
    input [63:0] rs1,    // A
    input [63:0] rs2,    // B
    output [63:0] rd,
    output z_flag     
);
    wire [63:0] diff;
    wire c_out, v_flag, n_flag, z_flag;
    wire less_than;      // N XOR V
    
    // rs1 - rs2
    sub64 subtractor(
        .a(rs1),
        .b(rs2),
        .diff(diff),
        .c_out(c_out),
        .v_flag(v_flag),
        .n_flag(n_flag),
        .z_flag(z_flag)
    );
    
    xor x1(less_than, n_flag, v_flag);
    assign rd = {63'b0, less_than};
    assign z_flag = (rd == 64'b0);

endmodule