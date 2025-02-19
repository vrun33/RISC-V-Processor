// 64-bit AND Operation for ALU
module and64(
    input[63:0] a,
    input[63:0] b,
    output[63:0] out,
    output z_flag
);
    genvar i;

    generate
        for(i = 0; i<64; i=i+1) begin
            and a1(out[i], a[i], b[i]);
        end
    endgenerate

    assign z_flag = (out == 64'b0);
    
endmodule