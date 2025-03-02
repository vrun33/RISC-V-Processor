`timescale 1ns/1ps
`include "instruction_mem.v"

module instruction_memory_tb;
    reg clk;
    reg reset;
    reg [63:0] addr;
    wire [31:0] instr;
    
    // Test counter
    integer test_count = 0;
    integer pass_count = 0;
    
    instruction_memory #(
        .MEM_SIZE(4095),
        .MEM_INIT_FILE("Test_imemory_2.txt")
    ) imem (
        .clk(clk),
        .reset(reset),
        .addr(addr),
        .instr(instr)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Add GTKWave dumping
    initial begin
        $dumpfile("instruction_memory_tb.vcd");
        $dumpvars(0, instruction_memory_tb);
    end

    task run_test;
        input [63:0] test_addr;
        input [31:0] expected_instr;
        begin
            test_count = test_count + 1;
            addr = test_addr;
            
            @(posedge clk);
            #2;
            
            $display("Test Case %0d:", test_count);
            $display("Address = 0x%h", addr);
            $display("Expected Instruction = 0x%h", expected_instr);
            $display("Actual Instruction   = 0x%h", instr);
            
            if (instr === expected_instr) begin
                $display("Status: PASS\n");
                pass_count = pass_count + 1;
            end else begin
                $display("Status: FAIL\n");
            end
        end
    endtask

    initial begin
        // Initialize signals
        addr = 0;
        reset = 0;
        test_count = 0;
        pass_count = 0;

        $display("Starting Instruction Memory Test");
        
        // Wait for memory initialization
        #10;

        // Test cases for little-endian format
        // Original test cases
        run_test(0, 32'h00500113);    // First instruction (bytes 0-3)
        #10;
        run_test(4, 32'h00a00193);    // Second instruction (bytes 4-7)
        #10;
        run_test(8, 32'h003100b3);    // Third instruction (bytes 8-11)
        #10;
        run_test(12, 32'h40310133);   // Fourth instruction (bytes 12-15)
        #10;
        
        // Additional test cases
        run_test(16, 32'h0021a233);   // Fifth instruction (bytes 16-19)
        #10;
        run_test(20, 32'h0041f2b3);   // Sixth instruction (bytes 20-23)
        #10;
        run_test(24, 32'h00416333);   // Seventh instruction (bytes 24-27)
        #10;
        run_test(28, 32'h004143b3);   // Eighth instruction (bytes 28-31)
        #10;
        run_test(32, 32'h00002437);   // Ninth instruction (bytes 32-35)
        #10;
        run_test(36, 32'h06042223);   // Tenth instruction (bytes 36-39)
        #10;
        run_test(40, 32'h06442483);   // Eleventh instruction (bytes 40-43)
        #10;
        run_test(44, 32'h00119493);   // Twelfth instruction (bytes 44-47)
        #10;
        run_test(48, 32'h00115513);   // Thirteenth instruction (bytes 48-51)
        #10;
        run_test(52, 32'h40115593);   // Fourteenth instruction (bytes 52-55)
        #10;
        run_test(56, 32'h00208663);   // Fifteenth instruction (bytes 56-59)
        #10;
        
        // Report Results
        $display("=== Test Summary ===");
        $display("Total Tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", test_count - pass_count);
        $display("==================\n");
        
        #10 $finish;
    end

endmodule