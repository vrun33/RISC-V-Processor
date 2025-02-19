// 1-bit Full Adder for ALU 
module fulladder1(
    output sum,
    output cout,
    input a,
    input b,
    input cin
);
    wire s1, c1, c2;

    xor x1(s1, a, b);
    xor x2(sum, s1, cin); // sum = a XOR b XOR cin
    and a1(c1, s1, cin);
    and a2(c2, a, b);
    or o1(cout, c1, c2); // cout = ab + cin (a XOR b)

endmodule