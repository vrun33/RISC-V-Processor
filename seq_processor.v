// // Wrapper conencting all the blocks

// `include "pc.v"
// `include "instruction_mem.v"
// `include "control.v"
// `include "imm_gen.v"
// `include "register_file.v"
// `include "data_memory.v"
// `include "MUX_2x1.v"
// `include "CLA_64_BIT.v"
// `include "and2.v"
// `include "sl1.v"
// `include "alu.v"

// module seq_processor (
//     input wire clk,
//     input wire reset
// );

//     // Instantiate Hardware
//     initial
//     begin
//         pc pc_inst( .clk(clk),
//                     .reset(reset), 
//                     .pc_in(pc_in), 
//                     .pc_out(pc_out) );

//         instruction_memory instruction_mem_inst(clk, reset, pc_out, instr);
//         control control_inst(instr[0:6], branch, mem_read, mem_to_reg, alu_op, mem_write, alu_src, reg_write_en);
//         register_file register_file_inst(clk, reset, instr[19:15], instr[24:20], instr[11:7], write_data, reg_write_en, read_data1, read_data2);
//         imm_gen imm_gen_inst(instr, imm);
//         data_memory data_memory_inst(clk, reset, alu_out, read_data2, mem_read, mem_write, read_data);
//         alu_control alu_control_inst(alu_op, {instr[30], instr[14:12]}, op);
//         CLA_N_Bit add_pc_inst(64'h0000000000000004, pc_out, 64'h0000000000000000, mux_pc_2);
//         sl1 sl1_inst(imm, imm_shifted);
//         CLA_N_Bit add_addr_inst(imm_shifted, pc_out, 64'h0000000000000000, mux_pc_1);
//         mux_2x1 mux_pc(mux_pc_1, mux_pc_2, and_out, pc_in);
//         and2 and_inst(branch, z_flag, and_out);
//         mux_2x1 mux_mem(alu_out, read_data, mem_to_reg, write_data);
//         mux_2x1 mux_reg_alu(read_data2, imm, alu_src, alu_in_2);
//         alu alu_inst(read_data1, alu_in_2, op, alu_out, z_flag);
//     end

// endmodule

// Wrapper connecting all the blocks

`include "pc.v"
`include "instruction_mem.v"
`include "control.v"
`include "imm_gen.v"
`include "register_file.v"
`include "data_memory.v"
`include "MUX_2x1.v"
`include "CLA_64_BIT.v"
`include "and2.v"
`include "sl1.v"
`include "alu.v"

module seq_processor (
    input wire clk,
    input wire reset
);

    // Declare internal wires
    wire [63:0] pc_in;
    wire [63:0] pc_out;
    wire [31:0] instr;
    wire branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write_en;
    wire [1:0] alu_op;
    wire [63:0] read_data1, read_data2, write_data;
    wire [63:0] imm;
    wire [63:0] read_data;
    wire [3:0] op;
    wire [63:0] mux_pc_1, mux_pc_2;
    wire [63:0] imm_shifted;
    wire and_out;
    wire [63:0] alu_in_2;
    wire [63:0] alu_out;
    wire z_flag;

    // Instantiate Hardware
    pc pc_inst(
        .clk(clk),
        .reset(reset), 
        .pc_in(pc_in), 
        .pc_out(pc_out)
    );

    instruction_memory instruction_mem_inst(
        .clk(clk),
        .reset(reset),
        .pc(pc_out),
        .instruction(instr)
    );

    control control_inst(
        .opcode(instr[6:0]),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write_en)
    );

    register_file register_file_inst(
        .clk(clk),
        .reset(reset),
        .rs1(instr[19:15]),
        .rs2(instr[24:20]),
        .rd(instr[11:7]),
        .write_data(write_data),
        .reg_write_en(reg_write_en),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    imm_gen imm_gen_inst(
        .instruction(instr),
        .immediate(imm)
    );

    data_memory data_memory_inst(
        .clk(clk),
        .reset(reset),
        .address(alu_out),
        .write_data(read_data2),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(read_data)
    );

    alu_control alu_control_inst(
        .alu_op(alu_op),
        .funct({instr[30], instr[14:12]}),
        .operation(op)
    );

    CLA_N_Bit add_pc_inst(
        .A(64'h0000000000000004),
        .B(pc_out),
        .Cin(64'h0000000000000000),
        .Sum(mux_pc_2)
    );

    sl1 sl1_inst(
        .in(imm),
        .out(imm_shifted)
    );

    CLA_N_Bit add_addr_inst(
        .A(imm_shifted),
        .B(pc_out),
        .Cin(64'h0000000000000000),
        .Sum(mux_pc_1)
    );

    mux_2x1 mux_pc(
        .in1(mux_pc_1),
        .in2(mux_pc_2),
        .sel(and_out),
        .out(pc_in)
    );

    and2 and_inst(
        .in1(branch),
        .in2(z_flag),
        .out(and_out)
    );

    mux_2x1 mux_mem(
        .in1(alu_out),
        .in2(read_data),
        .sel(mem_to_reg),
        .out(write_data)
    );

    mux_2x1 mux_reg_alu(
        .in1(read_data2),
        .in2(imm),
        .sel(alu_src),
        .out(alu_in_2)
    );

    alu alu_inst(
        .in1(read_data1),
        .in2(alu_in_2),
        .op(op),
        .out(alu_out),
        .zero(z_flag)
    );

endmodule