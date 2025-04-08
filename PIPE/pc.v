// Program Counter - Active High Reset
// Now with write enable!

module pc(
    input clk,
    input reset,
    input [63:0] pc_in,
    input pc_write,     // write enable signal from hazard zaza unit
    output [63:0] pc_out
);

    reg [63:0] pc_reg;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            pc_reg <= 64'h0;
        end
            
        else if(pc_write) begin // update iff pc_write is high else stall
            pc_reg <= pc_in;
        end
    end

    assign pc_out = pc_reg;
    
endmodule