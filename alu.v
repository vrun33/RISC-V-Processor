// Include all the modules for the ALU

// 1-bit Full Adder for ALU 
module fulladder1(
    output sum,
    output cout,
    input a,
    input b,
    input cin
);
    wire s1, c1, c2;

    xor x1(s1, a, b);
    xor x2(sum, s1, cin); // sum = a XOR b XOR cin
    and a1(c1, s1, cin);
    and a2(c2, a, b);
    or o1(cout, c1, c2); // cout = ab + cin (a XOR b)

endmodule

module fa64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] sum,
    output c_out,      
    output v_flag,     
    output n_flag,     
    output z_flag      
);
    wire [64:0] carry;
    wire a_sum_diff_sign;
    wire same_signs_temp;     
    wire same_signs;          

    assign carry[0] = 0;

    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin 
            fulladder1 fa1(
                .sum(sum[i]), 
                .cout(carry[i+1]), 
                .a(a[i]), 
                .b(b[i]), 
                .cin(carry[i])
            );
        end
    endgenerate

    assign c_out = carry[64];
    
    // A and Sum have opposite signs
    xor x1(a_sum_diff_sign, a[63], sum[63]);
    
    // A and B have same signs 
    xor x2(same_signs_temp, a[63], b[63]);
    xor x3(same_signs, same_signs_temp, 1'b1);  // XNOR 

    and a1(v_flag, a_sum_diff_sign, same_signs);
    
    assign n_flag = sum[63];
    assign z_flag = (sum == 64'b0);
endmodule

// Subtractor 64-bit for ALU using 1-bit Full Adder
// `include "fulladder1.v"
module sub64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] diff,
    output c_out,      
    output v_flag,     
    output n_flag,     
    output z_flag      
);
    wire [63:0] b_inv;
    wire [64:0] carry;
    wire a_diff_diff_sign;    
    wire opp_signs;           
    
    // Invert b for subtraction
    genvar j;
    generate
        for(j=0; j< 64;j=j+1) begin
            xor x1(b_inv[j], b[j], 1'b1);
        end
    endgenerate
    
    assign carry[0] = 1;
    
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin
            fulladder1 fa1(
                .sum(diff[i]),
                .cout(carry[i+1]),
                .a(a[i]),
                .b(b_inv[i]),
                .cin(carry[i])
            );
        end
    endgenerate

    assign c_out = carry[64];
    
    // A and Diff have opposite signs
    xor x2(a_diff_diff_sign, a[63], diff[63]);
    
    // A and B have opposite signs
    xor x3(opp_signs, a[63], b[63]);
    
    // AND of conditions 
    and a1(v_flag, a_diff_diff_sign, opp_signs);
    
    assign n_flag = diff[63];
    assign z_flag = (diff == 64'b0);
endmodule

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

// 64-bit AND Operation for ALU
module and64(
    input[63:0] a,
    input[63:0] b,
    output[63:0] out,
    output z_flag
);
    genvar i;

    generate
        for(i = 0; i<64; i=i+1) begin
            and a1(out[i], a[i], b[i]);
        end
    endgenerate

    assign z_flag = (out == 64'b0);
    
endmodule

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

// Barrel Shifter: Arithmetic Right Shift
module sra64(
    input [63:0] rs1,   
    input [63:0] rs2,    
    output [63:0] result,
    output z_flag
);
    wire [5:0] shift_amt;  
    assign shift_amt = rs2[5:0];  
    
    wire [63:0] stage1, stage2, stage4, stage8, stage16, stage32; 
    wire msb = rs1[63];

    assign stage1 = shift_amt[0] ? {msb, rs1[63:1]} : rs1; // shift right by 0 or 1

    assign stage2 = shift_amt[1] ? {{2{msb}}, stage1[63:2]} : stage1; // shift right by 0 or 2

    assign stage4 = shift_amt[2] ? {{4{msb}}, stage2[63:4]} : stage2; // shift right by 0 or 4
    
    assign stage8 = shift_amt[3] ? {{8{msb}}, stage4[63:8]} : stage4; // shift right by 0 or 8

    assign stage16 = shift_amt[4] ? {{16{msb}}, stage8[63:16]} : stage8; // shift right by 0 or 16
    
    assign stage32 = shift_amt[5] ? {{32{msb}}, stage16[63:32]} : stage16; // shift right by 0 or 32
    
    assign result = stage32;  
    assign z_flag = (result == 64'b0);

endmodule

// SLT for ALU
module slt64(
    input [63:0] rs1,    // A
    input [63:0] rs2,    // B
    output [63:0] rd,
    output wire z_flag     
);
    wire [63:0] diff;
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

// Set Less than Unsigned for ALU
// `include "sub64.v"
module sltu64(
    input [63:0] rs1,    // A
    input [63:0] rs2,    // B
    output [63:0] rd,    // output
    output wire z_flag   // zero flag
);
    wire [63:0] diff;
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

// 64-bit XOR Operation for ALU in RISC-V
module xor64(
    input[63:0] a,
    input[63:0] b,
    output[63:0] out,
    output z_flag
);
    genvar i;

    generate
        for(i = 0; i<64; i=i+1) begin
            xor a1(out[i], a[i], b[i]);
        end
    endgenerate

    assign z_flag = (out == 64'b0);

endmodule

// 64-bit OR Operation for ALU in RISC-V
module or64(
    input[63:0] a,
    input[63:0] b,
    output[63:0] out,
    output z_flag
);
    genvar i;

    generate
        for(i = 0; i<64; i=i+1) begin
            or a1(out[i], a[i], b[i]);
        end
    endgenerate

    assign z_flag = (out == 64'b0);
    
endmodule

// Wrapper ALU module
module alu(
    input signed [63:0] a,
    input signed [63:0] b,
    input [3:0] control,  
    output wire [63:0] result,
    output wire z_flag,      // Zero flag
    output wire n_flag,      // Negative flag
    output wire v_flag,      // Overflow flag
    output wire c_flag       // Carry flag
);

    wire [63:0] add_result, sub_result, and_result, or_result, xor_result;
    wire [63:0] slt_result, sltu_result, sra_result, srl_result, sll_result;
    
    // Flags from each operation
    wire add_cout, add_v, add_n, add_z;
    wire sub_cout, sub_v, sub_n, sub_z;
    wire and_z, or_z, xor_z;
    wire slt_z, sltu_z;
    wire sra_z, srl_z, sll_z;

    reg [63:0] reg_result;
    reg reg_z_flag, reg_n_flag, reg_v_flag, reg_c_flag;

    assign result = reg_result;
    assign z_flag = reg_z_flag;
    assign n_flag = reg_n_flag;
    assign v_flag = reg_v_flag;
    assign c_flag = reg_c_flag;

    // Operation control codes
    localparam  AND  = 4'b0000,
                OR  = 4'b0001,
                ADD  = 4'b0010,
                SRL   = 4'b0011,
                XOR  = 4'b0100,
                SLL  = 4'b0101,
                SUB = 4'b0110,
                SRA  = 4'b0111,
                SLT  = 4'b1000,
                SLTU  = 4'b1001;

    // Instantiate all operation modules
    fa64 adder(
        .a(a),
        .b(b),
        .sum(add_result),
        .c_out(add_cout),
        .v_flag(add_v),
        .n_flag(add_n),
        .z_flag(add_z)
    );

    sub64 subtractor(
        .a(a),
        .b(b),
        .diff(sub_result),
        .c_out(sub_cout),
        .v_flag(sub_v),
        .n_flag(sub_n),
        .z_flag(sub_z)
    );

    and64 and_op(
        .a(a),
        .b(b),
        .out(and_result),
        .z_flag(and_z)
    );

    or64 or_op(
        .a(a),
        .b(b),
        .out(or_result),
        .z_flag(or_z)
    );

    xor64 xor_op(
        .a(a),
        .b(b),
        .out(xor_result),
        .z_flag(xor_z)
    );

    slt64 slt_op(
        .rs1(a),
        .rs2(b),
        .rd(slt_result),
        .z_flag(slt_z)
    );

    sltu64 sltu_op(
        .rs1(a),
        .rs2(b),
        .rd(sltu_result),
        .z_flag(sltu_z)
    );

    sra64 sra_op(
        .rs1(a),
        .rs2(b),
        .result(sra_result),
        .z_flag(sra_z)
    );

    srl64 srl_op(
        .rs1(a),
        .rs2(b),
        .result(srl_result),
        .z_flag(srl_z)
    );

    sll64 sll_op(
        .rs1(a),
        .rs2(b),
        .result(sll_result),
        .z_flag(sll_z)
    );

    // Select result and set flags based on control signal
    always @(*) begin
        case(control)
            ADD: begin
                reg_result = add_result;
                reg_z_flag = add_z;
                reg_n_flag = add_n;
                reg_v_flag = add_v;
                reg_c_flag = add_cout;
            end
            SUB: begin
                reg_result = sub_result;
                reg_z_flag = sub_z;
                reg_n_flag = sub_n;
                reg_v_flag = sub_v;
                reg_c_flag = sub_cout;
            end
            AND: begin
                reg_result = and_result;
                reg_z_flag = and_z;
                reg_n_flag = and_result[63];
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
            OR: begin
                reg_result = or_result;
                reg_z_flag = or_z;
                reg_n_flag = or_result[63];
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
            XOR: begin
                reg_result = xor_result;
                reg_z_flag = xor_z;
                reg_n_flag = xor_result[63];
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
            SLT: begin
                reg_result = slt_result;
                reg_z_flag = slt_z;
                reg_n_flag = slt_result[63];
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
            SLTU: begin
                reg_result = sltu_result;
                reg_z_flag = sltu_z;
                reg_n_flag = sltu_result[63];
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
            SRA: begin
                reg_result = sra_result;
                reg_z_flag = sra_z;
                reg_n_flag = sra_result[63];
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
            SRL: begin
                reg_result = srl_result;
                reg_z_flag = srl_z;
                reg_n_flag = srl_result[63];
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
            SLL: begin
                reg_result = sll_result;
                reg_z_flag = sll_z;
                reg_n_flag = sll_result[63];
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
            default: begin
                reg_result = 64'h0;
                reg_z_flag = 1'b1;
                reg_n_flag = 1'b0;
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
        endcase
    end

endmodule