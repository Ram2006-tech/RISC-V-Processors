// =================================================================
// PART 1: STRUCTURAL HELPERS
// (Basic building blocks used by the instruction modules)
// =================================================================

// 1-bit Full Adder
module full_adder(input a, b, cin, output sum, cout);
    wire axorb, aandb, axorb_and_cin;
    xor(axorb, a, b);
    xor(sum, axorb, cin);
    and(aandb, a, b);
    and(axorb_and_cin, axorb, cin);
    or(cout, aandb, axorb_and_cin);
endmodule

// 2-to-1 Multiplexer
module mux2to1(input i0, i1, sel, output out);
    wire not_sel, w0, w1;
    not(not_sel, sel);
    and(w0, i0, not_sel);
    and(w1, i1, sel);
    or(out, w0, w1);
endmodule

// Shared Barrel Shifter Core (Used by SLL, SRL, SRA)
module barrel_shifter_core(
    input [63:0] in, 
    input [5:0] amt, 
    input is_right, 
    input is_arith, 
    output [63:0] out
);
    wire [63:0] rev_in, s0, s1, s2, s3, s4, s5;
    wire fill_bit;
    
    // Fill bit is in[63] if Arithmetic Right Shift, else 0
    and(fill_bit, is_right, is_arith, in[63]);

    // 1. Pre-Reverse Input (only if Right Shift)
    genvar i, j;
    generate
        for(i=0; i<64; i=i+1) begin : rev_input
            mux2to1 m(in[i], in[63-i], is_right, rev_in[i]);
        end
    endgenerate

    // 2. Left Shift Stages (0 to 5)
    generate
        // Stage 0 (Shift 1)
        for(j=0; j<64; j=j+1) begin : st0
            wire b_in = (j == 0) ? fill_bit : rev_in[j-1];
            mux2to1 m(rev_in[j], b_in, amt[0], s0[j]);
        end
        // Stage 1 (Shift 2)
        for(j=0; j<64; j=j+1) begin : st1
            wire b_in = (j < 2) ? fill_bit : s0[j-2];
            mux2to1 m(s0[j], b_in, amt[1], s1[j]);
        end
        // Stage 2 (Shift 4)
        for(j=0; j<64; j=j+1) begin : st2
            wire b_in = (j < 4) ? fill_bit : s1[j-4];
            mux2to1 m(s1[j], b_in, amt[2], s2[j]);
        end
        // Stage 3 (Shift 8)
        for(j=0; j<64; j=j+1) begin : st3
            wire b_in = (j < 8) ? fill_bit : s2[j-8];
            mux2to1 m(s2[j], b_in, amt[3], s3[j]);
        end
        // Stage 4 (Shift 16)
        for(j=0; j<64; j=j+1) begin : st4
            wire b_in = (j < 16) ? fill_bit : s3[j-16];
            mux2to1 m(s3[j], b_in, amt[4], s4[j]);
        end
        // Stage 5 (Shift 32)
        for(j=0; j<64; j=j+1) begin : st5
            wire b_in = (j < 32) ? fill_bit : s4[j-32];
            mux2to1 m(s4[j], b_in, amt[5], s5[j]);
        end
    endgenerate

    // 3. Post-Reverse Output (only if Right Shift)
    generate
        for(i=0; i<64; i=i+1) begin : rev_output
            mux2to1 m(s5[i], s5[63-i], is_right, out[i]);
        end
    endgenerate
endmodule

// =================================================================
// PART 2: THE 10 SEPARATE INSTRUCTION MODULES
// =================================================================

// 1. ADD
module op_add(input [63:0] a, b, output [63:0] res, output cout, output ovf);
    wire [64:0] c;
    assign c[0] = 1'b0; 
    genvar i;
    generate
        for(i=0; i<64; i=i+1) begin : add_loop
            full_adder fa(a[i], b[i], c[i], res[i], c[i+1]);
        end
    endgenerate
    assign cout = c[64];
    xor(ovf, c[63], c[64]);
endmodule

