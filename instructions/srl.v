module op_srl(input [63:0] a, b, output [63:0] res);
    barrel_shifter bs(
        .in(a), .amt(b[5:0]), .is_right(1'b1), .is_arith(1'b0), .out(res)
    );
endmodule