// Wrapper connecting all the blocks

`include "pc.v"
`include "instruction_mem.v"
`include "control.v"
`include "alu_control.v"
`include "imm_gen.v"
`include "register_file.v"
`include "data_memory.v"
`include "MUX_2x1.v"
`include "CLA_64_BIT.v"
`include "CLA4BIT.v"
`include "and2.v"
`include "sl1.v"
`include "alu.v"
`include "IF_ID.v"
`include "ID_EX.v"
`include "EX_MEM.v"
`include "MEM_WB.v"
`include "forwarding_unit.v"
`include "hazard_unit.v"

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
    wire tmp_carry;
    wire tmp_carry_2;
    wire flush;
    wire IF_ID_write;
    wire [31:0] instr_IF_ID;

    // Instantiate Hardware
    // Register files  
    IF_ID if_id_inst(
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .write(IF_ID_write),
        .instr_in(instr),
        .instr_out(instr_IF_ID)
    );

    ID_EX id_ex_inst(
        .clk(clk),
        .reset(reset),
        .data_in_1(read_data1),
        .data_in_2(read_data2),
        .ID_EX_rs1(instr_IF_ID[19:15]),
        .ID_EX_rs2(instr_IF_ID[24:20]),
        .ID_EX_rd(instr_IF_ID[11:7]),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .reg_write_en(reg_write_en),
        .alu_control(op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .branch(branch),
        .imm_gen(imm),
        .read_data1(read_data1_ID_EX),
        .read_data2(read_data2_ID_EX),
        .mem_read_out(mem_read_ID_EX),
        .mem_to_reg_out(mem_to_reg_ID_EX),
        .reg_write_en_out(reg_write_en_ID_EX),
        .alu_control_out(op_ID_EX),
        .mem_write_out(mem_write_ID_EX),
        .alu_src_out(alu_src_ID_EX),
        .imm_gen_out(imm_ID_EX),
        .ID_EX_rs1_out(rs1_ID_EX),
        .ID_EX_rs2_out(rs2_ID_EX),
        .ID_EX_rd_out(rd_ID_EX),
        .branch_out(branch_ID_EX)
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

    control control_inst(
        .op_code(instr_IF_ID[6:0]),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write_en(reg_write_en)
    );

    register_file register_file_inst(
        .clk(clk),
        .reset(reset),
        .read_reg1(instr_IF_ID[19:15]),
        .read_reg2(instr_IF_ID[24:20]),
        .write_reg(instr_IF_ID[11:7]),
        .write_data(write_data), // Fix it later
        .reg_write_en(reg_write_en), // Fix it later
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    imm_gen imm_gen_inst(
        .instr(instr_IF_ID),
        .imm(imm)
    );

    data_memory data_memory_inst(
        .clk(clk),
        .reset(reset),
        .addr(alu_out[9:0]),
        .write_data(read_data2),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .read_data(read_data)
    );

    alu_control alu_control_inst(
        .alu_op(alu_op),
        .instr_bits({instr_IF_ID[30], instr_IF_ID[14:12]}),
        .op(op)
    );

    CLA_N_Bit add_pc_inst(
        .In1(64'h0000000000000004),
        .In2(pc_out),
        .Cin(1'b0),
        .Sum(mux_pc_1),
        .Carry(tmp_carry)
    );

    sl1 sl1_inst(
        .in(imm),
        .out(imm_shifted)
    );

    CLA_N_Bit add_addr_inst(
        .In1(imm_shifted),
        .In2(pc_out),
        .Cin(1'b0),
        .Sum(mux_pc_2),
        .Carry(tmp_carry_2)
    );

    mux_2x1 mux_pc(
        .in1(mux_pc_1),
        .in2(mux_pc_2),
        .s0(and_out),
        .y(pc_in)
    );

    and2 and_inst(
        .in1(branch_ID_EX),
        .in2(z_flag),
        .out(and_out)
    );

    mux_2x1 mux_mem(
        .in1(alu_out), // Fix it later
        .in2(read_data), // Fix it later
        .s0(mem_to_reg), // Fix it later
        .y(write_data)
    );

    mux_2x1 mux_reg_alu(
        .in1(read_data2_ID_EX),
        .in2(imm_ID_EX),
        .s0(alu_src_ID_EX),
        .y(alu_in_2)
    );

    alu alu_inst(
        .a(read_data1_ID_EX),
        .b(alu_in_2),
        .control(op_ID_EX),
        .result(alu_out),
        .z_flag(z_flag)
    );

endmodule