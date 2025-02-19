// Subtractor 64-bit for ALU using 1-bit Full Adder
// `include "fulladder1.v"
module sub64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] diff,
    output c_out,      
    output v_flag,     
    output n_flag,     
    output z_flag      
);
    wire [63:0] b_inv;
    wire [64:0] carry;
    wire a_diff_diff_sign;    
    wire opp_signs;           
    
    // Invert b for subtraction
    genvar j;
    generate
        for(j=0; j< 64;j=j+1) begin
            xor x1(b_inv[j], b[j], 1'b1);
        end
    endgenerate
    
    assign carry[0] = 1;
    
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin
            fulladder1 fa1(
                .sum(diff[i]),
                .cout(carry[i+1]),
                .a(a[i]),
                .b(b_inv[i]),
                .cin(carry[i])
            );
        end
    endgenerate

    assign c_out = carry[64];
    
    // A and Diff have opposite signs
    xor x2(a_diff_diff_sign, a[63], diff[63]);
    
    // A and B have opposite signs
    xor x3(opp_signs, a[63], b[63]);
    
    // AND of conditions 
    and a1(v_flag, a_diff_diff_sign, opp_signs);
    
    assign n_flag = diff[63];
    assign z_flag = (diff == 64'b0);
endmodule