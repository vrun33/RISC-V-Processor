// Hazard Detection Unit for pipeline

module hazard_unit(
    input wire [4:0] IF_ID_rs1,        
    input wire [4:0] IF_ID_rs2,        
    input wire [4:0] ID_EX_rd,         
    input wire ID_EX_mem_read,         
    output wire pc_write,               
    output wire IF_ID_write,            
    output wire control_mux_sel         
);
    reg reg_pc_write, reg_IF_ID_write, reg_control_mux_sel;

    always @(*) begin
        // Assume no stall
        reg_pc_write = 1'b1;
        reg_IF_ID_write = 1'b1;
        reg_control_mux_sel = 1'b0;
        
        if (ID_EX_mem_read && 
            ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)) && 
            (ID_EX_rd != 5'b0)) begin
            
            // Stall 
            reg_pc_write = 1'b0;           // dont update PC
            reg_IF_ID_write = 1'b0;        // dont write to IF_ID
            reg_control_mux_sel = 1'b1;    // bubble daalo 
            // #TODO: Flush the pipeline 
        end
    end

    assign pc_write = reg_pc_write;
    assign IF_ID_write = reg_IF_ID_write;
    assign control_mux_sel = reg_control_mux_sel;

endmodule
