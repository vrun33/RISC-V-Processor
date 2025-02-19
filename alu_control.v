module alu_control (
    input wire [1:0] alu_op,      // {alu_op_1, alu_op_0}
    input wire [3:0] instr_bits,   // {i_30, i_14, i_13, i_12}
    output wire [3:0] op          // {op_3, op_2, op_1, op_0}
);
    wire alu_op_1 = alu_op[1];
    wire alu_op_0 = alu_op[0];
    wire i_30 = instr_bits[3];
    wire i_14 = instr_bits[1];
    wire i_13 = instr_bits[2];
    wire i_12 = instr_bits[0];
    
    // Gate level implementation of the ALU control logic
    wire temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, temp9;

    not (temp1, alu_op_0);
    not (temp2, alu_op_1);
    not (temp3, i_12);
    not (temp4, i_13);
    not (temp5, i_14);
    not (temp6, i_30);

    and (temp7, alu_op_1, i_30, temp3, temp4, temp5);  // alu_op_1 & i_30 & ~i_12 & ~i_13 & ~i_14
    and (temp8, temp1, temp2);                         // ~alu_op_0 & ~alu_op_1
    and (temp9, alu_op_1, temp3, temp4, temp5);        // alu_op_1 & ~i_12 & ~i_13 & ~i_14

    assign op[3] = 1'b0;
    or (op[2], alu_op_0, temp7);
    or (op[1], temp8, alu_op_0, temp9);
    and (op[0], alu_op_1, temp6, temp3, i_13, i_14);
endmodule