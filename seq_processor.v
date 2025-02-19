// Wrapper conencting all the blocks

`include "pc.v"
`include "instruction_mem.v"
`include "control.v"
`include "imm_gen.v"
`include "register_file.v"
`include "data_memory.v"
`include "MUX_2X1.v"
`include "CLA_32_BIT.v"
`include "and2.v"
`include "sl1.v"
// Include ALU

module seq_processor (
    input clk
);

    // Instantiate Hardware
    initial
    begin

    end

    // Instantiate Memory
    initial
    begin

    end

    // Update on Clock
    always @(posedge clk)
    begin

    end

endmodule