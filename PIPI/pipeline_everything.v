// Pipelined Wrapper connecting all the blocks

module pc(
    input clk,
    input reset,
    input [63:0] pc_in,
    input pc_write,     // write enable signal from hazard zaza unit
    output [63:0] pc_out
);

    reg [63:0] pc_reg;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            pc_reg <= 64'h0;
        end
            
        else if(pc_write) begin // update iff pc_write is high else stall
            pc_reg <= pc_in;
        end
    end

    assign pc_out = pc_reg;
    
endmodule


module instruction_memory #(
    parameter MEM_SIZE = 4095,
    parameter MEM_INIT_FILE = "Test_Vector_Add.txt"
    // parameter MEM_INIT_FILE = "imemory.txt"
) (
    input wire clk,
    input wire reset,  // Added reset signal
    input wire [63:0] addr,
    output wire [31:0] instr
);
    // Memory array
    reg [7:0] mem [0:MEM_SIZE-1];
    
    // File reading variables
    integer file, status, i;
    integer decimal_value;
    
    // Initialize memory from file
    initial begin
        // Clear memory
        for (i = 0; i < MEM_SIZE; i = i + 1)
            mem[i] = 0;
            
        // Read from file
        file = $fopen(MEM_INIT_FILE, "r");
        if (!file) begin
            $display("Error: Could not open %s", MEM_INIT_FILE);
            $finish;
        end
        
        i = 0;
        while (!$feof(file) && i < MEM_SIZE) begin
            status = $fscanf(file, "%d", decimal_value);
            // Print whatever is read
            // $display("Read %0d", decimal_value);
            if (status == 1 && decimal_value >= 0 && decimal_value <= 255) begin
                mem[i] = decimal_value;
                i = i + 1;
            end
        end
        
        $fclose(file);
        $display("Loaded %0d bytes from %s", i, MEM_INIT_FILE);
    end

    reg [31:0] tmp;
    assign instr = tmp;

    // // Read instruction with reset (big-endian)
    // always @(posedge clk or posedge reset) begin
    //     if (reset) begin
    //         tmp <= 32'h0;  // Reset the instruction register to zero
    //     end else begin
    //         tmp <= {mem[addr+0], mem[addr+1], mem[addr+2], mem[addr+3]};
    //     end
    // end

    // Read instruction with reset (big-endian)
    always @(*) 
    begin
        tmp <= {mem[addr+0], mem[addr+1], mem[addr+2], mem[addr+3]};
    end

endmodule

module control(
    input wire [6:0] op_code,
    output wire branch,
    output wire mem_read,
    output wire mem_to_reg,
    output wire [1:0] alu_op,
    output wire mem_write,
    output wire alu_src,
    output wire reg_write_en
);
    

    localparam R_type = 7'b0110011;
    localparam I_op_type = 7'b0010011;
    localparam I_load_type = 7'b0000011;
    localparam S_type = 7'b0100011;
    localparam B_type = 7'b1100011;

    reg branch_reg, mem_read_reg, mem_to_reg_reg, mem_write_reg, alu_src_reg, reg_write_en_reg;
    reg [1:0] alu_op_reg;

    assign branch = branch_reg;
    assign mem_read = mem_read_reg;
    assign mem_to_reg = mem_to_reg_reg;
    assign alu_op = alu_op_reg;
    assign mem_write = mem_write_reg;
    assign alu_src = alu_src_reg;
    assign reg_write_en = reg_write_en_reg;

    always @(*) begin
        case(op_code)
            R_type: begin
                branch_reg = 1'b0;
                mem_read_reg = 1'b0;
                mem_to_reg_reg = 1'b0;
                alu_op_reg = 2'b10;
                mem_write_reg = 1'b0;
                alu_src_reg = 1'b0;
                reg_write_en_reg = 1'b1;
            end
            I_op_type: begin
                branch_reg = 1'b0;
                mem_read_reg = 1'b0;
                mem_to_reg_reg = 1'b0;
                alu_op_reg = 2'b00;
                mem_write_reg = 1'b0;
                alu_src_reg = 1'b1;
                reg_write_en_reg = 1'b1;
            end
            I_load_type: begin
                branch_reg = 1'b0;
                mem_read_reg = 1'b1;
                mem_to_reg_reg = 1'b1;
                alu_op_reg = 2'b00;
                mem_write_reg = 1'b0;
                alu_src_reg = 1'b1;
                reg_write_en_reg = 1'b1;
            end
            S_type: begin
                branch_reg = 1'b0;
                mem_read_reg = 1'b0;
                mem_to_reg_reg = 1'b0;
                alu_op_reg = 2'b00;
                mem_write_reg = 1'b1;
                alu_src_reg = 1'b1;
                reg_write_en_reg = 1'b0;
            end
            B_type: begin
                branch_reg = 1'b1;
                mem_read_reg = 1'b0;
                mem_to_reg_reg = 1'b0;
                alu_op_reg = 2'b01;
                mem_write_reg = 1'b0;
                alu_src_reg = 1'b0;
                reg_write_en_reg = 1'b0;
            end
            // J_type: begin
            //     branch_reg = 1'b1;
            //     mem_read_reg = 1'b0;
            //     mem_to_reg_reg = 1'b0;
            //     alu_op_reg = 2'b00;
            //     mem_write_reg = 1'b0;
            //     alu_src_reg = 1'b0;
            //     reg_write_en_reg = 1'b0;
            // end
            default: begin
                branch_reg = 1'b0;
                mem_read_reg = 1'b0;
                mem_to_reg_reg = 1'b0;
                alu_op_reg = 2'b00;
                mem_write_reg = 1'b0;
                alu_src_reg = 1'b0;
                reg_write_en_reg = 1'b0;
            end
        endcase
    end

endmodule

module alu_control (
    input wire [1:0] alu_op,      // {alu_op_1, alu_op_0}
    input wire [3:0] instr_bits,   // {30,14,13,12}
    output wire [3:0] op          // {op_3, op_2, op_1, op_0}
);
    wire alu_op_1 = alu_op[1];
    wire alu_op_0 = alu_op[0];
    wire i_30 = instr_bits[3];    
    wire i_14 = instr_bits[2];    
    wire i_13 = instr_bits[1];    
    wire i_12 = instr_bits[0];    
    
    // Gate level implementation of the ALU control logic
    wire temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, temp9;

    not (temp1, alu_op_0);
    not (temp2, alu_op_1);
    not (temp3, i_12);
    not (temp4, i_13);
    not (temp5, i_14);
    not (temp6, i_30);

    and (temp7, alu_op_1, i_30, temp3, temp4, temp5);  // alu_op_1 & i_30 & ~i_12 & ~i_13 & ~i_14
    and (temp8, temp1, temp2);                         // ~alu_op_0 & ~alu_op_1
    and (temp9, alu_op_1, temp3, temp4, temp5);        // alu_op_1 & ~i_12 & ~i_13 & ~i_14

    assign op[3] = 1'b0;
    or (op[2], alu_op_0, temp7);
    or (op[1], temp8, alu_op_0, temp9);
    and (op[0], alu_op_1, temp6, temp3, i_13, i_14);
