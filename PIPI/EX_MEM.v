// Registers with inputs aas a 64 bit alu out, 64 bit data line, 5 bit rd value, and 5 control signals
// Only the alu_out is an expcetion to the naming of inputs(since it contains the output of the ALU)
// The actual output is alu_out_out

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
    input wire [4:0] rs2_ID_EX,
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
    output wire [4:0] rs2_ID_EX_out,
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
    reg [63:0] pc_next_reg;
    reg [4:0] rs2_ID_EX_reg;

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
    assign rs2_ID_EX_out = rs2_ID_EX_reg;

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
            rs2_ID_EX_reg <= 5'b0;
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
            rs2_ID_EX_reg <= rs2_ID_EX;
        end
    end

endmodule