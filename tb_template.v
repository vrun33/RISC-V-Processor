`timescale 1ns/1ps

`include "whatever"

module ALU_TB;
    reg [63:0] In1, In2;
    reg [3:0] Control;
    wire [63:0] Out;
    wire Zero, Overflow, Carry;
    
    // Control codes
    localparam  AND_Oper  = 4'b0000,
                OR_Oper   = 4'b0001,
                ADD_Oper  = 4'b0010,
                SRL_Oper  = 4'b0011,
                XOR_Oper  = 4'b0100,
                SLL_Oper  = 4'b0101,
                SUB_Oper  = 4'b0110,
                SRA_Oper  = 4'b0111,
                SLT_Oper  = 4'b1000,
                SLTU_Oper = 4'b1001;
    
    // Test counter
    integer test_count = 0;
    integer pass_count = 0;
    
    ALU_Wrapper uut(
        .In1(In1),
        .In2(In2),
        .Control(Control),
        .Out(Out),
        .Zero(Zero),
        .Overflow(Overflow),
        .Carry(Carry)
    );

    task run_test;
        input [63:0] test_In1, test_In2, expected_Out;
        input [3:0] test_Control;
        input exp_Carry, exp_Overflow, exp_Zero;
        begin
            test_count = test_count + 1;
            In1 = test_In1;
            In2 = test_In2;
            Control = test_Control;
            #10;
            
            $display("\nTest Case %0d:", test_count);
            $display("Test: In1 = %h", In1);
            $display("      In2 = %h", In2);
            $display("      Control = %b (%s)", Control,
                    Control == AND_Oper  ? "AND" :
                    Control == OR_Oper   ? "OR"  :
                    Control == ADD_Oper  ? "ADD" :
                    Control == SRL_Oper  ? "SRL" :
                    Control == XOR_Oper  ? "XOR" :
                    Control == SLL_Oper  ? "SLL" :
                    Control == SUB_Oper  ? "SUB" :
                    Control == SRA_Oper  ? "SRA" :
                    Control == SLT_Oper  ? "SLT" :
                    Control == SLTU_Oper ? "SLTU" : "INVALID");
            $display("      Expected Out = %h", expected_Out);
            $display("      Actual Out = %h", Out);
            $display("      Expected Flags: Carry=%b, Overflow=%b, Zero=%b", exp_Carry, exp_Overflow, exp_Zero);
            $display("      Actual Flags:   Carry=%b, Overflow=%b, Zero=%b", Carry, Overflow, Zero);
            
            if (Out === expected_Out && Carry === exp_Carry && Overflow === exp_Overflow && Zero === exp_Zero) begin
                $display("      Status: PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("      Status: FAIL");
                if (Out !== expected_Out) $display("      Output mismatch!");
                if (Carry !== exp_Carry) $display("      Carry flag mismatch!");
                if (Overflow !== exp_Overflow) $display("      Overflow flag mismatch!");
                if (Zero !== exp_Zero) $display("      Zero flag mismatch!");
            end
        end
    endtask

    initial begin
        $dumpfile("ALU_TB.vcd");
        $dumpvars(1, uut);

        // Basic Operations Tests
        run_test(64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, ADD_Oper, 0, 0, 1); // ADD: 0 + 0
        run_test(64'h0000000000000001, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, ADD_Oper, 1, 0, 1); // ADD: 1 + (-1)
        
        // Overflow Tests for ADD
        run_test(64'h7FFFFFFFFFFFFFFF, 64'h0000000000000001, 64'h8000000000000000, ADD_Oper, 0, 1, 0); // Positive overflow
        run_test(64'h8000000000000000, 64'h8000000000000000, 64'h0000000000000000, ADD_Oper, 1, 1, 1); // Negative overflow
        
        // Overflow Tests for SUB
        run_test(64'h8000000000000000, 64'h0000000000000001, 64'h7FFFFFFFFFFFFFFF, SUB_Oper, 1, 1, 0); // Positive overflow
        run_test(64'h7FFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 64'h8000000000000000, SUB_Oper, 0, 1, 0); // Negative overflow
        
        // Shift Edge Cases
        run_test(64'h8000000000000000, 64'h0000000000000001, 64'h4000000000000000, SRL_Oper, 0, 0, 0); // SRL with sign bit
        run_test(64'h8000000000000000, 64'h0000000000000001, 64'hC000000000000000, SRA_Oper, 0, 0, 0); // SRA with sign bit
        run_test(64'h0000000000000001, 64'h000000000000003F, 64'h8000000000000000, SLL_Oper, 0, 0, 0); // SLL max shift
        run_test(64'hFFFFFFFFFFFFFFFF, 64'h0000000000000040, 64'hFFFFFFFFFFFFFFFF, SRA_Oper, 0, 0, 0); // SRA overflow shift amount
        
        // Comparison Edge Cases
        run_test(64'h8000000000000000, 64'h7FFFFFFFFFFFFFFF, 64'h0000000000000001, SLT_Oper, 0, 0, 0); // SLT with min vs max
        run_test(64'h8000000000000000, 64'h8000000000000000, 64'h0000000000000000, SLT_Oper, 0, 0, 1); // SLT with equal negatives
        run_test(64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, 64'h0000000000000000, SLTU_Oper, 0, 0, 1); // SLTU with -1 vs 0
        
        // Logical Operation Edge Cases
        run_test(64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, 64'h0000000000000000, AND_Oper, 0, 0, 1); // AND with all 1's and 0's
        run_test(64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, OR_Oper, 0, 0, 0);  // OR with all 1's
        run_test(64'hAAAAAAAAAAAAAAAA, 64'h5555555555555555, 64'hFFFFFFFFFFFFFFFF, OR_Oper, 0, 0, 0);  // OR with alternating patterns
        run_test(64'hAAAAAAAAAAAAAAAA, 64'hAAAAAAAAAAAAAAAA, 64'h0000000000000000, XOR_Oper, 0, 0, 1); // XOR with same values
        
        // Invalid Operation Tests
        run_test(64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, 4'b1111, 0, 0, 1); // Invalid control code
        run_test(64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, 4'b1010, 0, 0, 1); // Invalid control code
        
        // Random Pattern Tests
        run_test(64'hDEADBEEFDEADBEEF, 64'hCAFEBABECAFEBABE, 64'hDEADBEEFDEADBEEF & 64'hCAFEBABECAFEBABE, AND_Oper, 0, 0, 0);
        run_test(64'h0123456789ABCDEF, 64'hFEDCBA9876543210, 64'hFFFFFFFFFFFFFFFF, OR_Oper, 0, 0, 0);
        
        // Large Shift Amount Tests
        run_test(64'hFFFFFFFFFFFFFFFF, 64'h0000000000000020, 64'h00000000FFFFFFFF, SRL_Oper, 0, 0, 0); // 32-bit right shift
        run_test(64'h0000000000000001, 64'h0000000000000020, 64'h0000000100000000, SLL_Oper, 0, 0, 0); // 32-bit left shift
        
        // Report Results
        #10;
        $display("\n=== Test Summary ===");
        $display("Total Tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", test_count - pass_count);
        $display("==================\n");
        
        $finish;
    end

endmodule