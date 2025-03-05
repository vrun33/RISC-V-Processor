// MUX to select between control signals for stalls 

module control_mux(
    input wire branch,
    input wire mem_read,
    input wire mem_to_reg,
    input wire [1:0] alu_op,
    input wire mem_write,
    input wire alu_src,
    input wire reg_write_en,
    output wire branch_out,
    output wire mem_read_out,
    output wire mem_to_reg_out,
    output wire [1:0] alu_op_out,
    output wire mem_write_out,
    output wire alu_src_out,
    output wire reg_write_en_out,
    input wire control_mux_sel
);

    wire input_bus [7:0];
    wire output_bus [7:0];

    assign input_bus[0] = branch;
    assign input_bus[1] = mem_read;
    assign input_bus[2] = mem_to_reg;
    assign input_bus[3] = alu_op[0];
    assign input_bus[4] = alu_op[1];
    assign input_bus[5] = mem_write;
    assign input_bus[6] = alu_src;
    assign input_bus[7] = reg_write_en;

    assign output_bus = control_mux_sel ? 8'b0 : input_bus;

    assign branch_out = output_bus[0];
    assign mem_read_out = output_bus[1];
    assign mem_to_reg_out = output_bus[2];
    assign alu_op_out[0] = output_bus[3];
    assign alu_op_out[1] = output_bus[4];
    assign mem_write_out = output_bus[5];
    assign alu_src_out = output_bus[6];
    assign reg_write_en_out = output_bus[7];

endmodule