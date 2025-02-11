module register_file (
    input wire clk,
    input wire [4:0] read_reg1,
    input wire [4:0] read_reg2,
    input wire [4:0] write_reg,
    input wire [63:0] write_data,
    input wire reg_write_en,
    output wire [63:0] read_data1,
    output wire [63:0] read_data2
);

    // 31 registers, each 64 bits
    reg [63:0] registers [31:0];

    // Initialize registers to 0
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 64'b0;
        end
    end

    // Read data from registers
    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];

    // Write data to registers
    always @(posedge clk) begin
        if (reg_write_en && write_reg != 5'b0) begin  
            registers[write_reg] <= write_data;
        end
    end

endmodule