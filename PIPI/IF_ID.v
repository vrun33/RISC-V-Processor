// IF/ID reg file which takes 32 bit instruction input, has a flush flag and write flag

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
    assign IF_ID_pc_out = pc_in_reg;

    // Reg <= Next(input)
    always @(posedge clk or posedge reset or flush) begin
        if (reset) begin
            temp <= 32'b0;
            pc_in_reg <= 64'b0;
        end
        else if (flush) begin
            temp <= 32'b0;
            pc_in_reg <= pc_in_reg;
        end
        else if (IF_ID_write) begin
            temp <= instr_in;
            pc_in_reg <= IF_ID_pc_in;
        end
        else begin
            temp <= temp;
            pc_in_reg <= pc_in_reg;
        end
    end

endmodule