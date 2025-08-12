module op_slt(input [63:0] a, b, output [63:0] res);
    wire [63:0] sub_res;
    wire cout, ovf;
    
    // Reuse SUB logic
    op_sub subtractor(.a(a), .b(b), .res(sub_res), .cout(cout), .ovf(ovf));
    
    // SLT is true if (Sign_Bit XOR Overflow) is 1
    wire res_bit;
    xor(res_bit, sub_res[63], ovf);
    
    assign res[0] = res_bit;
    
    genvar i;
    generate
        for(i=1; i<64; i=i+1) assign res[i] = 1'b0;
    endgenerate
endmodule