// Include all the modules for the ALU
`include "fa1.v"
`include "fa64.v"
`include "sub64.v"
`include "and64.v"
`include "or64.v"
`include "xor64.v"
`include "slt64.v"
`include "sltu64.v"
`include "sra64.v"
`include "srl64.v"
`include "sll64.v"

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