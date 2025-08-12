module op_xor(input [63:0] a, b, output [63:0] res);
    genvar i;
    generate
        for(i=0; i<64; i=i+1) begin : xor_loop
            xor(res[i], a[i], b[i]);
        end
    endgenerate
endmodule