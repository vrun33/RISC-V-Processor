`timescale 1ns / 1ps
`include "data_memory.v"

module data_memory_tb;
    localparam DATA_WIDTH = 64;
    localparam ADDR_WIDTH = 10;

    reg clk = 0;
    reg rst = 1;
    reg [ADDR_WIDTH-1:0] addr;
    reg [DATA_WIDTH-1:0] write_data;
    reg mem_write;
    reg mem_read;
    wire [DATA_WIDTH-1:0] read_data;

    data_memory #(DATA_WIDTH, ADDR_WIDTH) uut (
        .clk(clk), .reset(rst), .addr(addr), .write_data(write_data),
        .mem_write(mem_write), .mem_read(mem_read), .read_data(read_data)
    );

    always #10 clk = ~clk;

    initial begin
        $dumpfile("data_memory_tb.vcd");
        $dumpvars(1, data_memory_tb);
        mem_read = 0; mem_write = 0; #10
        rst = 1; #10 rst = 0;

        // Test 1: Write and read from address 5
        addr = 5; write_data = 64'hCAFEBABEDEADBEEF; mem_write = 1; #20; mem_write = 0;
        mem_read = 1; #20; $display("Addr 5: %h", read_data); mem_read = 0;

        // Test 2: Write and read from address 0
        addr = 0; write_data = 64'h1234567890ABCDEF; mem_write = 1; #20; mem_write = 0;
        mem_read = 1; #20; $display("Addr 0: %h", read_data); mem_read = 0;

        // Test 3: Write and read from max address (1023)
        addr = 1023; write_data = 64'hFFFFFFFFFFFFFFFF; mem_write = 1; #20; mem_write = 0;
        mem_read = 1; #20; $display("Addr 1023: %h", read_data); mem_read = 0;

        // Edge case: No write, just read
        addr = 10; mem_read = 1; #20; $display("Addr 10 (unwritten): %h", read_data); mem_read = 0;

        // Edge case: Write to address 1, then reset
        addr = 1; write_data = 64'hA5A5A5A5A5A5A5A5; mem_write = 1; #20; rst = 1; #20; rst = 0; mem_write = 0;
        mem_read = 1; #20; $display("Addr 1 after reset: %h", read_data); mem_read = 0;

        #20; $finish;
    end
endmodule
