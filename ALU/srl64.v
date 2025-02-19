// Barrel Shifter: Logical Right Shift
module srl64(
    input [63:0] rs1,   
    input [63:0] rs2,    
    output [63:0] result,
    output z_flag
);
    wire [5:0] shift_amt; 
    assign shift_amt = rs2[5:0]; 
    
    wire [63:0] stage1, stage2, stage4, stage8, stage16, stage32; 

    assign stage1 = shift_amt[0] ? {1'b0, rs1[63:1]} : rs1; // shift right by 0 or 1

    assign stage2 = shift_amt[1] ? {2'b0, stage1[63:2]} : stage1; // shift right by 0 or 2

    assign stage4 = shift_amt[2] ? {4'b0, stage2[63:4]} : stage2; // shift right by 0 or 4
    
    assign stage8 = shift_amt[3] ? {8'b0, stage4[63:8]} : stage4; // shift right by 0 or 8

    assign stage16 = shift_amt[4] ? {16'b0, stage8[63:16]} : stage8; // shift right by 0 or 16
    
    assign stage32 = shift_amt[5] ? {32'b0, stage16[63:32]} : stage16; // shift right by 0 or 32
    
    assign result = stage32; 
    assign z_flag = (result == 64'b0); 

endmodule