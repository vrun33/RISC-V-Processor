// Instruction memory

module instruction_memory #(parameter MEM_SIZE = 4095, parameter MEM_INIT_FILE = "mem_init.txt") (
    input wire clk,
    input wire [63:0] addr,
    output wire [31:0] instr
);

    reg [7:0] mem [0:MEM_SIZE-1];
    reg [31:0]tmp;
    assign instr = tmp;

    // Add error checking
    initial begin
        if (!$readmemh(MEM_INIT_FILE, mem)) begin
            $display("Error: Failed to read memory initialization file");
            $finish;
        end
    end

    // At posedge, concatenate the 8-bit values to form a 32-bit instruction
    always @(posedge clk)
    begin
        tmp = {mem[addr], mem[addr+1], mem[addr+2], mem[addr+3]};
    end

endmodule