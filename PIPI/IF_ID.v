// IF/ID reg file which takes 32 bit instruction input, has a flush flag and write flag

module IF_ID(
    input wire clk,
    input wire reset,
    input wire flush,
    input wire IF_ID_write,
    input wire [31:0] instr_in,
    output wire [31:0] instr_out
);

    reg [31:0] temp;
    assign instr_out = temp;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            temp <= 32'b0;
        end
        else if (flush) begin
            temp <= 32'b0;
        end
        else if (IF_ID_write) begin
            temp <= instr;
        end
        else
            temp <= temp;
    end

endmodule