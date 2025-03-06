`timescale 1ns / 1ps

`include "seq_processor.v"

module seq_processor_tb;    
    // Testbench signals
    reg clk;
    reg reset;
    
    // Instance of sequential processor
    seq_processor uut (
        .clk(clk),
        .reset(reset)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock
    end
    
    // Test counter
    integer test_count = 0;
    integer i;
    
    // Test stimulus
    initial begin
        $dumpfile("seq_processor_tb.vcd");
        $dumpvars(1, uut);
        
        // Initialize test counter
        test_count = 0;
        
        // Reset sequence
        reset = 1;
        #2;
        reset = 0;
        
        // Wait for instruction memory to be loaded
        // #10;
        
        // Run program for 200 cycles or until halt condition
        for (i = 0; i < 500; i = i + 1) begin
            @(posedge clk);
            
            // Display current processor state
            $display("\nCycle %0d:", i + 1);
            $display("PC: %h", uut.pc_out);
            $display("Instruction: %h", uut.instr);
            $display("ALU Output: %h", uut.alu_out);
            $display("Register Write Enable: %b", uut.reg_write_en);
            $display("Memory Write Enable: %b", uut.mem_write);
            $display("Branch: %b\n", uut.branch);
            $display("x4: %h\n", uut.register_file_inst.registers[4]);
            // Check for program completion
            if (uut.instr == 32'h00000000) begin
                $display("\nProgram completed after %0d cycles", i + 1);
                i = 1000;
            end
            
            // reset at the given clock cycle
            // essentially, resets pc (pc =0) and thus restarts the program
            // if (i == 50) begin
            //     reset = 1;
            //     #2;
            //     reset = 0;
            // end

            test_count = test_count + 1;
        end
        
        // Final state display
        $display("\n=== Final Processor State ===");
        $display("Total Cycles: %0d", test_count);
        
        // Display final register file contents
        $display("\nRegister File Contents:");
        for (i = 0; i < 32; i = i + 1) begin
            $display("x%0d: %h", i, uut.register_file_inst.registers[i]);
        end

        // // Display final data memory contents - at locations 10, 11, 12, 20, 21, 22, 40, 41, 42
        // $display("\nData Memory Contents (Locations 10, 11, 12, 20, 21, 22, 40, 41, 42):");
        // $display("Mem[10]: %h", uut.data_memory_inst.memory[10]);
        // $display("Mem[11]: %h", uut.data_memory_inst.memory[11]);
        // $display("Mem[12]: %h", uut.data_memory_inst.memory[12]);
        // $display("Mem[20]: %h", uut.data_memory_inst.memory[20]);
        // $display("Mem[21]: %h", uut.data_memory_inst.memory[21]);
        // $display("Mem[22]: %h", uut.data_memory_inst.memory[22]);
        // $display("Mem[40]: %h", uut.data_memory_inst.memory[40]);
        // $display("Mem[41]: %h", uut.data_memory_inst.memory[41]);
        // $display("Mem[42]: %h", uut.data_memory_inst.memory[42]);

        
        // Display final data memory contents (first 16 words)
        // $display("\nData Memory Contents (First 16 words):");
        // for (i = 0; i < 16; i = i + 1) begin
        //     $display("Mem[%0d]: %h", i, uut.data_memory_inst.memory[i]);
        // end
        
        #100;
        $finish;
    end
    
    // Monitor for instruction changes
    always @(uut.instr) begin
        $display("===============================\n");
        case (uut.instr[6:0])
            7'b0110011: $display("R-type instruction");
            7'b0010011: $display("I-type instruction");
            7'b0000011: $display("Load instruction");
            7'b0100011: $display("Store instruction");
            7'b1100011: $display("Branch instruction");
            default:    $display("Other instruction type");
        endcase
    end

endmodule