`timescale 1ns / 1ps
`include "alu_control.v"

module alu_control_tb;
    reg alu_op_1, alu_op_0, i_30, i_14, i_13, i_12;
    wire op_3, op_2, op_1, op_0;

    integer pass_count = 0;

    alu_control uut (
        .alu_op_1(alu_op_1), .alu_op_0(alu_op_0), .i_30(i_30), .i_14(i_14), .i_13(i_13), .i_12(i_12),
        .op_3(op_3), .op_2(op_2), .op_1(op_1), .op_0(op_0)
    );

    initial begin
        $dumpfile("alu_control_tb.vcd");
        $dumpvars(0, alu_control_tb);

        // Test cases based on provided table
        {alu_op_1, alu_op_0, i_30, i_14, i_13, i_12} = 6'b00xxxx; #10;
        check_output(4'b0010, op_3, op_2, op_1, op_0);

        {alu_op_1, alu_op_0, i_30, i_14, i_13, i_12} = 6'b01xxxx; #10;
        check_output(4'b0110, op_3, op_2, op_1, op_0);

        {alu_op_1, alu_op_0, i_30, i_14, i_13, i_12} = 6'b100000; #10;
        check_output(4'b0010, op_3, op_2, op_1, op_0);

        {alu_op_1, alu_op_0, i_30, i_14, i_13, i_12} = 6'b101000; #10;
        check_output(4'b0110, op_3, op_2, op_1, op_0);

        {alu_op_1, alu_op_0, i_30, i_14, i_13, i_12} = 6'b100111; #10;
        check_output(4'b0000, op_3, op_2, op_1, op_0);

        {alu_op_1, alu_op_0, i_30, i_14, i_13, i_12} = 6'b100110; #10;
        check_output(4'b0001, op_3, op_2, op_1, op_0);

        $display("Total Passed Cases: %0d out of 6", pass_count);
        $finish;
    end

    task check_output;
        input [3:0] expected;
        input op_3, op_2, op_1, op_0;
        begin
            $display("Expected: %b, Obtained: %b%b%b%b", expected, op_3, op_2, op_1, op_0);
            if ({op_3, op_2, op_1, op_0} === expected) pass_count = pass_count + 1;
            else $display("Test Failed");
        end
    endtask
endmodule
