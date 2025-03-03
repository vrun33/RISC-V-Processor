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
    wire instr_reg_file;

    // Instantiate Hardware
    // Register files - Output variables have the reg_file suffix    
    IF_ID if_id_inst(
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .write(IF_ID_write),
        .instr_in(instr),
        .instr_out(instr_reg_file)
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
        .op_code(instr[6:0]),
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
        .read_reg1(instr[19:15]),
        .read_reg2(instr[24:20]),
        .write_reg(instr[11:7]),
        .write_data(write_data),
        .reg_write_en(reg_write_en),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    imm_gen imm_gen_inst(
        .instr(instr),
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
        .instr_bits({instr[30], instr[14:12]}),
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
        .in1(branch),
        .in2(z_flag),
        .out(and_out)
    );

    mux_2x1 mux_mem(
        .in1(alu_out),
        .in2(read_data),
        .s0(mem_to_reg),
        .y(write_data)
    );

    mux_2x1 mux_reg_alu(
        .in1(read_data2),
        .in2(imm),
        .s0(alu_src),
        .y(alu_in_2)
    );

    alu alu_inst(
        .a(read_data1),
        .b(alu_in_2),
        .control(op),
        .result(alu_out),
        .z_flag(z_flag)
    );

endmodule