`timescale 1ns / 1ps

`include "instruction_memory.v"

module instruction_memory_TB;
    reg clk;
    reg [63:0] addr;
    wire [31:0] instr;
    
    // Test counter
    integer test_count = 0;
    integer pass_count = 0;
    
    // Test memory file creation
    integer file, i;
    reg [31:0] expected_instructions [0:7]; // Store expected values
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Instantiate the instruction memory module
    instruction_memory #(
        .MEM_SIZE(32),  // Smaller size for testing
        .MEM_INIT_FILE("test_mem_init.txt")
    ) uut (
        .clk(clk),
        .addr(addr),
        .instr(instr)
    );
    
    task run_test;
        input [64:0] test_addr;
        input [31:0] expected_instr;
        begin
            test_count = test_count + 1;
            addr = test_addr;
            
            @(posedge clk);
            @(posedge clk); // Wait one extra cycle for instruction to be read
            #2; // Wait for outputs to stabilize
            
            $display("\nTest Case %0d:", test_count);
            $display("Test: addr = %h", addr);
            $display("      Expected instr = %h", expected_instr);
            $display("      Actual instr = %h", instr);
            
            if (instr === expected_instr) begin
                $display("      Status: PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("      Status: FAIL");
                $display("      Instruction mismatch!");
            end
        end
    endtask
    
    // Create test memory initialization file
    initial begin
        file = $fopen("test_mem_init.txt", "w");
        // Write some test instructions in byte format
        // Instruction 1: 0x11223344
        $fwrite(file, "11\n");
        $fwrite(file, "22\n");
        $fwrite(file, "33\n");
        $fwrite(file, "44\n");
        // Instruction 2: 0xAABBCCDD
        $fwrite(file, "AA\n");
        $fwrite(file, "BB\n");
        $fwrite(file, "CC\n");
        $fwrite(file, "DD\n");
        // Instruction 3: 0xFEDCBA98
        $fwrite(file, "FE\n");
        $fwrite(file, "DC\n");
        $fwrite(file, "BA\n");
        $fwrite(file, "98\n");
        $fclose(file);
        
        // Store expected values
        expected_instructions[0] = 32'h11223344;
        expected_instructions[1] = 32'hAABBCCDD;
        expected_instructions[2] = 32'hFEDCBA98;
    end
    
    initial begin
        $dumpfile("instruction_memory_TB.vcd");
        $dumpvars(1, uut);
        
        // Initialize signals
        addr = 64'h0;
        #20; // Wait for memory initialization
        
        // Test 1: Read first instruction
        run_test(64'h0, expected_instructions[0]);
        
        // Test 2: Read second instruction
        run_test(64'h4, expected_instructions[1]);
        
        // Test 3: Read third instruction
        run_test(64'h8, expected_instructions[2]);
        
        // Test 4: Read from unaligned address (should still read aligned instruction)
        run_test(64'h1, expected_instructions[0]);
        
        // Test 5: Read from last valid address
        run_test(64'h1C, 32'h0); // Should read zeros or undefined
        
        // Test 6: Multiple consecutive reads
        run_test(64'h0, expected_instructions[0]);
        run_test(64'h4, expected_instructions[1]);
        run_test(64'h8, expected_instructions[2]);
        
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