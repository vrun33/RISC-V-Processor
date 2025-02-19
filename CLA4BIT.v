`timescale 1ns / 1ps

module CLA4Bit(input [3:0]a, input [3:0]b, input cin, output [3:0]s, output cout);

    wire [4:0]Carry; // Stage i takes carry in c[i], and produes c[i+1]
    wire [3:0]Pi; // Pi = ai ^ bi
    wire [3:0]Gi; // Gi = ai & bi
    assign Carry[0] = cin;
    assign cout = Carry[4];

    genvar i;
    generate
        for(i = 0; i < 4; i = i + 1)
        begin : Pi_Gi_Loop
            assign Pi[i] = a[i] ^ b[i];
            assign Gi[i] = a[i] & b[i];
        end
    endgenerate

    assign Carry[1] = Gi[0] | (Pi[0] & Carry[0]);
    assign Carry[2] = Gi[1] | (Pi[1] & Gi[0]) | (Pi[1] & Pi[0] & Carry[0]);
    assign Carry[3] = Gi[2] | (Pi[2] & Gi[1]) | (Pi[2] & Pi[1] & Gi[0]) | (Pi[2] & Pi[1] & Pi[0] & Carry[0]);
    assign Carry[4] = Gi[3] | (Pi[3] & Gi[2]) | (Pi[3] & Pi[2] & Gi[1]) | (Pi[3] & Pi[2] & Pi[1] & Gi[0]) | (Pi[3] & Pi[2] & Pi[1] & Pi[0] & Carry[0]);

    generate
        for(i = 0; i < 4; i = i + 1)
        begin : Sum_Loop
            assign s[i] = Pi[i] ^ Carry[i];
        end
    endgenerate

endmodule