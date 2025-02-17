// op_3 = 0
// op_2 = alu_op_0 + (alu_op_1 * i_30 * ~i_12 * ~i_13 * ~i_14)
// op_1 = (~alu_op_0 * ~alu_op_1) + (alu_op_0) + (alu_op_1 * ~i_12 * ~i_13 * ~i_14)
// op_0 = alu_op_1 * ~i_30 * ~i_12 * i_13 * i_14

module alu_control (
    input wire alu_op_1,
    input wire alu_op_0,
    input wire i_30,
    input wire i_14,
    input wire i_13,
    input wire i_12,
    output wire op_3,
    output wire op_2,
    output wire op_1,
    output wire op_0
);
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

    assign op_3 = 1'b0;
    or (op_2, alu_op_0, temp7);
    or (op_1, temp8, alu_op_0, temp9);
    and (op_0, alu_op_1, temp6, temp3, i_13, i_14);
endmodule