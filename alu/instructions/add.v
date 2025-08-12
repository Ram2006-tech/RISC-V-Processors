module op_add(
    input [63:0] a, 
    input [63:0] b, 
    output [63:0] res, 
    output cout, 
    output ovf
);
    wire [64:0] c;
    assign c[0] = 1'b0; // ADD has carry-in 0
    
    genvar i;
    generate
        for(i=0; i<64; i=i+1) begin : adder_loop
            full_adder fa(a[i], b[i], c[i], res[i], c[i+1]);
        end
    endgenerate
    
    assign cout = c[64];
    xor(ovf, c[63], c[64]); // Overflow = C_in_MSB XOR C_out_MSB
endmodule