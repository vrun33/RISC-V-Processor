// Control Block 

module control(
    input wire [6:0] op_code,
    output wire branch,
    output wire mem_read,
    output wire mem_to_reg,
    output wire [1:0] alu_op,
    output wire mem_write,
    output wire alu_src,
    output wire reg_write_en
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
    // localparam J_type = 7'b1101111;

    reg branch_reg, mem_read_reg, mem_to_reg_reg, mem_write_reg, alu_src_reg, reg_write_en_reg;
    reg [1:0] alu_op_reg;

    assign branch = branch_reg;
    assign mem_read = mem_read_reg;
    assign mem_to_reg = mem_to_reg_reg;
    assign alu_op = alu_op_reg;
    assign mem_write = mem_write_reg;
    assign alu_src = alu_src_reg;
    assign reg_write_en = reg_write_en_reg;

    always @(*) begin
        case(op_code)
            R_type: begin
                branch_reg = 1'b0;
                mem_read_reg = 1'b0;
                mem_to_reg_reg = 1'b0;
                alu_op_reg = 2'b10;
                mem_write_reg = 1'b0;
                alu_src_reg = 1'b0;
                reg_write_en_reg = 1'b1;
            end
            I_op_type: begin
                branch_reg = 1'b0;
                mem_read_reg = 1'b0;
                mem_to_reg_reg = 1'b0;
                alu_op_reg = 2'b00;
                mem_write_reg = 1'b0;
                alu_src_reg = 1'b1;
                reg_write_en_reg = 1'b1;
            end
            I_load_type: begin
                branch_reg = 1'b0;
                mem_read_reg = 1'b1;
                mem_to_reg_reg = 1'b1;
                alu_op_reg = 2'b00;
                mem_write_reg = 1'b0;
                alu_src_reg = 1'b1;
                reg_write_en_reg = 1'b1;
            end
            S_type: begin
                branch_reg = 1'b0;
                mem_read_reg = 1'b0;
                mem_to_reg_reg = 1'b0;
                alu_op_reg = 2'b00;
                mem_write_reg = 1'b1;
                alu_src_reg = 1'b1;
                reg_write_en_reg = 1'b0;
            end
            B_type: begin
                branch_reg = 1'b1;
                mem_read_reg = 1'b0;
                mem_to_reg_reg = 1'b0;
                alu_op_reg = 2'b01;
                mem_write_reg = 1'b0;
                alu_src_reg = 1'b0;
                reg_write_en_reg = 1'b0;
            end
            // J_type: begin
            //     branch_reg = 1'b1;
            //     mem_read_reg = 1'b0;
            //     mem_to_reg_reg = 1'b0;
            //     alu_op_reg = 2'b00;
            //     mem_write_reg = 1'b0;
            //     alu_src_reg = 1'b0;
            //     reg_write_en_reg = 1'b0;
            // end
            default: begin
                branch_reg = 1'b0;
                mem_read_reg = 1'b0;
                mem_to_reg_reg = 1'b0;
                alu_op_reg = 2'b00;
                mem_write_reg = 1'b0;
                alu_src_reg = 1'b0;
                reg_write_en_reg = 1'b0;
            end
        endcase
    end

endmodule