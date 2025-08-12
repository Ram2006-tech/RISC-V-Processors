// File: sltu.v
module op_sltu(input [63:0] a, b, output [63:0] res);
    wire [63:0] sub_res;
    wire cout, ovf;
    
    // Reuse SUB logic
    op_sub subtractor(.a(a), .b(b), .res(sub_res), .cout(cout), .ovf(ovf));
    
    // For Unsigned Sub (A + ~B + 1):
    // Cout=1 implies A >= B. Cout=0 implies A < B (Borrow).
    wire res_bit;
    not(res_bit, cout);
    
    assign res[0] = res_bit;
    
    genvar i;
    generate
        for(i=1; i<64; i=i+1) assign res[i] = 1'b0;
    endgenerate
endmodule