endmodule

module imm_gen(
    input wire [31:0] instr,
    output reg [63:0] imm
);

    localparam I_op_type = 7'b0010011;
    localparam I_load_type = 7'b0000011;
    localparam S_type = 7'b0100011;
    localparam B_type = 7'b1100011;

    wire [6:0] opcode;
    assign opcode = instr[6:0];

    always @(*) begin
        case(opcode)
            I_op_type, I_load_type: begin
                imm = {{52{instr[31]}}, instr[31:20]};
            end

            S_type: begin
                imm = {{52{instr[31]}}, instr[31:25], instr[11:7]};
            end

            B_type: begin
                imm = {{51{instr[31]}}, instr[31], instr[7], 
                            instr[30:25], instr[11:8], 1'b0};
            end

            default: begin
                imm = 64'b0;
            end
        endcase
    end

endmodule

module register_file (
    input wire clk,
    input wire reset,
    input wire [4:0] read_reg1,
    input wire [4:0] read_reg2,
    input wire [4:0] write_reg,
    input wire [63:0] write_data,
    input wire reg_write_en,
    output wire [63:0] read_data1,
    output wire [63:0] read_data2
);

    // 31 registers, each 64 bits
    reg [63:0] registers [31:0];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 64'b0;
        end
    end

    // Read data from registers
    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];

    // Write data to registers or reset all registers
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers to 0
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 64'b0;
            end
        end else if (reg_write_en && write_reg != 5'b0) begin
            // Normal write operation (register x0 is hardwired to 0)
            registers[write_reg] <= write_data;
        end
    end

endmodule

module data_memory #(parameter DATA_WIDTH = 64, parameter ADDR_WIDTH = 10) (
    input wire clk,
    input wire reset,                // Active-high asynchronous reset
    input wire [ADDR_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0] write_data,
    input wire mem_write,
    input wire mem_read,
    output wire [DATA_WIDTH-1:0] read_data
);
    // Memory array
    reg [DATA_WIDTH-1:0] mem [(2**ADDR_WIDTH)-1:0];
    integer i; // Declare the loop variable outside the always block

    // Write to memory with asynchronous reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Clear entire memory on reset
            for (i = 0; i < (2**ADDR_WIDTH); i = i + 1) begin
                mem[i] = 0; // Use '=' for blocking assignment in reset loops
            end
        end 
        else if (mem_write) begin
            mem[addr] <= write_data; // Non-blocking assignment for sequential logic
        end
    end

    reg [DATA_WIDTH-1:0] read_data_reg; // Declare read_data as a reg for continuous assignment

    assign read_data = read_data_reg; // Assign read_data to read_data_reg
    
    always @(*) begin
        if (mem_read) begin
            read_data_reg = mem[addr]; // Read data from memory
        end
        else begin
            read_data_reg = 0; // Output 0 if mem_read is low (or High-z if required)
        end
    end
endmodule

module mux_2x1(in1, in2, s0, y);

    input wire [63:0]in1;
    input wire [63:0]in2;
    input wire s0;
    output wire [63:0]y;

    assign y = s0 ? in2 : in1;

endmodule

module mux_4x1(in3, in2, in1, in0, s, y);

    
    input wire [63:0] in0;
    input wire [63:0] in1;
    input wire [63:0] in2;
    input wire [63:0] in3;
    input wire [1:0] s;
    output wire [63:0] y;

    wire [63:0] mux1, mux2;

    mux_2x1 Mux1(in0, in1, s[0], mux1);
    mux_2x1 Mux2(in2, in3, s[0], mux2);
    mux_2x1 Mux3(mux1, mux2, s[1], y);

endmodule

module CLA_N_Bit #(parameter Num = 64)(In1, In2, Cin, Sum, Carry);

    input [Num - 1 : 0]In1;
    input [Num - 1 : 0]In2;
    input Cin;
    output [Num - 1 : 0]Sum;
    output Carry;
    wire [Num : 0]Inter;
    
    assign Inter[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < Num; i = i + 4) 
        begin : CLA_loop
            CLA4Bit fa(In1[i + 3 : i], In2[i + 3 : i], Inter[i], Sum[i + 3 : i], Inter[i + 4]);
        end
    endgenerate

    assign Carry = Inter[Num];
    
endmodule

module CLA4Bit(input [3:0]a, input [3:0]b, input cin, output [3:0]s, output cout);

    wire [4:0]Carry; // Stage i takes carry in c[i], and produes c[i+1]
    wire [3:0]Pi; // Pi = ai ^ bi
    wire [3:0]Gi; // Gi = ai & bi
    assign Carry[0] = cin;
    assign cout = Carry[4];

    genvar i;
    generate
        for(i = 0; i < 4; i = i + 1)
        begin : Pi_Gi_Loop
            assign Pi[i] = a[i] ^ b[i];
            assign Gi[i] = a[i] & b[i];
        end
    endgenerate

    assign Carry[1] = Gi[0] | (Pi[0] & Carry[0]);
    assign Carry[2] = Gi[1] | (Pi[1] & Gi[0]) | (Pi[1] & Pi[0] & Carry[0]);
    assign Carry[3] = Gi[2] | (Pi[2] & Gi[1]) | (Pi[2] & Pi[1] & Gi[0]) | (Pi[2] & Pi[1] & Pi[0] & Carry[0]);
    assign Carry[4] = Gi[3] | (Pi[3] & Gi[2]) | (Pi[3] & Pi[2] & Gi[1]) | (Pi[3] & Pi[2] & Pi[1] & Gi[0]) | (Pi[3] & Pi[2] & Pi[1] & Pi[0] & Carry[0]);

    generate
        for(i = 0; i < 4; i = i + 1)
        begin : Sum_Loop
            assign s[i] = Pi[i] ^ Carry[i];
        end
    endgenerate

endmodule

module and2 (
    input wire in1,
    input wire in2,
    output wire out
);
    and (out, in1, in2);
endmodule

