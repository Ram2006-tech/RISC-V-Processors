module op_and(input [63:0] a, b, output [63:0] res);
    genvar i;
    generate
        for(i=0; i<64; i=i+1) begin : and_loop
            and(res[i], a[i], b[i]);
        end
    endgenerate
endmodule