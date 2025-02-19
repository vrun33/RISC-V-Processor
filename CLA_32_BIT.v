// 32 Bit Adder

module CLA_N_Bit #(parameter Num = 32)(In1, In2, Cin, Sum, Carry);

    input [Num - 1 : 0]In1;
    input [Num - 1 : 0]In2;
    input Cin;
    output [Num - 1 : 0]Sum;
    output Carry;
    wire [Num : 0]Inter;
    
    assign Inter[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < Num; i = i + 4) 
        begin : CLA_loop
            CLA4Bit fa(In1[i + 3 : i], In2[i + 3 : i], Inter[i], Sum[i + 3 : i], Inter[i + 4]);
        end
    endgenerate

    assign Carry = Inter[Num];
    
endmodule