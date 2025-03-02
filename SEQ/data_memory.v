module data_memory #(parameter DATA_WIDTH = 64, parameter ADDR_WIDTH = 10) (
    input wire clk,
    input wire reset,                // Active-high asynchronous reset
    input wire [ADDR_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0] write_data,
    input wire mem_write,
    input wire mem_read,
    output wire [DATA_WIDTH-1:0] read_data
);
    // Memory array
    reg [DATA_WIDTH-1:0] mem [(2**ADDR_WIDTH)-1:0];
    integer i; // Declare the loop variable outside the always block

    // Write to memory with asynchronous reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Clear entire memory on reset
            for (i = 0; i < (2**ADDR_WIDTH); i = i + 1) begin
                mem[i] = 0; // Use '=' for blocking assignment in reset loops
            end
        end 
        else if (mem_write) begin
            mem[addr] <= write_data; // Non-blocking assignment for sequential logic
            // Print data that is being written
            $display("Writing %h to address %h", write_data, addr);
        end
    end

    reg [DATA_WIDTH-1:0] read_data_reg; // Declare read_data as a reg for continuous assignment

    assign read_data = read_data_reg; // Assign read_data to read_data_reg
    
    always @(*) begin
        if (mem_read) begin
            read_data_reg = mem[addr]; // Read data from memory
        end
        else begin
            read_data_reg = 0; // Output 0 if mem_read is low (or High-z if required)
        end
    end

endmodule

