// MUX to select between control signals for stalls 

module control_mux(
    input wire branch,
    input wire mem_read,
    input wire mem_to_reg,
    input wire [3:0] op,
    input wire mem_write,
    input wire alu_src,
    input wire reg_write_en,
    output wire branch_out,
    output wire mem_read_out,
    output wire mem_to_reg_out,
    output wire [3:0] op_out,
    output wire mem_write_out,
    output wire alu_src_out,
    output wire reg_write_en_out,
    input wire control_mux_sel
);

    wire [9:0] input_bus;
    wire [9:0] output_bus;

    assign input_bus[0] = branch;
    assign input_bus[1] = mem_read;
    assign input_bus[2] = mem_to_reg;
    assign input_bus[3] = op[0];
    assign input_bus[4] = op[1];
    assign input_bus[5] = op[2];
    assign input_bus[6] = op[3];
    assign input_bus[7] = mem_write;
    assign input_bus[8] = alu_src;
    assign input_bus[9] = reg_write_en;

    assign output_bus = control_mux_sel ? 10'b0 : input_bus;

    assign branch_out = output_bus[0];
    assign mem_read_out = output_bus[1];
    assign mem_to_reg_out = output_bus[2];
    assign op_out[0] = output_bus[3];
    assign op_out[1] = output_bus[4];
    assign op_out[2] = output_bus[5];
    assign op_out[3] = output_bus[6];
    assign mem_write_out = output_bus[7];
    assign alu_src_out = output_bus[8];
    assign reg_write_en_out = output_bus[9];

endmodule