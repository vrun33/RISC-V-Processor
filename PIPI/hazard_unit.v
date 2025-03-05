// Hazard Detection Unit for pipeline

module hazard_unit(
    input wire [4:0] IF_ID_rs1,        
    input wire [4:0] IF_ID_rs2,        
    input wire [4:0] ID_EX_rd,         
    input wire ID_EX_mem_read,         
    output reg pc_write,               
    output reg IF_ID_write,            
    output reg control_mux_sel         
);

    always @(*) begin
        // Assume no stall
        pc_write = 1'b1;
        IF_ID_write = 1'b1;
        control_mux_sel = 1'b0;
        
        if (ID_EX_mem_read && 
            ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)) && 
            (ID_EX_rd != 5'b0)) begin
            
            // Stall 
            pc_write = 1'b0;           // dont update PC
            IF_ID_write = 1'b0;        // dont write to IF_ID
            control_mux_sel = 1'b1;    // bubble daalo 
        end
    end

endmodule
