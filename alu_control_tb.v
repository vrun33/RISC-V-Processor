`timescale 1ns / 1ps
`include "alu_control.v"

module alu_control_tb;
    reg [1:0] alu_op;
    reg [3:0] instr_bits;
    wire [3:0] op;

    integer pass_count = 0;

    // Map the individual bits to make test case writing clearer
    wire alu_op_1 = alu_op[1];
    wire alu_op_0 = alu_op[0];
    wire i_30 = instr_bits[3];
    wire i_14 = instr_bits[1];
    wire i_13 = instr_bits[2];
    wire i_12 = instr_bits[0];
    wire op_3 = op[3];
    wire op_2 = op[2];
    wire op_1 = op[1];
    wire op_0 = op[0];

    alu_control uut (
        .alu_op(alu_op),
        .instr_bits(instr_bits),
        .op(op)
    );

    initial begin
        $dumpfile("alu_control_tb.vcd");
        $dumpvars(0, alu_control_tb);

        // Test cases based on provided table
        alu_op = 2'b00; instr_bits = 4'bxxxx; #10;
        check_output(4'b0010, op);

        alu_op = 2'b01; instr_bits = 4'bxxxx; #10;
        check_output(4'b0110, op);

        alu_op = 2'b10; instr_bits = 4'b0000; #10;
        check_output(4'b0010, op);

        alu_op = 2'b10; instr_bits = 4'b1000; #10;
        check_output(4'b0110, op);

        alu_op = 2'b10; instr_bits = 4'b0111; #10;
        check_output(4'b0000, op);

        alu_op = 2'b10; instr_bits = 4'b0110; #10;
        check_output(4'b0001, op);

        $display("Total Passed Cases: %0d out of 6", pass_count);
        $finish;
    end

    task check_output;
        input [3:0] expected;
        input [3:0] actual;
        begin
            $display("Expected: %b, Obtained: %b", expected, actual);
            if (actual === expected) pass_count = pass_count + 1;
            else $display("Test Failed");
        end
    endtask
endmodule