module sl1(
    input [63:0] in,   
    output [63:0] out
);
    assign out = {in[62:0], 1'b0};
endmodule

module fulladder1(
    output sum,
    output cout,
    input a,
    input b,
    input cin
);
    wire s1, c1, c2;

    xor x1(s1, a, b);
    xor x2(sum, s1, cin); // sum = a XOR b XOR cin
    and a1(c1, s1, cin);
    and a2(c2, a, b);
    or o1(cout, c1, c2); // cout = ab + cin (a XOR b)

endmodule

module fa64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] sum,
    output c_out,      
    output v_flag,     
    output n_flag,     
    output z_flag      
);
    wire [64:0] carry;
    wire a_sum_diff_sign;
    wire same_signs_temp;     
    wire same_signs;          

    assign carry[0] = 0;

    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin 
            fulladder1 fa1(
                .sum(sum[i]), 
                .cout(carry[i+1]), 
                .a(a[i]), 
                .b(b[i]), 
                .cin(carry[i])
            );
        end
    endgenerate

    assign c_out = carry[64];
    
    // A and Sum have opposite signs
    xor x1(a_sum_diff_sign, a[63], sum[63]);
    
    // A and B have same signs 
    xor x2(same_signs_temp, a[63], b[63]);
    xor x3(same_signs, same_signs_temp, 1'b1);  // XNOR 

    and a1(v_flag, a_sum_diff_sign, same_signs);
    
    assign n_flag = sum[63];
    assign z_flag = (sum == 64'b0);
endmodule

// Subtractor 64-bit for ALU using 1-bit Full Adder
// `include "fulladder1.v"
module sub64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] diff,
    output c_out,      
    output v_flag,     
    output n_flag,     
    output z_flag      
);
    wire [63:0] b_inv;
    wire [64:0] carry;
    wire a_diff_diff_sign;    
    wire opp_signs;           
    
    // Invert b for subtraction
    genvar j;
    generate
        for(j=0; j< 64;j=j+1) begin
            xor x1(b_inv[j], b[j], 1'b1);
        end
    endgenerate
    
    assign carry[0] = 1;
    
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin
            fulladder1 fa1(
                .sum(diff[i]),
                .cout(carry[i+1]),
                .a(a[i]),
                .b(b_inv[i]),
                .cin(carry[i])
            );
        end
    endgenerate

    assign c_out = carry[64];
    
    // A and Diff have opposite signs
    xor x2(a_diff_diff_sign, a[63], diff[63]);
    
    // A and B have opposite signs
    xor x3(opp_signs, a[63], b[63]);
    
    // AND of conditions 
    and a1(v_flag, a_diff_diff_sign, opp_signs);
    
    assign n_flag = diff[63];
    assign z_flag = (diff == 64'b0);
endmodule

// Shift Left Logical 64-bit for ALU
module sll64(
    input [63:0] rs1,   
    input [63:0] rs2,    
    output [63:0] result,
    output z_flag,
    output v_flag
);
    wire [5:0] shift_amt;  
    assign shift_amt = rs2[5:0]; 
    
    wire [63:0] stage1, stage2, stage4, stage8, stage16, stage32;  

    assign stage1 = shift_amt[0] ? {rs1[62:0], 1'b0} : rs1; // shift left by 0 or 1

    assign stage2 = shift_amt[1] ? {stage1[61:0], 2'b0} : stage1; // shift left by 0 or 2

    assign stage4 = shift_amt[2] ? {stage2[59:0], 4'b0} : stage2; // shift left by 0 or 4
    
    assign stage8 = shift_amt[3] ? {stage4[55:0], 8'b0} : stage4; // shift left by 0 or 8

    assign stage16 = shift_amt[4] ? {stage8[47:0], 16'b0} : stage8; // shift left by 0 or 16
    
    assign stage32 = shift_amt[5] ? {stage16[31:0], 32'b0} : stage16; // shift left by 0 or 32
    
    assign result = stage32;  
    assign z_flag = (result == 64'b0);
    assign v_flag = (rs1[63] ^ result[63]);

endmodule

// 64-bit AND Operation for ALU
module and64(
    input[63:0] a,
    input[63:0] b,
    output[63:0] out,
    output z_flag
);
    genvar i;

    generate
        for(i = 0; i<64; i=i+1) begin
            and a1(out[i], a[i], b[i]);
        end
    endgenerate

    assign z_flag = (out == 64'b0);
    
endmodule

// Barrel Shifter: Logical Right Shift
module srl64(
    input [63:0] rs1,   
    input [63:0] rs2,    
    output [63:0] result,
    output z_flag
);
    wire [5:0] shift_amt; 
    assign shift_amt = rs2[5:0]; 
    
    wire [63:0] stage1, stage2, stage4, stage8, stage16, stage32; 

    assign stage1 = shift_amt[0] ? {1'b0, rs1[63:1]} : rs1; // shift right by 0 or 1

    assign stage2 = shift_amt[1] ? {2'b0, stage1[63:2]} : stage1; // shift right by 0 or 2

    assign stage4 = shift_amt[2] ? {4'b0, stage2[63:4]} : stage2; // shift right by 0 or 4
    
    assign stage8 = shift_amt[3] ? {8'b0, stage4[63:8]} : stage4; // shift right by 0 or 8

    assign stage16 = shift_amt[4] ? {16'b0, stage8[63:16]} : stage8; // shift right by 0 or 16
    
    assign stage32 = shift_amt[5] ? {32'b0, stage16[63:32]} : stage16; // shift right by 0 or 32
    
    assign result = stage32; 
    assign z_flag = (result == 64'b0); 

endmodule

// Barrel Shifter: Arithmetic Right Shift
module sra64(
    input [63:0] rs1,   
    input [63:0] rs2,    
    output [63:0] result,
    output z_flag
);
    wire [5:0] shift_amt;  
    assign shift_amt = rs2[5:0];  
    
    wire [63:0] stage1, stage2, stage4, stage8, stage16, stage32; 
    wire msb = rs1[63];

    assign stage1 = shift_amt[0] ? {msb, rs1[63:1]} : rs1; // shift right by 0 or 1

    assign stage2 = shift_amt[1] ? {{2{msb}}, stage1[63:2]} : stage1; // shift right by 0 or 2

    assign stage4 = shift_amt[2] ? {{4{msb}}, stage2[63:4]} : stage2; // shift right by 0 or 4
    
    assign stage8 = shift_amt[3] ? {{8{msb}}, stage4[63:8]} : stage4; // shift right by 0 or 8

    assign stage16 = shift_amt[4] ? {{16{msb}}, stage8[63:16]} : stage8; // shift right by 0 or 16
    
    assign stage32 = shift_amt[5] ? {{32{msb}}, stage16[63:32]} : stage16; // shift right by 0 or 32
    
    assign result = stage32;  
    assign z_flag = (result == 64'b0);

endmodule

// SLT for ALU
module slt64(
    input [63:0] rs1,    // A
    input [63:0] rs2,    // B
    output [63:0] rd,
    output wire z_flag     
);
    wire [63:0] diff;
    wire less_than;      // N XOR V
    
    // rs1 - rs2
    sub64 subtractor(
        .a(rs1),
        .b(rs2),
        .diff(diff),
        .c_out(c_out),
        .v_flag(v_flag),
        .n_flag(n_flag),
        .z_flag(z_flag)
    );
    
    xor x1(less_than, n_flag, v_flag);
    assign rd = {63'b0, less_than};
    assign z_flag = (rd == 64'b0);

endmodule

// Set Less than Unsigned for ALU
// `include "sub64.v"
module sltu64(
    input [63:0] rs1,    // A
    input [63:0] rs2,    // B
    output [63:0] rd,    // output
    output wire z_flag   // zero flag
);
    wire [63:0] diff;
    wire less_than;
    
    // rs1 - rs2
    sub64 subtractor(
        .a(rs1),
        .b(rs2),
        .diff(diff),
        .c_out(c_out),
        .v_flag(v_flag),
        .n_flag(n_flag),
        .z_flag(z_flag)
    );
    
    // (UNSIGNED) rs1 < rs2 if there is no carry out
    // notC 
    xor x1(less_than, c_out, 1'b1);
    
    assign rd = {63'b0, less_than};
    assign z_flag = (rd == 64'b0);
    
endmodule

// 64-bit XOR Operation for ALU in RISC-V
module xor64(
    input[63:0] a,
    input[63:0] b,
    output[63:0] out,
    output z_flag
);
    genvar i;

    generate
        for(i = 0; i<64; i=i+1) begin
            xor a1(out[i], a[i], b[i]);
        end
    endgenerate

    assign z_flag = (out == 64'b0);

endmodule

// 64-bit OR Operation for ALU in RISC-V
module or64(
    input[63:0] a,
    input[63:0] b,
    output[63:0] out,
    output z_flag
);
    genvar i;

    generate
        for(i = 0; i<64; i=i+1) begin
            or a1(out[i], a[i], b[i]);
        end
    endgenerate

    assign z_flag = (out == 64'b0);
    
endmodule

// Wrapper ALU module
module alu(
    input signed [63:0] a,
    input signed [63:0] b,
    input [3:0] control,  
    output wire [63:0] result,
    output wire z_flag      // Zero flag
);

    wire [63:0] add_result, sub_result, and_result, or_result, xor_result;
    wire [63:0] slt_result, sltu_result, sra_result, srl_result, sll_result;
    
    // Flags from each operation
    wire add_cout, add_v, add_n, add_z;
    wire sub_cout, sub_v, sub_n, sub_z;
    wire and_z, or_z, xor_z;
    wire slt_z, sltu_z;
    wire sra_z, srl_z, sll_z, sll_v;

    reg [63:0] reg_result;
    reg reg_z_flag, reg_n_flag, reg_v_flag, reg_c_flag;

    assign result = reg_result;
    assign z_flag = reg_z_flag;
    assign n_flag = reg_n_flag;
    assign v_flag = reg_v_flag;
    assign c_flag = reg_c_flag;

    // Operation control codes
    localparam  AND  = 4'b0000,
                OR  = 4'b0001,
                ADD  = 4'b0010,
                SRL   = 4'b0011,
                XOR  = 4'b0100,
                SLL  = 4'b0101,
                SUB = 4'b0110,
                SRA  = 4'b0111,
                SLT  = 4'b1000,
                SLTU  = 4'b1001;

    // Instantiate all operation modules
    fa64 adder(
        .a(a),
        .b(b),
        .sum(add_result),
        .c_out(add_cout),
        .v_flag(add_v),
        .n_flag(add_n),
        .z_flag(add_z)
    );

    sub64 subtractor(
        .a(a),
        .b(b),
        .diff(sub_result),
        .c_out(sub_cout),
        .v_flag(sub_v),
        .n_flag(sub_n),
        .z_flag(sub_z)
    );

    and64 and_op(
        .a(a),
        .b(b),
        .out(and_result),
        .z_flag(and_z)
    );

    or64 or_op(
        .a(a),
        .b(b),
        .out(or_result),
        .z_flag(or_z)
    );

    xor64 xor_op(
        .a(a),
        .b(b),
        .out(xor_result),
        .z_flag(xor_z)
    );

    slt64 slt_op(
        .rs1(a),
        .rs2(b),
        .rd(slt_result),
        .z_flag(slt_z)
    );

    sltu64 sltu_op(
        .rs1(a),
        .rs2(b),
        .rd(sltu_result),
        .z_flag(sltu_z)
    );

    sra64 sra_op(
        .rs1(a),
        .rs2(b),
        .result(sra_result),
        .z_flag(sra_z)
    );

    srl64 srl_op(
        .rs1(a),
        .rs2(b),
        .result(srl_result),
        .z_flag(srl_z)
    );

    sll64 sll_op(
        .rs1(a),
        .rs2(b),
        .result(sll_result),
        .z_flag(sll_z),
        .v_flag(sll_v)
    );

    // Select result and set flags based on control signal
    always @(*) begin
        case(control)
            ADD: begin
                reg_result = add_result;
                reg_z_flag = add_z;
                reg_n_flag = add_n;
                reg_v_flag = add_v;
                reg_c_flag = add_cout;
            end
            SUB: begin
                reg_result = sub_result;
                reg_z_flag = sub_z;
                reg_n_flag = sub_n;
                reg_v_flag = sub_v;
                reg_c_flag = sub_cout;
            end
            AND: begin
                reg_result = and_result;
                reg_z_flag = and_z;
                reg_n_flag = and_result[63];
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
            OR: begin
                reg_result = or_result;
                reg_z_flag = or_z;
                reg_n_flag = or_result[63];
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
            XOR: begin
                reg_result = xor_result;
                reg_z_flag = xor_z;
                reg_n_flag = xor_result[63];
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
            SLT: begin
                reg_result = slt_result;
                reg_z_flag = slt_z;
                reg_n_flag = slt_result[63];
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
            SLTU: begin
                reg_result = sltu_result;
                reg_z_flag = sltu_z;
                reg_n_flag = sltu_result[63];
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
            SRA: begin
                reg_result = sra_result;
                reg_z_flag = sra_z;
                reg_n_flag = sra_result[63];
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
            SRL: begin
                reg_result = srl_result;
                reg_z_flag = srl_z;
                reg_n_flag = srl_result[63];
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
            SLL: begin
                reg_result = sll_result;
                reg_z_flag = sll_z;
                reg_n_flag = sll_result[63];
                reg_v_flag = sll_v;
                reg_c_flag = 1'b0;
            end
            default: begin
                reg_result = 64'h0;
                reg_z_flag = 1'b1;
                reg_n_flag = 1'b0;
                reg_v_flag = 1'b0;
                reg_c_flag = 1'b0;
            end
        endcase
    end

endmodule

module IF_ID(
    input wire clk,
    input wire reset,
    input wire flush,
    input wire IF_ID_write,
    input wire [63:0] IF_ID_pc_in,
    input wire [31:0] instr_in,
    output wire [63:0] IF_ID_pc_out,
    output wire [31:0] instr_out
);

    reg [31:0] temp;
    reg [63:0] pc_in_reg;
    
    // Outputs <= Reg
    assign instr_out = temp;
    assign pc_out = pc_in_reg;

    // Reg <= Next(input)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            temp <= 32'b0;
            pc_in_reg <= 64'b0;
        end
        else if (flush) begin
            temp <= 32'b0;
            pc_in_reg <= IF_ID_pc_in;
        end
        else if (IF_ID_write) begin
            temp <= instr_in;
            pc_in_reg <= IF_ID_pc_in;
        end
        else
            temp <= temp;
            pc_in_reg <= pc_in_reg;
    end

endmodule

module ID_EX(
    input wire clk,
    input wire reset,
    input wire mem_to_reg,        // WB
    input wire reg_write_en,
    input wire mem_read,          // MEM
    input wire mem_write,
    input wire branch,  
    input wire [3:0] alu_control, // EX
    input wire alu_src,
    input wire [63:0] ID_EX_pc_in, 
    input wire [63:0] data_in_1,
    input wire [63:0] data_in_2,
    input wire [63:0] imm_gen,
    input wire [4:0] ID_EX_rs1,
    input wire [4:0] ID_EX_rs2,
    input wire [4:0] ID_EX_rd,
    output wire mem_to_reg_out,
    output wire reg_write_en_out,
    output wire mem_read_out,
    output wire mem_write_out,
    output wire branch_out,
    output wire [3:0] alu_control_out,
    output wire alu_src_out,
    output wire [63:0] ID_EX_pc_out,
    output wire [63:0] read_data1,
    output wire [63:0] read_data2,
    output wire [63:0] imm_gen_out,
    output wire [4:0] ID_EX_rs1_out,
    output wire [4:0] ID_EX_rs2_out,
    output wire [4:0] ID_EX_rd_out
);
    // Registers (reg_input)
    reg [63:0] reg_data_in_1;
    reg [63:0] reg_data_in_2;
    reg [4:0] reg_ID_EX_rs1;
    reg [4:0] reg_ID_EX_rs2;
    reg [4:0] reg_ID_EX_rd;
    reg mem_read_reg;
    reg mem_to_reg_reg;
    reg reg_write_en_reg;
    reg [3:0] alu_control_reg;
    reg mem_write_reg;
    reg alu_src_reg;
    reg branch_reg;
    reg [63:0] imm_gen_reg;
    reg [63:0] ID_EX_pc_reg;

    // Outputs <= Reg
    assign read_data1 = reg_data_in_1;
    assign read_data2 = reg_data_in_2;
    assign ID_EX_rs1_out = reg_ID_EX_rs1;
    assign ID_EX_rs2_out = reg_ID_EX_rs2;
    assign ID_EX_rd_out = reg_ID_EX_rd;
    assign mem_read_out = mem_read_reg;
    assign mem_to_reg_out = mem_to_reg_reg;
    assign reg_write_en_out = reg_write_en_reg;
    assign alu_control_out = alu_control_reg;
    assign mem_write_out = mem_write_reg;
    assign alu_src_out = alu_src_reg;
    assign branch_out = branch_reg;
    assign imm_gen_out = imm_gen_reg;
    assign ID_EX_pc_out = ID_EX_pc_reg;

    // Reg <= Next
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_data_in_1 <= 64'b0;
            reg_data_in_2 <= 64'b0;
            reg_ID_EX_rs1 <= 5'b0;
            reg_ID_EX_rs2 <= 5'b0;
            reg_ID_EX_rd <= 5'b0;
            mem_read_reg <= 1'b0;
            mem_to_reg_reg <= 1'b0;
            reg_write_en_reg <= 1'b0;
            alu_control_reg <= 4'b0;
            mem_write_reg <= 1'b0;
            alu_src_reg <= 1'b0;
            branch_reg <= 1'b0;
            imm_gen_reg <= 64'b0;
            ID_EX_pc_reg <= 64'b0;
        end else begin
            reg_data_in_1 <= data_in_1;
            reg_data_in_2 <= data_in_2;
            reg_ID_EX_rs1 <= ID_EX_rs1;
            reg_ID_EX_rs2 <= ID_EX_rs2;
            reg_ID_EX_rd <= ID_EX_rd;
            mem_read_reg <= mem_read;
            mem_to_reg_reg <= mem_to_reg;
            reg_write_en_reg <= reg_write_en;
            alu_control_reg <= alu_control;
            mem_write_reg <= mem_write;
            alu_src_reg <= alu_src;
            branch_reg <= branch;
            imm_gen_reg <= imm_gen;
            ID_EX_pc_reg <= ID_EX_pc_in;
        end
    end

endmodule

module EX_MEM(
    input wire clk,
    input wire reset,
    input wire mem_to_reg,
    input wire reg_write_en,
    input wire mem_read,
    input wire mem_write,
    input wire branch,
    input wire [63:0] pc_next,  
    input wire z_flag,
    input wire [63:0] alu_out,
    input wire [63:0] data,
    input wire [4:0] rd,
    output wire mem_to_reg_out,
    output wire reg_write_en_out,
    output wire mem_read_out,
    output wire mem_write_out,
    output wire branch_out,
    output wire [63:0] pc_next_out,
    output wire z_flag_out,
    output wire [63:0] alu_out_out,
    output wire [63:0] data_out,
    output wire [4:0] rd_out
);
    // Registers (input_reg)
    reg [63:0] alu_out_reg;
    reg [63:0] data_reg;
    reg [4:0] rd_reg;
    reg mem_read_reg;
    reg mem_to_reg_reg;
    reg reg_write_en_reg;
    reg mem_write_reg;
    reg z_flag_reg;
    reg branch_reg;
    reg pc_next_reg;

    // Outputs <= Reg
    assign alu_out_out = alu_out_reg;
    assign data_out = data_reg;
    assign rd_out = rd_reg;
    assign mem_read_out = mem_read_reg;
    assign mem_to_reg_out = mem_to_reg_reg;
    assign reg_write_en_out = reg_write_en_reg;
    assign mem_write_out = mem_write_reg;
    assign z_flag_out = z_flag_reg;
    assign branch_out = branch_reg;
    assign pc_next_out = pc_next_reg;

    // Reg <= Next(input)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_out_reg <= 64'b0;
            data_reg <= 64'b0;
            rd_reg <= 5'b0;
            mem_read_reg <= 1'b0;
            mem_to_reg_reg <= 1'b0;
            reg_write_en_reg <= 1'b0;
            mem_write_reg <= 1'b0;
            z_flag_reg <= 1'b0;
            branch_reg <= 1'b0;
            pc_next_reg <= 64'b0;
        end else begin
            alu_out_reg <= alu_out;
            data_reg <= data;
            rd_reg <= rd;
            mem_read_reg <= mem_read;
            mem_to_reg_reg <= mem_to_reg;
            reg_write_en_reg <= reg_write_en;
            mem_write_reg <= mem_write;
            z_flag_reg <= z_flag;
            branch_reg <= branch;
            pc_next_reg <= pc_next;
        end
    end

endmodule

module MEM_WB(
    input wire clk,
    input wire reset,
    input wire mem_to_reg,
    input wire reg_write_en,
    input wire [63:0] data,
    input wire [63:0] alu_out,
    input wire [4:0] rd,
    output wire mem_to_reg_out,
    output wire reg_write_en_out,
    output wire [63:0] data_out,
    output wire [63:0] alu_out_out,
    output wire [4:0] rd_out
);

    reg [63:0] alu_out_reg;
    reg [63:0] data_reg;
    reg [4:0] rd_reg;
    reg mem_to_reg_reg;
    reg reg_write_en_reg;

    assign alu_out_out = alu_out_reg;
    assign data_out = data_reg;
    assign rd_out = rd_reg;
    assign mem_to_reg_out = mem_to_reg_reg;
    assign reg_write_en_out = reg_write_en_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_out_reg <= 64'b0;
            data_reg <= 64'b0;
            rd_reg <= 5'b0;
            mem_to_reg_reg <= 1'b0;
            reg_write_en_reg <= 1'b0;
        end else begin
            alu_out_reg <= alu_out;
            data_reg <= data;
            rd_reg <= rd;
            mem_to_reg_reg <= mem_to_reg;
            reg_write_en_reg <= reg_write_en;
        end
    end

endmodule

module forwarding_unit(
    input wire [4:0] ID_EX_rs1,          
    input wire [4:0] ID_EX_rs2,          
    input wire [4:0] EX_MEM_rd,          
    input wire EX_MEM_reg_write_en,         
    input wire [4:0] MEM_WB_rd,          
    input wire MEM_WB_reg_write_en,         
    output wire [1:0] ForwardA,           // forwarding control for first ALU operand
    output wire [1:0] ForwardB            // second ALU operand
);

    // ForwardX values, 00 = No forwarding (use ID/EX register, as it is)
    // 01 = Forward from MEM/WB stage
    // 10 = Forward from EX/MEM stage

    reg [1:0] ForwardA_reg, ForwardB_reg;

    always @(*) begin

        // Assume no forwarding
        ForwardA_reg = 2'b00;
        ForwardB_reg = 2'b00;
        
        // EX hazard for rs1 (ForwardA)
        if (EX_MEM_reg_write_en && 
            (EX_MEM_rd != 5'b0) &&
            (EX_MEM_rd == ID_EX_rs1)) begin
            ForwardA_reg = 2'b10;  
        end

        // MEM hazard for rs1 (ForwardA)
        else if (MEM_WB_reg_write_en && 
                 (MEM_WB_rd != 5'b0) &&
                 !(EX_MEM_reg_write_en && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs1)) && // give priority to EX/MEM stage
                 (MEM_WB_rd == ID_EX_rs1)) begin
            ForwardA_reg = 2'b01;  // from MEM/WB 
        end
        
        // EX hazard for rs2 (ForwardB)
        if (EX_MEM_reg_write_en && 
            (EX_MEM_rd != 5'b0) &&
            (EX_MEM_rd == ID_EX_rs2)) begin
            ForwardB_reg = 2'b10;  // from EX/MEM 
        end
        // MEM hazard for rs2 (ForwardB)
        else if (MEM_WB_reg_write_en && 
                 (MEM_WB_rd != 5'b0) &&
                 !(EX_MEM_reg_write_en && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs2)) && // give priority to EX/MEM stage
                 (MEM_WB_rd == ID_EX_rs2)) begin
            ForwardB_reg = 2'b01;  // from MEM/WB
        end
    end

    assign ForwardA = ForwardA_reg;
    assign ForwardB = ForwardB_reg;

endmodule

// #TODO : ld followed by stor and vice versa

module hazard_unit(
    input wire [4:0] IF_ID_rs1,        
    input wire [4:0] IF_ID_rs2,        
    input wire [4:0] ID_EX_rd,         
    input wire ID_EX_mem_read,         
    output wire pc_write,               
    output wire IF_ID_write,            
    output wire control_mux_sel         
);
    reg reg_pc_write, reg_IF_ID_write, reg_control_mux_sel;

    always @(*) begin
        // Assume no stall
        reg_pc_write = 1'b1;
        reg_IF_ID_write = 1'b1;
        reg_control_mux_sel = 1'b0;
        
        if (ID_EX_mem_read && 
            ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)) && 
            (ID_EX_rd != 5'b0)) begin
            
            // Stall 
            reg_pc_write = 1'b0;           // dont update PC
            reg_IF_ID_write = 1'b0;        // dont write to IF_ID
            reg_control_mux_sel = 1'b1;    // bubble daalo 
            // #TODO: Flush the pipeline 
        end
    end

    assign pc_write = reg_pc_write;
    assign IF_ID_write = reg_IF_ID_write;
    assign control_mux_sel = reg_control_mux_sel;

endmodule

module control_mux(
    input wire branch,
    input wire mem_read,
    input wire mem_to_reg,
    input wire [3:0] op,
    input wire mem_write,
    input wire alu_src,
    input wire reg_write_en,
    output wire branch_out,
    output wire mem_read_out,
    output wire mem_to_reg_out,
    output wire [3:0] op_out,
    output wire mem_write_out,
    output wire alu_src_out,
    output wire reg_write_en_out,
    input wire control_mux_sel
);

    wire [9:0] input_bus;
    wire [9:0] output_bus;

    assign input_bus[0] = branch;
    assign input_bus[1] = mem_read;
    assign input_bus[2] = mem_to_reg;
    assign input_bus[3] = op[0];
    assign input_bus[4] = op[1];
    assign input_bus[5] = op[2];
    assign input_bus[6] = op[3];
    assign input_bus[7] = mem_write;
    assign input_bus[8] = alu_src;
    assign input_bus[9] = reg_write_en;

    assign output_bus = control_mux_sel ? 10'b0 : input_bus;

    assign branch_out = output_bus[0];
    assign mem_read_out = output_bus[1];
    assign mem_to_reg_out = output_bus[2];
    assign op_out[0] = output_bus[3];
    assign op_out[1] = output_bus[4];
    assign op_out[2] = output_bus[5];
    assign op_out[3] = output_bus[6];
    assign mem_write_out = output_bus[7];
    assign alu_src_out = output_bus[8];
    assign reg_write_en_out = output_bus[9];

endmodule

module seq_processor (
    input wire clk,
    input wire reset
);

    // Declare internal wires
    // IF_ID.v
    wire flush;
    wire IF_ID_write;
    wire [31:0] instr;
    wire[63:0] IF_ID_pc_out;
    wire [31:0] instr_IF_ID; // goes to control, HDU, ID_EX, register_file, imm_gen

    // control.v, the control signals are all going into mux, apart from alu_op
    wire branch_in_mux;
    wire mem_read_in_mux;
    wire mem_to_reg_in_mux;
    wire [1:0] alu_op; // 2 bit control signal for ALU going into alu_control
    wire mem_write_in_mux;
    wire alu_src_in_mux;
    wire reg_write_en_in_mux;

    // alu_control.v
    wire [3:0] op_in_mux; // 4 bit control signal for ALU going into control_mux

    // control_mux.v, the inputs are from control, alu_control
    // the outputs are going into ID_EX
    wire branch_out_mux;
    wire mem_read_out_mux;
    wire mem_to_reg_out_mux;
    wire [3:0] op_out_mux;
    wire mem_write_out_mux;
    wire alu_src_out_mux;
    wire reg_write_en_out_mux;
    wire control_mux_sel;

    // register_file.v
    wire [63:0] write_data;
    wire reg_write_en_MEM_WB;
    wire [63:0] read_data1, read_data2; // goes to ID_EX

    // imm_gen.v
    wire [63:0] imm; // goes to ID_EX

    // ID_EX.v
    wire [63:0] ID_EX_pc_out;
    wire [63:0] read_data1_ID_EX, read_data2_ID_EX;
    wire [63:0] imm_ID_EX;
    wire [4:0] rs1_ID_EX, rs2_ID_EX, rd_ID_EX;
    wire mem_read_ID_EX, mem_to_reg_ID_EX, reg_write_en_ID_EX;
    wire [3:0] op_ID_EX;
    wire mem_write_ID_EX;
    wire alu_src_ID_EX;
    wire branch_ID_EX;
        
    // forwarding muxes (3x1)
    wire [1:0] forward_A, forward_B;
    wire [63:0] read_data1_mux;
    wire [63:0] alu_in_2;  // goes to EX_MEM

    // alu_src mux (2x1)
    wire [63:0] read_data2_mux; // selects between read_data2 and imm

    // ALU gets one input from 3x1 mux, the other from alu_src 2x1 mux
    wire [63:0] alu_out; // goes to EX_MEM
    wire z_flag;         // goes to EX_MEM

    // sl1.v
    wire [63:0] imm_shifted; // goes to CLA_N_Bit

    // CLA_N_Bit.v (pc+imm)
    wire [63:0] pc_next; // contains the pc+4 or pc+imm

    // forwarding_unit.v
    // the outputs are decalred in the section for 3x1 muxes

    // EX_MEM.v
    wire mem_read_EX_MEM, mem_write_EX_MEM, mem_to_reg_EX_MEM, reg_write_en_EX_MEM;
    wire [63:0] alu_out_EX_MEM, data_EX_MEM;
    wire [4:0] rd_EX_MEM;
    wire z_flag_EX_MEM;
    wire branch_EX_MEM;
    wire [63:0] pc_next_EX_MEM; // goes to mux that selects between pc+4 and pc+imm

    // and2.v
    // performs the AND operation between branch and z_flag

    // CLA_N_Bit.v (pc+4)
    wire tmp_carry;
    wire [63:0] mux_pc_1;

    // mux that selects between pc+4 and pc+imm
    wire pc_src;

    // PC
    wire [63:0] pc_in;
    wire [63:0] pc_out;

    // instruction_memory.v
    // the instr goes to IF_ID

    // data_memory.v
    wire [63:0] read_data; // goes to MEM_WB

    // MEM_WB.v
    wire mem_to_reg_MEM_WB;
    wire [63:0] alu_out_MEM_WB, data_MEM_WB;
    wire [4:0] rd_MEM_WB;
    
    wire branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write_en;
    wire tmp_carry_2;
    wire pc_write;
    
    // wire op_in_mux;
    
    // Instantiate Hardware
    // Register files  
    IF_ID if_id_inst(
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .IF_ID_write(IF_ID_write),
        .IF_ID_pc_in(pc_in),
        .instr_in(instr),
        .IF_ID_pc_out(IF_ID_pc_out),
        .instr_out(instr_IF_ID)
    );
    
    control control_inst(
        .op_code(instr_IF_ID[6:0]),
        .branch(branch_in_mux),
        .mem_read(mem_read_in_mux),
        .mem_to_reg(mem_to_reg_in_mux),
        .alu_op(alu_op),
        .mem_write(mem_write_in_mux),
        .alu_src(alu_src_in_mux),
        .reg_write_en(reg_write_en_in_mux)
    );

    alu_control alu_control_inst(
        .alu_op(alu_op),
        .instr_bits({instr_IF_ID[30], instr_IF_ID[14:12]}),
        .op(op_in_mux)
    );

    control_mux control_mux_inst(
        .branch(branch_in_mux),
        .mem_read(mem_read_in_mux),
        .mem_to_reg(mem_to_reg_in_mux),
        .op(op_in_mux),
        .mem_write(mem_write_in_mux),
        .alu_src(alu_src_in_mux),
        .reg_write_en(reg_write_en_in_mux),
        .branch_out(branch_out_mux),
        .mem_read_out(mem_read_out_mux),
        .mem_to_reg_out(mem_to_reg_out_mux),
        .op_out(op_out_mux),
        .mem_write_out(mem_write_out_mux),
        .alu_src_out(alu_src_out_mux),
        .reg_write_en_out(reg_write_en_out_mux),
        .control_mux_sel(control_mux_sel)
    );

    register_file register_file_inst(
        .clk(clk),
        .reset(reset),
        .read_reg1(instr_IF_ID[19:15]),  // rs1
        .read_reg2(instr_IF_ID[24:20]),  // rs2
        .write_reg(instr_IF_ID[11:7]),   // rd
        .write_data(write_data),
        .reg_write_en(reg_write_en_MEM_WB),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    imm_gen imm_gen_inst(
        .instr(instr_IF_ID),
        .imm(imm)
    );

    ID_EX id_ex_inst(
        .clk(clk),
        .reset(reset),
        .mem_to_reg(mem_to_reg_out_mux),
        .reg_write_en(reg_write_en_out_mux),
        .mem_read(mem_read_out_mux),
        .mem_write(mem_write_out_mux),
        .branch(branch_out_mux),
        .alu_control(op_out_mux),
        .alu_src(alu_src_out_mux),
        .ID_EX_pc_in(IF_ID_pc_out),
        .data_in_1(read_data1),
        .data_in_2(read_data2),
        .imm_gen(imm),
        .ID_EX_rs1(instr_IF_ID[19:15]),  // rs1
        .ID_EX_rs2(instr_IF_ID[24:20]),  // rs2
        .ID_EX_rd(instr_IF_ID[11:7]),    // rd
        .mem_to_reg_out(mem_to_reg_ID_EX),
        .reg_write_en_out(reg_write_en_ID_EX),
        .mem_read_out(mem_read_ID_EX),
        .mem_write_out(mem_write_ID_EX),
        .branch_out(branch_ID_EX),
        .alu_control_out(op_ID_EX),
        .alu_src_out(alu_src_ID_EX),
        .ID_EX_pc_out(ID_EX_pc_out),
        .read_data1(read_data1_ID_EX),
        .read_data2(read_data2_ID_EX),
        .imm_gen_out(imm_ID_EX),
        .ID_EX_rs1_out(rs1_ID_EX),
        .ID_EX_rs2_out(rs2_ID_EX),
        .ID_EX_rd_out(rd_ID_EX)
    );

    mux_4x1 alu_in_1_mux(
        .in0(read_data1_ID_EX),
        .in1(write_data),
        .in2(alu_out_EX_MEM),
        // .in3(read_data1_ID_EX),
        .s(forward_A), // 2 Bit Select line from the forwarding unit
        .y(read_data1_mux)
    );

    mux_4x1 alu_in_2_mux(
        .in0(read_data2_ID_EX),
        .in1(write_data),
        .in2(alu_out_EX_MEM),
        // .in3(read_data2_ID_EX),
        .s(forward_B), // 2 Bit Select line from the forwarding unit
        .y(alu_in_2)
    );

    mux_2x1 mux_reg_alu(
        .in1(alu_in_2),
        .in2(imm_ID_EX),
        .s0(alu_src_ID_EX),
        .y(read_data2_mux)
    );

    alu alu_inst(
        .a(read_data1_mux),
        .b(read_data2_mux),
        .control(op_ID_EX),
        .result(alu_out),
        .z_flag(z_flag)
    );

    sl1 sl1_inst(   
        .in(imm_ID_EX),
        .out(imm_shifted)
    );

    CLA_N_Bit add_addr_inst(
        .In1(imm_shifted),
        .In2(ID_EX_pc_out),
        .Cin(1'b0),
        .Sum(pc_next),
        .Carry(tmp_carry_2)
    );

    forwarding_unit forwarding_unit_inst(
        .ID_EX_rs1(rs1_ID_EX),
        .ID_EX_rs2(rs2_ID_EX),
        .EX_MEM_rd(rd_EX_MEM),
        .EX_MEM_reg_write_en(reg_write_en_EX_MEM),
        .MEM_WB_rd(rd_MEM_WB),
        .MEM_WB_reg_write_en(reg_write_en_MEM_WB),
        .ForwardA(forward_A),
        .ForwardB(forward_B)
    );

    EX_MEM ex_mem_inst(
        .clk(clk),
        .reset(reset),
        .mem_to_reg(mem_to_reg_ID_EX),
        .reg_write_en(reg_write_en_ID_EX),
        .mem_read(mem_read_ID_EX),
        .mem_write(mem_write_ID_EX),
        .branch(branch_ID_EX),
        .pc_next(pc_next),
        .z_flag(z_flag),
        .alu_out(alu_out),
        .data(alu_in_2), 
        .rd(rd_ID_EX),
        .mem_to_reg_out(mem_to_reg_EX_MEM),
        .reg_write_en_out(reg_write_en_EX_MEM),
        .mem_read_out(mem_read_EX_MEM),
        .mem_write_out(mem_write_EX_MEM),
        .branch_out(branch_EX_MEM),
        .pc_next_out(pc_next_EX_MEM),
        .z_flag_out(z_flag_EX_MEM),
        .alu_out_out(alu_out_EX_MEM),
        .data_out(data_EX_MEM),
        .rd_out(rd_EX_MEM)
    );

    and2 and_inst(
        .in1(branch_EX_MEM),   // both inputs come from EX_MEM
        .in2(z_flag_EX_MEM),
        .out(pc_src)
    );

    CLA_N_Bit add_pc_inst(
        .In1(64'h0000000000000004),
        .In2(pc_out),
        .Cin(1'b0),
        .Sum(mux_pc_1),
        .Carry(tmp_carry)
    );
    // The mux that selects between the pc+4 and pc+imm
    mux_2x1 mux_pc(
        .in1(mux_pc_1),        // comes from pc+4
        .in2(pc_next_EX_MEM),  // comes from EX_MEM
        .s0(pc_src),           // comes from the AND gate
        .y(pc_in)
    );

    pc pc_inst(
        .clk(clk),
        .reset(reset), 
        .pc_in(pc_in), 
        .pc_out(pc_out)
    );

    instruction_memory instruction_mem_inst(
        .clk(clk),
        .reset(reset),
        .addr(pc_out),
        .instr(instr)
    );

    data_memory data_memory_inst(
        .clk(clk),
        .reset(reset),
        .addr(alu_out_EX_MEM[9:0]), // Fix to 64-bit line
        .write_data(data_EX_MEM),
        .mem_write(mem_write_EX_MEM),
        .mem_read(mem_read_EX_MEM),
        .read_data(read_data)
    );

    MEM_WB mem_wb_inst(
        .clk(clk),
        .reset(reset),
        .mem_to_reg(mem_to_reg_EX_MEM),
        .reg_write_en(reg_write_en_EX_MEM),
        .data(read_data),   // comes from data_memory
        .alu_out(alu_out_EX_MEM),
        .rd(rd_EX_MEM),
        .mem_to_reg_out(mem_to_reg_MEM_WB),
        .reg_write_en_out(reg_write_en_MEM_WB),
        .data_out(data_MEM_WB),
        .alu_out_out(alu_out_MEM_WB),
        .rd_out(rd_MEM_WB)
    );

    hazard_unit hazard_unit_inst(
        .IF_ID_rs1(instr_IF_ID[19:15]),     
        .IF_ID_rs2(instr_IF_ID[24:20]),     
        .ID_EX_rd(rd_ID_EX),               
        .ID_EX_mem_read(mem_read_ID_EX),    
        .pc_write(pc_write),         
        .IF_ID_write(IF_ID_write),    
        .control_mux_sel(control_mux_sel) 
    );

    // Mux for write back stage
    mux_2x1 mux_mem(
        .in1(alu_out_MEM_WB),
        .in2(data_MEM_WB),
        .s0(mem_to_reg_MEM_WB),
        .y(write_data)
    );
    
endmodule