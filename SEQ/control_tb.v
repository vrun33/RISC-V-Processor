`timescale 1ns/1ps

`include "control.v"

module control_tb;
    // Inputs
    reg [6:0] op_code;
    
    // Outputs
    wire branch;
    wire mem_read;
    wire mem_to_reg;
    wire [1:0] alu_op;
    wire mem_write;
    wire alu_src;
    wire reg_write_en;
    
    // Test counter
    integer test_count = 0;
    integer pass_count = 0;
    
    // Instantiate the Unit Under Test (UUT)
    control uut(
        .op_code(op_code),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write_en(reg_write_en)
    );
    
    // Task to run individual tests
    task run_test;
        input [7:0] test_op_code;
        input exp_branch;
        input exp_mem_read;
        input exp_mem_to_reg;
        input [1:0] exp_alu_op;
        input exp_mem_write;
        input exp_alu_src;
        input exp_reg_write_en;
        input [128:0] test_name;
        begin
            test_count = test_count + 1;
            
            // Apply inputs
            op_code = test_op_code;
            #10; // Wait for outputs to stabilize
            
            // Display test information
            $display("\nTest Case %0d: %s", test_count, test_name);
            $display("OpCode: %b", op_code);
            $display("Expected outputs:");
            $display("  branch=%b, mem_read=%b, mem_to_reg=%b, alu_op=%b",
                    exp_branch, exp_mem_read, exp_mem_to_reg, exp_alu_op);
            $display("  mem_write=%b, alu_src=%b, reg_write_en=%b",
                    exp_mem_write, exp_alu_src, exp_reg_write_en);
            $display("Actual outputs:");
            $display("  branch=%b, mem_read=%b, mem_to_reg=%b, alu_op=%b",
                    branch, mem_read, mem_to_reg, alu_op);
            $display("  mem_write=%b, alu_src=%b, reg_write_en=%b",
                    mem_write, alu_src, reg_write_en);
            
            // Check if all outputs match expected values
            if (branch === exp_branch &&
                mem_read === exp_mem_read &&
                mem_to_reg === exp_mem_to_reg &&
                alu_op === exp_alu_op &&
                mem_write === exp_mem_write &&
                alu_src === exp_alu_src &&
                reg_write_en === exp_reg_write_en) begin
                $display("Status: PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("Status: FAIL");
                if (branch !== exp_branch) $display("  branch mismatch!");
                if (mem_read !== exp_mem_read) $display("  mem_read mismatch!");
                if (mem_to_reg !== exp_mem_to_reg) $display("  mem_to_reg mismatch!");
                if (alu_op !== exp_alu_op) $display("  alu_op mismatch!");
                if (mem_write !== exp_mem_write) $display("  mem_write mismatch!");
                if (alu_src !== exp_alu_src) $display("  alu_src mismatch!");
                if (reg_write_en !== exp_reg_write_en) $display("  reg_write_en mismatch!");
            end
        end
    endtask
    
    // Main test sequence
    initial begin
        $dumpfile("control_tb.vcd");
        $dumpvars(0, control_tb);
        
        // Initialize inputs
        op_code = 0;
        #100;
        
        // Test R-type instructions (add, sub, and, or, etc.)
        run_test(
            8'b0110011, // op_code
            1'b0,       // branch
            1'b0,       // mem_read
            1'b0,       // mem_to_reg
            2'b10,      // alu_op
            1'b0,       // mem_write
            1'b0,       // alu_src
            1'b1,       // reg_write_en
            "R-type instruction"
        );
        
        // Test I-type ALU instructions (addi, andi, ori, etc.)
        run_test(
            8'b0010011, // op_code
            1'b0,       // branch
            1'b0,       // mem_read
            1'b0,       // mem_to_reg
            2'b00,      // alu_op
            1'b0,       // mem_write
            1'b1,       // alu_src
            1'b1,       // reg_write_en
            "I-type ALU instruction"
        );
        
        // Test I-type Load instructions (lw, lb, etc.)
        run_test(
            8'b0000011, // op_code
            1'b0,       // branch
            1'b1,       // mem_read
            1'b1,       // mem_to_reg
            2'b00,      // alu_op
            1'b0,       // mem_write
            1'b1,       // alu_src
            1'b1,       // reg_write_en
            "I-type Load instruction"
        );
        
        // Test S-type instructions (sw, sb, etc.)
        run_test(
            8'b0100011, // op_code
            1'b0,       // branch
            1'b0,       // mem_read
            1'b0,       // mem_to_reg
            2'b00,      // alu_op
            1'b1,       // mem_write
            1'b1,       // alu_src
            1'b0,       // reg_write_en
            "S-type instruction"
        );
        
        // Test B-type instructions (beq, bne, etc.)
        run_test(
            8'b1100011, // op_code
            1'b1,       // branch
            1'b0,       // mem_read
            1'b0,       // mem_to_reg
            2'b01,      // alu_op
            1'b0,       // mem_write
            1'b0,       // alu_src
            1'b0,       // reg_write_en
            "B-type instruction"
        );
        
        // Test invalid/unsupported opcode
        run_test(
            8'b1111111, // op_code
            1'b0,       // branch
            1'b0,       // mem_read
            1'b0,       // mem_to_reg
            2'b00,      // alu_op
            1'b0,       // mem_write
            1'b0,       // alu_src
            1'b0,       // reg_write_en
            "Invalid opcode"
        );
        
        // Display test summary
        #10;
        $display("\n=== Test Summary ===");
        $display("Total Tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", test_count - pass_count);
        $display("==================\n");
        
        $finish;
    end

endmodule