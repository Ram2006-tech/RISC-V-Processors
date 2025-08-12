`timescale 1ns / 1ps

module tb_and;

    // ==========================================
    // 1. Signal Declaration
    // ==========================================
    reg [63:0] a;
    reg [63:0] b;
    
    wire [63:0] res;

    // ==========================================
    // 2. Instantiate the AND Module (UUT)
    // ==========================================
    op_and uut (
        .a(a), 
        .b(b), 
        .res(res)
    );

    // ==========================================
    // 3. Test Stimulus
    // ==========================================
    initial begin
        // For waveform viewing
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_and);

        $display("----------------------------------------------------------------------");
        $display("Testing 64-bit Bitwise AND (op_and)");
        $display("----------------------------------------------------------------------");

        // ------------------------------------------------------------
        // Test 1: Identity Check (AND with all 1s)
        // Logic: X & 1 = X. We check if input 'a' passes through unchanged.
        // ------------------------------------------------------------
        a = 64'hA5A5A5A5A5A5A5A5; 
        b = 64'hFFFFFFFFFFFFFFFF; // All 1s
        #10;
        check_result("Identity (X & 1s)", a);

        // ------------------------------------------------------------
        // Test 2: Zero Check (AND with all 0s)
        // Logic: X & 0 = 0.
        // ------------------------------------------------------------
        a = 64'hFFFFFFFFFFFFFFFF; 
        b = 64'h0000000000000000; // All 0s
        #10;
        check_result("Zero Check (X & 0s)", 64'd0);

        // ------------------------------------------------------------
        // Test 3: Alternating Patterns (No Overlap)
        // Logic: 1010... & 0101... should yield 0000...
        // ------------------------------------------------------------
        a = 64'hAAAAAAAAAAAAAAAA; // Binary 1010...
        b = 64'h5555555555555555; // Binary 0101...
        #10;
        check_result("Alternating Bits (No Overlap)", 64'd0);

        // ------------------------------------------------------------
        // Test 4: Masking High Bits
        // Logic: Keep only the lower 32 bits (Upper bits should become 0)
        // ------------------------------------------------------------
        a = 64'hDEADBEEFCAFEBABE; 
        b = 64'h00000000FFFFFFFF; // Mask upper 32 bits
        #10;
        check_result("Mask Upper 32 Bits", 64'h00000000CAFEBABE);

        // ------------------------------------------------------------
        // Test 5: Mixed Pattern
        // ------------------------------------------------------------
        a = 64'hF0F0F0F00F0F0F0F;
        b = 64'hFF00FF00FF00FF00;
        // Expected Logic: 
        // F0 & FF = F0
        // F0 & 00 = 00
        // 0F & FF = 0F
        // 0F & 00 = 00
        #10;
        check_result("Mixed Pattern", 64'hF000F0000F000F00);

        $display("----------------------------------------------------------------------");
        $finish;
    end

    // Helper task to make output readable
    task check_result;
        input [255:0] test_name;
        input [63:0] expected;
        begin
            if (res === expected)
                $display("Test: %0s \n  [PASS] %h & %h = %h", test_name, a, b, res);
            else
                $display("Test: %0s \n  [FAIL] %h & %h = %h (Expected: %h)", 
                         test_name, a, b, res, expected);
        end
    endtask

endmodule