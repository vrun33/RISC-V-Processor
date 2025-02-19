// Set Less than Unsigned for ALU
// `include "sub64.v"
module sltu64(
    input [63:0] rs1,    // A
    input [63:0] rs2,    // B
    output [63:0] rd,     // output
    output z_flag          // zero flag
);
    wire [63:0] diff;
    wire c_out, v_flag, n_flag, z_flag;
    wire less_than;
    
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
    
    // (UNSIGNED) rs1 < rs2 if there is no carry out
    // notC 
    xor x1(less_than, c_out, 1'b1);
    
    assign rd = {63'b0, less_than};
    assign z_flag = (rd == 64'b0);
    
endmodule