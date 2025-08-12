// 1-bit Full Adder (Structural)
module full_adder(input a, b, cin, output sum, cout);
    wire axorb, aandb, axorb_and_cin;
    xor(axorb, a, b);
    xor(sum, axorb, cin);
    and(aandb, a, b);
    and(axorb_and_cin, axorb, cin);
    or(cout, aandb, axorb_and_cin);
endmodule

// 2-to-1 Multiplexer (Structural)
module mux2to1(input i0, i1, sel, output out);
    wire not_sel, w0, w1;
    not(not_sel, sel);
    and(w0, i0, not_sel);
    and(w1, i1, sel);
    or(out, w0, w1);
endmodule