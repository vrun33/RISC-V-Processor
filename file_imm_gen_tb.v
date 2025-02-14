`timescale 1ns/1ps

`include "imm_gen.v"

module imm_gen_TB;
    reg [31:0] instr;
    wire [63:0] imm;
    
    // Test counter
    integer test_count = 0;
    integer pass_count = 0;
    
    // File handle
    integer file;
    integer scan_count;
    reg [8*100:1] line; // Buffer for reading lines
    integer test_instr;
    
    imm_gen uut(
        .instr(instr),
        .imm(imm)
    );

    // Function to calculate expected immediate based on instruction type
    function [63:0] calculate_expected_imm;
        input [31:0] instruction;
        reg [6:0] opcode;
        begin
            opcode = instruction[6:0];
            case(opcode)
                7'b0010011, 7'b0000011: begin  // I-type
                    calculate_expected_imm = {{52{instruction[31]}}, instruction[31:20]};
                end
                7'b0100011: begin  // S-type
                    calculate_expected_imm = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]};
                end
                7'b1100011: begin  // B-type
                    calculate_expected_imm = {{52{instruction[31]}}, instruction[31], instruction[7], 
                                           instruction[30:25], instruction[11:8]};
                end
                default: begin
                    calculate_expected_imm = 64'b0;
                end
            endcase
        end
    endfunction

    initial begin
        $dumpfile("imm_gen_TB.vcd");
        $dumpvars(1, uut);

        // Open test cases file
        file = $fopen("test_cases.txt", "r");
        if (file == 0) begin
            $display("Error opening file!");
            $finish;
        end

        // Read and process each line
        while (!$feof(file)) begin
            scan_count = $fgets(line, file);
            
            // Only process the line if it's not empty and not a comment
            if (scan_count > 0 && line[8*2:1] != "//") begin
                // Parse the line for instruction
                scan_count = $sscanf(line, "%d", test_instr);
                
                // If we successfully read the value, run the test
                if (scan_count == 1) begin
                    test_count = test_count + 1;
                    instr = test_instr;
                    #10;
                    
                    $display("\nTest Case %0d:", test_count);
                    $display("Instruction: %b", instr);
                    $display("Opcode: %b", instr[6:0]);
                    $display("Expected Immediate: %d", calculate_expected_imm(instr));
                    $display("Generated Immediate: %d", imm);
                    
                    if (imm === calculate_expected_imm(instr)) begin
                        $display("Status: PASS");
                        pass_count = pass_count + 1;
                    end else begin
                        $display("Status: FAIL");
                        $display("Immediate value mismatch!");
                    end
                end
            end
        end

        // Close the file
        $fclose(file);

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