`timescale 1ns / 1ps

module tb_or;

    // ==========================================
    // 1. Signal Declaration
    // ==========================================
    reg [63:0] a;
    reg [63:0] b;
    
    wire [63:0] res;

    // ==========================================
    // 2. Instantiate the OR Module (UUT)
    // ==========================================
    op_or uut (
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
        $dumpvars(0, tb_or);

        $display("----------------------------------------------------------------------");
        $display("Testing 64-bit Bitwise OR (op_or)");
        $display("----------------------------------------------------------------------");

        // ------------------------------------------------------------
        // Test 1: Identity Check (OR with 0s)
        // Logic: X | 0 = X. Input 'a' should pass through unchanged.
        // ------------------------------------------------------------
        a = 64'hDEADBEEFCAFEBABE; 
        b = 64'd0; 
        #10;
        check_result("Identity (X | 0)", a);

        // ------------------------------------------------------------
        // Test 2: Saturation Check (OR with 1s)
        // Logic: X | 1 = 1. Result should be all 1s.
        // ------------------------------------------------------------
        a = 64'hDEADBEEFCAFEBABE; 
        b = 64'hFFFFFFFFFFFFFFFF; // All 1s
        #10;
        check_result("Saturation (X | 1s)", 64'hFFFFFFFFFFFFFFFF);

        // ------------------------------------------------------------
        // Test 3: Merging Bits (Alternating Pattern)
        // Logic: 1010... | 0101... = 1111...
        // ------------------------------------------------------------
        a = 64'hAAAAAAAAAAAAAAAA; // Binary 1010...
        b = 64'h5555555555555555; // Binary 0101...
        #10;
        check_result("Merge Alternating Bits", 64'hFFFFFFFFFFFFFFFF);

        // ------------------------------------------------------------
        // Test 4: Setting Lower Bits
        // Logic: Keep upper bits of A, force lower bits to 1 via B
        // ------------------------------------------------------------
        a = 64'hFFFF0000FFFF0000; 
        b = 64'h0000FFFF0000FFFF; 
        #10;
        check_result("Set Lower Bits", 64'hFFFFFFFFFFFFFFFF);

        // ------------------------------------------------------------
        // Test 5: Random Mix
        // ------------------------------------------------------------
        a = 64'h1234000012340000;
        b = 64'h0000567800005678;
        // Result should combine them into 12345678...
        #10;
        check_result("Random Mix", 64'h1234567812345678);

        $display("----------------------------------------------------------------------");
        $finish;
    end

    // Helper task
    task check_result;
        input [255:0] test_name;
        input [63:0] expected;
        begin
            if (res === expected)
                $display("Test: %0s \n  [PASS] %h | %h = %h", test_name, a, b, res);
            else
                $display("Test: %0s \n  [FAIL] %h | %h = %h (Expected: %h)", 
                         test_name, a, b, res, expected);
        end
    endtask

endmodule