// Pipelined Wrapper connecting all the blocks

`include "pc.v"
`include "instruction_mem.v"
`include "control.v"
`include "alu_control.v"
`include "imm_gen.v"
`include "register_file.v"
`include "data_memory.v"
`include "MUX_4x1.v"
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
`include "ld_sd_forwarding_unit.v"

module pipelined_processor (
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
    wire [4:0] rs2_EX_MEM;
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
    
    // ld_sd_forwarding_unit.v
    wire ld_sd_sel;

    // mux_ld_sd
    wire [63:0] data_mem_in;

    // Instantiate Hardware
    // Register files  
    IF_ID if_id_inst(
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .IF_ID_write(IF_ID_write),
        .IF_ID_pc_in(pc_out),
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
        .write_reg(rd_MEM_WB),   // rd
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
        .in3(read_data1_ID_EX),
        .s(forward_A), // 2 Bit Select line from the forwarding unit
        .y(read_data1_mux)
    );

    mux_4x1 alu_in_2_mux(
        .in0(read_data2_ID_EX),
        .in1(write_data),
        .in2(alu_out_EX_MEM),
        .in3(read_data2_ID_EX),
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

    // pc+imm
    CLA_N_Bit add_pc_imm_inst(
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
        .rs2_ID_EX(rs2_ID_EX),
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
        .rs2_ID_EX_out(rs2_EX_MEM),
        .rd_out(rd_EX_MEM)
    );

    and2 and_inst(
        .in1(branch_EX_MEM),   // both inputs come from EX_MEM
        .in2(z_flag_EX_MEM),
        .out(pc_src)
    );

    // pc+4
    CLA_N_Bit add_pc_next_inst(
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
        .pc_write(pc_write),
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
        .write_data(data_mem_in),
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

    // wire [4:0] rs1_IF_ID;
    // wire [4:0] rs2_IF_ID;
    // wire [4:0] rd_IF_ID;

    // assign rs1_IF_ID = instr_IF_ID[19:15];
    // assign rs2_IF_ID = instr_IF_ID[24:20];
    // assign rd_IF_ID = instr_IF_ID[11:7];

    hazard_unit hazard_unit_inst(
        .IF_ID_rs1(instr_IF_ID[19:15]),     
        .IF_ID_rs2(instr_IF_ID[24:20]),     
        .ID_EX_rd(rd_ID_EX),               
        .ID_EX_mem_read(mem_read_ID_EX),  
        .ld_sd_mem_write(mem_write_in_mux),   
        .ld_sd_mem_read(mem_read_in_mux), 
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
    
    // ld_sd_forwarding_unit
    ld_sd_forward ld_sd_forwarding_unit_inst(
        .ld_rd(rd_MEM_WB),
        .sd_rs2_data(rs2_EX_MEM),
        .ld_sd_mem_to_reg(mem_to_reg_MEM_WB),
        .ld_sd_mem_write(mem_write_EX_MEM),
        .ld_sd_sel(ld_sd_sel)
    );

    mux_2x1 mux_ld_sd(
        .in1(data_EX_MEM),
        .in2(data_MEM_WB),
        .s0(ld_sd_sel),
        .y(data_mem_in)
    );
endmodule