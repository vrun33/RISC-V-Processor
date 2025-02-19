module fa64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] sum,
    output c_out,      
    output v_flag,     
    output n_flag,     
    output z_flag      
);
    wire [64:0] carry;
    wire a_sum_diff_sign;
    wire same_signs_temp;     
    wire same_signs;          

    assign carry[0] = 0;

    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin 
            fulladder1 fa1(
                .sum(sum[i]), 
                .cout(carry[i+1]), 
                .a(a[i]), 
                .b(b[i]), 
                .cin(carry[i])
            );
        end
    endgenerate

    assign c_out = carry[64];
    
    // A and Sum have opposite signs
    xor x1(a_sum_diff_sign, a[63], sum[63]);
    
    // A and B have same signs 
    xor x2(same_signs_temp, a[63], b[63]);
    xor x3(same_signs, same_signs_temp, 1'b1);  // XNOR 

    and a1(v_flag, a_sum_diff_sign, same_signs);
    
    assign n_flag = sum[63];
    assign z_flag = (sum == 64'b0);
endmodule