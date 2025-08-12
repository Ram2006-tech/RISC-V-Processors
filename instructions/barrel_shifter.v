module barrel_shifter(
    input [63:0] in, 
    input [5:0] amt, 
    input is_right, 
    input is_arith, 
    output [63:0] out
);
    wire [63:0] rev_in, s0, s1, s2, s3, s4, s5, rev_out;
    wire fill_bit;
    
    // Fill bit is in[63] if Arithmetic Right Shift, else 0
    and(fill_bit, is_right, is_arith, in[63]);

    // 1. Reverse Input if Right Shift
    genvar i, j;
    generate
        for(i=0; i<64; i=i+1) begin : reverse_in
            mux2to1 m(in[i], in[63-i], is_right, rev_in[i]);
        end
    endgenerate

    // 2. Left Shift Stages (0 to 5)
    generate
        // Stage 0 (Shift 1)
        for(j=0; j<64; j=j+1) begin : stage0
            wire b_in = (j == 0) ? fill_bit : rev_in[j-1];
            mux2to1 m(rev_in[j], b_in, amt[0], s0[j]);
        end
        // Stage 1 (Shift 2)
        for(j=0; j<64; j=j+1) begin : stage1
            wire b_in = (j < 2) ? fill_bit : s0[j-2];
            mux2to1 m(s0[j], b_in, amt[1], s1[j]);
        end
        // Stage 2 (Shift 4)
        for(j=0; j<64; j=j+1) begin : stage2
            wire b_in = (j < 4) ? fill_bit : s1[j-4];
            mux2to1 m(s1[j], b_in, amt[2], s2[j]);
        end
        // Stage 3 (Shift 8)
        for(j=0; j<64; j=j+1) begin : stage3
            wire b_in = (j < 8) ? fill_bit : s2[j-8];
            mux2to1 m(s2[j], b_in, amt[3], s3[j]);
        end
        // Stage 4 (Shift 16)
        for(j=0; j<64; j=j+1) begin : stage4
            wire b_in = (j < 16) ? fill_bit : s3[j-16];
            mux2to1 m(s3[j], b_in, amt[4], s4[j]);
        end
        // Stage 5 (Shift 32)
        for(j=0; j<64; j=j+1) begin : stage5
            wire b_in = (j < 32) ? fill_bit : s4[j-32];
            mux2to1 m(s4[j], b_in, amt[5], s5[j]);
        end
    endgenerate

    // 3. Reverse Output if Right Shift
    generate
        for(i=0; i<64; i=i+1) begin : reverse_out
            mux2to1 m(s5[i], s5[63-i], is_right, out[i]);
        end
    endgenerate
endmodule