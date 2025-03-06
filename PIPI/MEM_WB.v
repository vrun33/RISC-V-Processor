// Registers which hold 2 64 data line, 5 bit rd value, 2 control signals

module MEM_WB(
    input wire clk,
    input wire reset,
    input wire mem_to_reg,
    input wire reg_write_en,
    input wire [63:0] data,
    input wire [63:0] alu_out,
    input wire [4:0] rd,
    output wire [63:0] alu_out_out,
    output wire [63:0] data_out,
    output wire [4:0] rd_out,
    output wire mem_to_reg_out,
    output wire reg_write_en_out
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