`timescale 1ns / 1ps

`include "pipelined_processor.v"

module pipelined_processor_tb;
    // Testbench signals
    reg clk;
    reg reset;
    
    // Instance of pipelined processor
    pipelined_processor uut (
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
        $dumpfile("pipelined_processor_tb.vcd");
        $dumpvars(1, uut);
        
        // Initialize test counter
        test_count = 0;
        
        // Reset sequence
        reset = 1;
        #2;
        reset = 0;
        
        // Run program for 200 cycles or until halt condition
        for (i = 0; i < 500; i = i + 1) begin
            @(posedge clk);
            
            // Display current processor state
            // print the clock cycle number and the current time in brackets
            $display("\n=== Processor State at Cycle %0d (%t) ===", i, $realtime);
            $display("PC: %h", uut.pc_out);
            $display("Instruction Fetched: %h", uut.instr);
            $display("Instruction Decoded: %h", uut.instr_IF_ID);
            
            // Pipeline registers
            $display("\n--- Pipeline Registers ---");
            $display("IF/ID - PC: %h, Instr: %h", uut.IF_ID_pc_out, uut.instr_IF_ID);
            $display("ID/EX - PC: %h, RS1: %d, RS2: %d, RD: %d", 
                     uut.ID_EX_pc_out, uut.rs1_ID_EX, uut.rs2_ID_EX, uut.rd_ID_EX);
            $display("EX/MEM - ALU Result: %h, Branch: %b, Z Flag: %b", 
                     uut.alu_out_EX_MEM, uut.branch_EX_MEM, uut.z_flag_EX_MEM);
            $display("MEM/WB - ALU Result: %h, Mem Data: %h, RD: %d", 
                     uut.alu_out_MEM_WB, uut.data_MEM_WB, uut.rd_MEM_WB);
            
            // Control signals
            $display("\n--- Control Signals ---");
            $display("ID Stage - Branch: %b, MemRead: %b, MemToReg: %b, MemWrite: %b, ALUSrc: %b, RegWrite: %b", 
                     uut.branch_out_mux, uut.mem_read_out_mux, uut.mem_to_reg_out_mux, 
                     uut.mem_write_out_mux, uut.alu_src_out_mux, uut.reg_write_en_out_mux);
            $display("EX Stage - Branch: %b, MemRead: %b, MemToReg: %b, MemWrite: %b, ALUSrc: %b, RegWrite: %b", 
                     uut.branch_ID_EX, uut.mem_read_ID_EX, uut.mem_to_reg_ID_EX, 
                     uut.mem_write_ID_EX, uut.alu_src_ID_EX, uut.reg_write_en_ID_EX);
            
            // ALU and forwarding
            $display("\n--- Execution ---");
            $display("ALU Inputs: A=%h, B=%h", uut.read_data1_mux, uut.read_data2_mux);
            $display("ALU Result: %h", uut.alu_out);
            $display("Forwarding Unit: ForwardA=%b, ForwardB=%b", uut.forward_A, uut.forward_B);
            
            // Hazard detection
            $display("\n--- Hazard Detection ---");
            $display("PC Write: %b, IF/ID Write: %b, Control Mux Sel: %b", 
                     uut.pc_write, uut.IF_ID_write, uut.control_mux_sel);
            
            // Display some register contents for verification
            $display("\n--- Register Values ---");
            // $display("x1: %h", uut.register_file_inst.registers[1]);
            // $display("x2: %h", uut.register_file_inst.registers[2]);
            $display("x3: %h", uut.register_file_inst.registers[3]);
            // $display("x4: %h", uut.register_file_inst.registers[4]);
            // $display("x5: %h", uut.register_file_inst.registers[5]);
            
            // Check for program completion
            // if (uut.instr == 32'h00000000) begin
            //     $display("\nProgram completed after %0d cycles", i + 1);
            //     i = 200;
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
        
        // Display pipeline state at end
        // $display("\n=== Final Pipeline State ===");
        // $display("IF/ID - PC: %h, Instr: %h", uut.IF_ID_pc_out, uut.instr_IF_ID);
        // $display("ID/EX - PC: %h", uut.ID_EX_pc_out);
        // $display("EX/MEM - ALU Result: %h", uut.alu_out_EX_MEM);
        // $display("MEM/WB - ALU Result: %h", uut.alu_out_MEM_WB);
        
        // Display selected data memory contents
        // $display("\nData Memory Contents (Selected Locations):");
        // // Display 10 memory locations (assuming these are of interest)
        // for (i = 0; i < 10; i = i + 1) begin{
        //     $display("Mem[%0d]: %h", i, uut.data_memory_inst.memory[i]);
        // }
        // end
        // #100;
        $finish;
    end
    
    // Monitor for instruction changes in the IF stage
    always @(uut.instr) begin
        $display("===============================");
        $display("New Instruction Fetched: %h", uut.instr);
        case (uut.instr[6:0])
            7'b0110011: $display("R-type instruction");
            7'b0010011: $display("I-type instruction");
            7'b0000011: $display("Load instruction");
            7'b0100011: $display("Store instruction");
            7'b1100011: $display("Branch instruction");
            default:    $display("Other instruction type");
        endcase
    end
    
    // Monitor for instruction changes in the ID stage
    // always @(uut.instr_IF_ID) begin
    //     $display("===============================");
    //     $display("New Instruction Decoded: %h", uut.instr_IF_ID);
    // end
    
    // // Monitor for branch decisions
    // always @(posedge clk) begin
    //     if (uut.branch_EX_MEM && uut.z_flag_EX_MEM) begin
    //         $display("===============================");
    //         $display("BRANCH TAKEN! PC updated to %h", uut.pc_next_EX_MEM);
    //     end
    // end
    
    // // Monitor for hazard detection
    // always @(uut.control_mux_sel) begin
    //     if (uut.control_mux_sel) begin
    //         $display("===============================");
    //         $display("HAZARD DETECTED! Pipeline stalled.");
    //     end
    // end
    
    // // Monitor for forwarding
    // always @(uut.forward_A or uut.forward_B) begin
    //     if (uut.forward_A != 2'b00 || uut.forward_B != 2'b00) begin
    //         $display("===============================");
    //         $display("DATA FORWARDING ACTIVE: ForwardA=%b, ForwardB=%b", uut.forward_A, uut.forward_B);
    //     end
    // end

endmodule