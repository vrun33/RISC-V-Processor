`timescale 1ns / 1ps

module Control(
    input [7:0] op_code,
    output branch,
    output mem_read,
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_write,
    output alu_src,
    output reg_write_en
    );

    // R-Type OpCode - 0110011
    // I-Type OpCode - 0010011
    // S-Type OpCode - 0100011
    // B-Type OpCode - 1100011
    // J-Type OpCode - 1101111

    localparam R_type = 7'b0110011;
    localparam I_op_type = 7'b0010011;
    localparam I_load_type = 7'b0000011;
    localparam S_type = 7'b0100011;
    localparam B_type = 7'b1100011;
    localparam J_type = 7'b1101111;

    always @(*) begin
        case(op_code)
            R_type: begin
                branch = 1'b0;
                mem_read = 1'b0;
                mem_to_reg = 1'b0;
                alu_op = 2'b10;
                mem_write = 1'b0;
                alu_src = 1'b0;
                reg_write_en = 1'b1;
            end
            I_op_type: begin
                branch = 1'b0;
                mem_read = 1'b0;
                mem_to_reg = 1'b0;
                alu_op = 2'b10;
                mem_write = 1'b0;
                alu_src = 1'b1;
                reg_write_en = 1'b1;
            end
            I_load_type: begin
                branch = 1'b0;
                mem_read = 1'b1;
                mem_to_reg = 1'b1;
                alu_op = 2'b00;
                mem_write = 1'b0;
                alu_src = 1'b1;
                reg_write_en = 1'b1;
            end
            S_type: begin
                branch = 1'b0;
                mem_read = 1'b0;
                mem_to_reg = 1'b0;
                alu_op = 2'b00;
                mem_write = 1'b1;
                alu_src = 1'b1;
                reg_write = 1'b0;
            end
            B_type: begin
                branch = 1'b1;
                mem_read = 1'b0;
                mem_to_reg = 1'b0;
                alu_op = 2'b01;
                mem_write = 1'b0;
                alu_src = 1'b0;
                reg_write = 1'b0;
            end
            J_type: begin
                branch = 1'b1;
                mem_read = 1'b0;
                mem_to_reg = 1'b0;
                alu_op = 2'b00;
                mem_write = 1'b0;
                alu_src = 1'b0;
                reg_write = 1'b0;
            end
            default: begin
                branch = 1'b0;
                mem_read = 1'b0;
                mem_to_reg = 1'b0;
                alu_op = 2'b00;
                mem_write = 1'b0;
                alu_src = 1'b0;
                reg_write = 1'b0;
            end
        endcase
    end

endmodule