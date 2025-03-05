// Pipelined Wrapper connecting all the blocks

`include "pc.v"
`include "instruction_mem.v"
`include "control.v"
`include "alu_control.v"
`include "imm_gen.v"
`include "register_file.v"
`include "data_memory.v"
`include "MUX4x1.v"
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
`include "control_mux.v"

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
    wire [3:0] op_in_mux;
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
    wire [63:0] read_data1_ID_EX, read_data2_ID_EX;
    wire [63:0] imm_ID_EX;
    wire [4:0] rs1_ID_EX, rs2_ID_EX, rd_ID_EX;
    wire mem_read_ID_EX, mem_to_reg_ID_EX, reg_write_en_ID_EX;
    wire [3:0] op_ID_EX;
    wire mem_write_ID_EX;
    wire alu_src_ID_EX;
    wire branch_ID_EX;
    wire [63:0] alu_out_EX_MEM, data_EX_MEM;
    wire [4:0] rd_EX_MEM;
    wire mem_read_EX_MEM, mem_write_EX_MEM, mem_to_reg_EX_MEM, reg_write_en_EX_MEM;
    wire z_flag_EX_MEM;
    wire [63:0] alu_out_MEM_WB, data_MEM_WB;
    wire [4:0] rd_MEM_WB;
    wire mem_to_reg_MEM_WB, reg_write_en_MEM_WB;
    wire [63:0] read_data1_mux;
    wire [63:0] read_data2_mux;
    wire forward_A, forward_B;
    wire pc_write;
    wire control_mux_sel;
    wire branch_in_mux;
    wire mem_read_in_mux;
    wire mem_to_reg_in_mux;
    wire op_in_mux;
    wire mem_write_in_mux;
    wire alu_src_in_mux;
    wire reg_write_en_in_mux;
    wire branch_out_mux;
    wire mem_read_out_mux;
    wire mem_to_reg_out_mux;
    wire op_out_mux;
    wire mem_write_out_mux;
    wire alu_src_out_mux;
    wire reg_write_en_out_mux;

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
        .branch(branch_out_mux),
        .mem_read(mem_read_out_mux),
        .mem_to_reg(mem_to_reg_out_mux),
        .alu_control(op_out_mux),
        .mem_write(mem_write_out_mux),
        .alu_src(alu_src_out_mux),
        .reg_write_en(reg_write_en_out_mux),
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

    EX_MEM ex_mem_inst(
        .clk(clk),
        .reset(reset),
        .alu_out(alu_out),
        .data(alu_in_2), 
        .rd(rd_ID_EX),
        .mem_read(mem_read_ID_EX),
        .mem_write(mem_write_ID_EX),
        .mem_to_reg(mem_to_reg_ID_EX),
        .reg_write_en(reg_write_en_ID_EX),
        .z_flag(z_flag),
        .alu_out_out(alu_out_EX_MEM),
        .data_out(data_EX_MEM),
        .rd_out(rd_EX_MEM),
        .mem_read_out(mem_read_EX_MEM),
        .mem_write_out(mem_write_EX_MEM),
        .mem_to_reg_out(mem_to_reg_EX_MEM),
        .reg_write_en_out(reg_write_en_EX_MEM),
        .z_flag_out(z_flag_EX_MEM)
    );

    MEM_WB mem_wb_inst(
        .clk(clk),
        .reset(reset),
        .data(read_data),
        .alu_out(alu_out_EX_MEM),
        .rd(rd_EX_MEM),
        .mem_to_reg(mem_to_reg_EX_MEM),
        .reg_write_en(reg_write_en_EX_MEM),
        .alu_out_out(alu_out_MEM_WB),
        .data_out(data_MEM_WB),
        .rd_out(rd_MEM_WB),
        .mem_to_reg_out(mem_to_reg_MEM_WB),
        .reg_write_en_out(reg_write_en_MEM_WB)
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

    // control control_inst(
    //     .op_code(instr_IF_ID[6:0]),
    //     .branch(branch_in_mux),
    //     .mem_read(mem_read_in_mux),
    //     .mem_to_reg(mem_to_reg_in
    //     .alu_op(alu_op),
    //     .mem_write(mem_write),
    //     .alu_src(alu_src),
    //     .reg_write_en(reg_write_en)
    // );

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

    register_file register_file_inst(
        .clk(clk),
        .reset(reset),
        .read_reg1(instr_IF_ID[19:15]),
        .read_reg2(instr_IF_ID[24:20]),
        .write_reg(instr_IF_ID[11:7]),
        .write_data(write_data),
        .reg_write_en(reg_write_en_MEM_WB),
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
        .addr(alu_out_EX_MEM[9:0]), // Fix to 64-bit line
        .write_data(data_EX_MEM),
        .mem_write(mem_write_EX_MEM),
        .mem_read(mem_read_EX_MEM),
        .read_data(read_data)
    );

    alu_control alu_control_inst(
        .alu_op(alu_op),
        .instr_bits({instr_IF_ID[30], instr_IF_ID[14:12]}),
        .op(op_in_mux)
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
        .in2(z_flag_EX_MEM),
        .out(and_out)
    );

    mux_2x1 mux_mem(
        .in1(alu_out_MEM_WB),
        .in2(data_MEM_WB),
        .s0(mem_to_reg_MEM_WB),
        .y(write_data)
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

    hazard_unit hazard_unit_inst(
        .IF_ID_rs1(instr_IF_ID[19:15]),     
        .IF_ID_rs2(instr_IF_ID[24:20]),     
        .ID_EX_rd(rd_ID_EX),               
        .ID_EX_mem_read(mem_read_ID_EX),    
        .pc_write(pc_write),         
        .IF_ID_write(IF_ID_write),    
        .control_mux_sel(control_mux_sel) 
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
    
endmodule