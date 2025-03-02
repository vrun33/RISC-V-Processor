module imm_gen(
    input wire [31:0] instr,
    output reg [63:0] imm
);

    localparam I_op_type = 7'b0010011;
    localparam I_load_type = 7'b0000011;
    localparam S_type = 7'b0100011;
    localparam B_type = 7'b1100011;

    wire [6:0] opcode;
    assign opcode = instr[6:0];

    always @(*) begin
        case(opcode)
            I_op_type, I_load_type: begin
                imm = {{52{instr[31]}}, instr[31:20]};
            end

            S_type: begin
                imm = {{52{instr[31]}}, instr[31:25], instr[11:7]};
            end

            B_type: begin
                imm = {{51{instr[31]}}, instr[31], instr[7], 
                            instr[30:25], instr[11:8], 1'b0};
            end

            default: begin
                imm = 64'b0;
            end
        endcase
    end

endmodule