// Register file with multiple inputs and outputs
// Inputs include 2 64 bit data lines, 3 5 bit register address lines, 6 Control signals and a 4 bit alu control


module ID_EX(
    input wire clk,
    input wire reset,
    input wire flush,
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
        end 
        else if(flush) begin
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
        end  
        else begin
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