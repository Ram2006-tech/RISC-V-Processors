module op_sub(
    input [63:0] a, 
    input [63:0] b, 
    output [63:0] res, 
    output cout, 
    output ovf
);
    wire [63:0] b_inv;
    wire [64:0] c;
    
    // Invert B for 2's complement subtraction
    genvar i;
    generate
        for(i=0; i<64; i=i+1) begin : inv_loop
            xor(b_inv[i], b[i], 1'b1);
        end
    endgenerate

    assign c[0] = 1'b1; // SUB has carry-in 1
    
    generate
        for(i=0; i<64; i=i+1) begin : sub_loop
            full_adder fa(a[i], b_inv[i], c[i], res[i], c[i+1]);
        end
    endgenerate
    
    assign cout = c[64];
    xor(ovf, c[63], c[64]);
endmodule