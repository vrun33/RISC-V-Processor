// 2x1 MUX

module Mux2x1(in1, in2, s0, y);

    input in1, in2, s0;
    output y;
    wire Nots0, p, q;

    not N1(Nots0, s0);
    and A1(p, in1, Nots0);
    and A2(q, in2, s0);
    or O1(y, p, q);

endmodule