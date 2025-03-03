// Registers with inputs aas a 64 bit alu out, 64 bit data line, 5 bit rd value, and 5 control signals

module EX_MEM(
    input wire clk,
    input wire reset,
    input wire [63:0] alu_out,
    input wire [63:0] data,
    input wire [4:0] rd,
    input wire mem_read,
    input wire mem_write,
    input wire mem_to_reg,
    input wire reg_write_en,
    input wire z_flag,
    output wire [63:0] alu_out_out,
    output wire [63:0] data_out,
    output wire [4:0] rd_out,
    output wire mem_read_out,
    output wire mem_to_reg_out,
    output wire reg_write_en_out,
    output wire mem_write_out,
    output wire z_flag_out
);

    reg [63:0] alu_out_out;
    reg [63:0] data_out;
    reg [4:0] rd_out;
    reg mem_read_out;
    reg mem_to_reg_out;
    reg reg_write_en_out;
    reg mem_write_out;
    reg z_flag_out;

    assign alu_out_out = alu_out;
    assign data_out = data;
    assign rd_out = rd;
    assign mem_read_out = mem_read;
    assign mem_to_reg_out = mem_to_reg;
    assign reg_write_en_out = reg_write_en;
    assign mem_write_out = mem_write;
    assign z_flag_out = z_flag;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_out_out <= 64'b0;
            data_out <= 64'b0;
            rd_out <= 5'b0;
            mem_read_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            reg_write_en_out <= 1'b0;
            mem_write_out <= 1'b0;
            z_flag_out <= 1'b0;
        end else begin
            alu_out_out <= alu_out;
            data_out <= data;
            rd_out <= rd;
            mem_read_out <= mem_read;
            mem_to_reg_out <= mem_to_reg;
            reg_write_en_out <= reg_write_en;
            mem_write_out <= mem_write;
            z_flag_out <= z_flag;
        end
    end

endmodule