// 2. SUB
module op_sub(input [63:0] a, b, output [63:0] res, output cout, output ovf);
    wire [63:0] b_inv;
    wire [64:0] c;
    genvar i;
    generate
        for(i=0; i<64; i=i+1) xor(b_inv[i], b[i], 1'b1);
        
        assign c[0] = 1'b1; // +1 for 2's complement
        
        for(i=0; i<64; i=i+1) begin : sub_loop
            full_adder fa(a[i], b_inv[i], c[i], res[i], c[i+1]);
        end
    endgenerate
    assign cout = c[64];
    xor(ovf, c[63], c[64]);
endmodule

// 3. AND
module op_and(input [63:0] a, b, output [63:0] res);
    genvar i;
    generate for(i=0; i<64; i=i+1) and(res[i], a[i], b[i]); endgenerate
endmodule

// 4. OR
module op_or(input [63:0] a, b, output [63:0] res);
    genvar i;
    generate for(i=0; i<64; i=i+1) or(res[i], a[i], b[i]); endgenerate
endmodule

// 5. XOR
module op_xor(input [63:0] a, b, output [63:0] res);
    genvar i;
    generate for(i=0; i<64; i=i+1) xor(res[i], a[i], b[i]); endgenerate
endmodule

// 6. SLL (Shift Left Logical)
module op_sll(input [63:0] a, b, output [63:0] res);
    barrel_shifter_core bs(.in(a), .amt(b[5:0]), .is_right(1'b0), .is_arith(1'b0), .out(res));
endmodule

// 7. SRL (Shift Right Logical)
module op_srl(input [63:0] a, b, output [63:0] res);
    barrel_shifter_core bs(.in(a), .amt(b[5:0]), .is_right(1'b1), .is_arith(1'b0), .out(res));
endmodule

// 8. SRA (Shift Right Arithmetic)
module op_sra(input [63:0] a, b, output [63:0] res);
    barrel_shifter_core bs(.in(a), .amt(b[5:0]), .is_right(1'b1), .is_arith(1'b1), .out(res));
endmodule

// 9. SLT (Set Less Than Signed)
module op_slt(input [63:0] a, b, output [63:0] res);
    wire [63:0] sub_res;
    wire cout, ovf;
    op_sub s(.a(a), .b(b), .res(sub_res), .cout(cout), .ovf(ovf));
    
    wire bit0;
    xor(bit0, sub_res[63], ovf); // Result = SignBit XOR Overflow
    
    assign res[0] = bit0;
    genvar i;
    generate for(i=1; i<64; i=i+1) assign res[i] = 1'b0; endgenerate
endmodule

// 10. SLTU (Set Less Than Unsigned)
module op_sltu(input [63:0] a, b, output [63:0] res);
    wire [63:0] sub_res;
    wire cout, ovf;
    op_sub s(.a(a), .b(b), .res(sub_res), .cout(cout), .ovf(ovf));
    
    wire bit0;
    not(bit0, cout); // Borrow implies A < B
    
    assign res[0] = bit0;
    genvar i;
    generate for(i=1; i<64; i=i+1) assign res[i] = 1'b0; endgenerate
endmodule

// =================================================================
// PART 3: TOP LEVEL WRAPPER (alu_64_bit)
// =================================================================

module alu_64_bit(
    input [63:0] a,
    input [63:0] b,
    input [3:0] opcode,
    output reg [63:0] result,
    output reg cout,
    output reg carry_flag,
    output reg overflow_flag,
    output zero_flag
);

    // Wires to hold the results from all 10 modules
    wire [63:0] w_add, w_sub, w_and, w_or, w_xor, w_sll, w_srl, w_sra, w_slt, w_sltu;
    wire c_add, o_add, c_sub, o_sub;

    // --- Instantiate All 10 Instructions ---
    op_add  u1 (.a(a), .b(b), .res(w_add),  .cout(c_add), .ovf(o_add));
    op_sub  u2 (.a(a), .b(b), .res(w_sub),  .cout(c_sub), .ovf(o_sub));
    op_and  u3 (.a(a), .b(b), .res(w_and));
    op_or   u4 (.a(a), .b(b), .res(w_or));
    op_xor  u5 (.a(a), .b(b), .res(w_xor));
    op_sll  u6 (.a(a), .b(b), .res(w_sll));
    op_srl  u7 (.a(a), .b(b), .res(w_srl));
    op_sra  u8 (.a(a), .b(b), .res(w_sra));
    op_slt  u9 (.a(a), .b(b), .res(w_slt));
    op_sltu u10(.a(a), .b(b), .res(w_sltu));

    // --- MUX Logic to Select Output based on Opcode ---
    always @(*) begin
        // Default values for flags to avoid latches
        cout = 0; 
        carry_flag = 0; 
        overflow_flag = 0;
        
        case(opcode)
            4'b0000: begin // ADD
                result = w_add; 
                cout = c_add; 
                carry_flag = c_add; 
                overflow_flag = o_add; 
            end
            4'b0001: result = w_sll; // SLL
            4'b0010: result = w_slt; // SLT
            4'b0011: result = w_sltu; // SLTU
            4'b0100: result = w_xor; // XOR
            4'b0101: result = w_srl; // SRL
            4'b0110: result = w_or;  // OR
            4'b0111: result = w_and; // AND
            4'b1000: begin // SUB
                result = w_sub; 
                cout = c_sub; 
                carry_flag = c_sub; 
                overflow_flag = o_sub; 
            end
            4'b1101: result = w_sra; // SRA
            default: result = 64'd0;
        endcase
    end

    // Zero Flag Logic (Structural Reduction NOR)
    assign zero_flag = ~(|result);

endmodule