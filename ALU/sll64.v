// Shift Left Logical 64-bit for ALU
module sll64(
    input [63:0] rs1,   
    input [63:0] rs2,    
    output [63:0] result,
    output z_flag
);
    wire [5:0] shift_amt;  
    assign shift_amt = rs2[5:0]; 
    
    wire [63:0] stage1, stage2, stage4, stage8, stage16, stage32;  

    assign stage1 = shift_amt[0] ? {rs1[62:0], 1'b0} : rs1; // shift left by 0 or 1

    assign stage2 = shift_amt[1] ? {stage1[61:0], 2'b0} : stage1; // shift left by 0 or 2

    assign stage4 = shift_amt[2] ? {stage2[59:0], 4'b0} : stage2; // shift left by 0 or 4
    
    assign stage8 = shift_amt[3] ? {stage4[55:0], 8'b0} : stage4; // shift left by 0 or 8

    assign stage16 = shift_amt[4] ? {stage8[47:0], 16'b0} : stage8; // shift left by 0 or 16
    
    assign stage32 = shift_amt[5] ? {stage16[31:0], 32'b0} : stage16; // shift left by 0 or 32
    
    assign result = stage32;  
    assign z_flag = (result == 64'b0);

endmodule