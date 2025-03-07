`timescale 1ns/1ps

`include "imm_gen.v"

module imm_gen_TB;
    reg [31:0] instr;
    wire [63:0] imm;
    
    // Test counter
    integer test_count = 0;
    integer pass_count = 0;
    
    imm_gen uut(
        .instr(instr),
        .imm(imm)
    );

    task run_test;
        input [31:0] test_instr;
        input [63:0] expected_imm;
        begin
            test_count = test_count + 1;
            instr = test_instr;
            #10;
            
            $display("\nTest Case %0d:", test_count);
            $display("Instruction: %b %b %b %b %b %b %b %b", 
                    instr[31:28], instr[27:24], instr[23:20], instr[19:16],
                    instr[15:12], instr[11:8], instr[7:4], instr[3:0]);
            $display("Opcode: %b", instr[6:0]);
            $display("Expected Immediate: %h", expected_imm);
            $display("Actual Immediate: %h", imm);
            
            if (imm === expected_imm) begin
                $display("Status: PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("Status: FAIL");
                $display("Immediate value mismatch!");
            end
        end
    endtask

    initial begin
        $dumpfile("imm_gen_TB.vcd");
        $dumpvars(1, uut);

        // 1
        // I-type instruction tests (op-type)
        // ADDI x1, x2, 12
        run_test(32'b0000_0000_1100_0001_0000_0000_1001_0011,
                64'h000000000000000C);

        //2
        // ADDI x1, x2, -12
        run_test(32'b1111_1111_1100_0001_0000_0000_1001_0011,
                64'hFFFFFFFFFFFFFFFC);

        //3
        // I-type instruction tests (load-type)
        // LW x1, 16(x2)
        run_test(32'b0000_0001_0000_0001_0010_0000_1000_0011,
                64'h0000000000000010);

        //4
        // LW x1, -16(x2)
        run_test(32'b1111_1111_0000_0001_0010_0000_1000_0011,
                64'hFFFFFFFFFFFFFFF0);

        //5
        // S-type instruction tests
        // SW x1, 20(x2)
        run_test(32'b0000_0010_0001_0001_0010_1010_0010_0011,
                64'h0000000000000034);

        //6
        // SW x1, -20(x2)
        run_test(32'b1111_1110_0001_0001_0010_1110_0010_0011,
                64'hFFFFFFFFFFFFFFFC);

        //7
        // B-type instruction tests
        // BEQ x1, x2, 16
        run_test(32'b0000_0000_0010_0000_1000_1000_0110_0011,
                64'h0000000000000010);

        //8
        // BEQ x1, x2, -16
        run_test(32'b1111_1110_0010_0000_1000_1000_1110_0011,
                64'hFFFFFFFFFFFFFFF0);

        //9
        // Edge cases
        // Maximum positive immediate for I-type
        run_test(32'b0111_1111_1111_0000_0000_0000_0001_0011,
                64'h00000000000007FF);

        //10
        // Maximum negative immediate for I-type
        run_test(32'b1000_0000_0000_0000_0000_0000_0001_0011,
                64'hFFFFFFFFFFFFF800);

        //11
        // Invalid opcode test
        run_test(32'b0000_0000_0000_0000_0000_0000_0111_1111,
                64'h0000000000000000);

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