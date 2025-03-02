`timescale 1ns/1ps
`include "alu.v"

module alu_tb;
    reg [63:0] a, b;
    reg [3:0] control;
    wire [63:0] result;
    wire z_flag, n_flag, v_flag, c_flag;
    
    // Control codes
    localparam  AND  = 4'b0000,
                OR   = 4'b0001,
                ADD  = 4'b0010,
                SRL  = 4'b0011,
                XOR  = 4'b0100,
                SLL  = 4'b0101,
                SUB  = 4'b0110,
                SRA  = 4'b0111,
                SLT  = 4'b1000,
                SLTU = 4'b1001;
    
    alu uut(
        .a(a),
        .b(b),
        .control(control),
        .result(result),
        .z_flag(z_flag),
        .n_flag(n_flag),
        .v_flag(v_flag),
        .c_flag(c_flag)
    );

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        // Test 1: ADD (5 + 3 = 8)
        // Expected: result = 0x0000000000000008
        // Flags: C=0, V=0, N=0, Z=0
        a = 64'h0000000000000005;
        b = 64'h0000000000000003;
        control = ADD;
        #10;
        $display("Test 1: Addition");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 2: SUB (8 - 3 = 5)
        // Expected: result = 0x0000000000000005
        // Flags: C=0, V=0, N=0, Z=0
        a = 64'h0000000000000008;
        b = 64'h0000000000000003;
        control = SUB;
        #10;
        $display("Test 2: Subtraction");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 3: AND (FFFF0000FFFF0000 & FFFFFFFF00000000)
        // Expected: result = 0xFFFF000000000000
        // Flags: C=0, V=0, N=1, Z=0
        a = 64'hFFFF0000FFFF0000;
        b = 64'hFFFFFFFF00000000;
        control = AND;
        #10;
        $display("Test 3: AND");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 4: OR (FFFF0000FFFF0000 | 00000000FFFF0000)
        // Expected: result = 0xFFFF0000FFFF0000
        // Flags: C=0, V=0, N=1, Z=0
        a = 64'hFFFF0000FFFF0000;
        b = 64'h00000000FFFF0000;
        control = OR;
        #10;
        $display("Test 4: OR");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 5: XOR (FFFF...FFFF ^ FFFF...FFFF)
        // Expected: result = 0x0000000000000000
        // Flags: C=0, V=0, N=0, Z=1
        a = 64'hFFFFFFFFFFFFFFFF;
        b = 64'hFFFFFFFFFFFFFFFF;
        control = XOR;
        #10;
        $display("Test 5: XOR");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 6: SLT (-1 < 0 = true)
        // Expected: result = 0x0000000000000001
        // Flags: C=0, V=0, N=0, Z=0
        a = 64'hFFFFFFFFFFFFFFFF;
        b = 64'h0000000000000000;
        control = SLT;
        #10;
        $display("Test 6: SLT");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 7: SRA (8000...0000 >> 1)
        // Expected: result = 0xC000000000000000
        // Flags: C=0, V=0, N=1, Z=0
        a = 64'h8000000000000000;
        b = 64'h0000000000000001;
        control = SRA;
        #10;
        $display("Test 7: SRA");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 8: SLL (1 << 1)
        // Expected: result = 0x0000000000000002
        // Flags: C=0, V=0, N=0, Z=0
        a = 64'h0000000000000001;
        b = 64'h0000000000000001;
        control = SLL;
        #10;
        $display("Test 8: SLL");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 9: ADD causing overflow (MAX_INT + 1)
        // Expected: result = 0x8000000000000000
        // Flags: C=0, V=1, N=1, Z=0
        a = 64'h7FFFFFFFFFFFFFFF;
        b = 64'h0000000000000001;
        control = ADD;
        #10;
        $display("Test 9: Addition with Overflow");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 10: ADD of two negative numbers (MIN_INT + MIN_INT)
        // Expected: result = 0x0000000000000000
        // Flags: C=1, V=0, N=0, Z=1
        a = 64'h8000000000000000;
        b = 64'h8000000000000000;
        control = ADD;
        #10;
        $display("Test 10: Addition of Two Large Negative Numbers");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 11: SUB causing underflow (MIN_INT - 1)
        // Expected: result = 0x7FFFFFFFFFFFFFFF
        // Flags: C=0, V=1, N=0, Z=0
        a = 64'h8000000000000000;
        b = 64'h0000000000000001;
        control = SUB;
        #10;
        $display("Test 11: Subtraction with Underflow");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 12: SLTU with equal values
        // Expected: result = 0x0000000000000000
        // Flags: C=0, V=0, N=0, Z=1
        a = 64'hFFFFFFFFFFFFFFFF;
        b = 64'hFFFFFFFFFFFFFFFF;
        control = SLTU;
        #10;
        $display("Test 12: SLTU with Equal Values");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 13: SRA with maximum shift (63 positions)
        // Expected: result = 0xFFFFFFFFFFFFFFFF
        // Flags: C=0, V=0, N=1, Z=0
        a = 64'h8000000000000000;
        b = 64'h000000000000003F;
        control = SRA;
        #10;
        $display("Test 13: SRA with Maximum Shift");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 14: SLL with overflow (bit shifts out)
        // Expected: result = 0x8000000000000000
        // Flags: C=0, V=0, N=1, Z=0
        a = 64'h4000000000000000;
        b = 64'h0000000000000001;
        control = SLL;
        #10;
        $display("Test 14: SLL with Overflow");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 15: AND with alternating bits
        // Expected: result = 0x0000000000000000
        // Flags: C=0, V=0, N=0, Z=1
        a = 64'hAAAAAAAAAAAAAAAA;
        b = 64'h5555555555555555;
        control = AND;
        #10;
        $display("Test 15: AND with Alternating Bits");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 16: SLT with edge case (MIN_INT < MAX_INT)
        // Expected: result = 0x0000000000000001
        // Flags: C=0, V=0, N=0, Z=0
        a = 64'h8000000000000000;
        b = 64'h7FFFFFFFFFFFFFFF;
        control = SLT;
        #10;
        $display("Test 16: SLT with Extreme Values");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 17: Invalid control signal
        // Expected: result = 0x0000000000000000 (or implementation defined)
        // Flags: Implementation defined
        a = 64'h0000000000000001;
        b = 64'h0000000000000001;
        control = 4'b1111;
        #10;
        $display("Test 17: Invalid Control Signal");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        // Test 18: Zero input ADD operation
        // Expected: result = 0x0000000000000000
        // Flags: C=0, V=0, N=0, Z=1
        a = 64'h0000000000000000;
        b = 64'h0000000000000000;
        control = ADD;
        #10;
        $display("Test 18: All-Zero Addition");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("result = %h", result);
        $display("Flags: C=%b, V=%b, N=%b, Z=%b\n", c_flag, v_flag, n_flag, z_flag);

        #10 $finish;
    end
endmodule