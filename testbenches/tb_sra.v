`timescale 1ns / 1ps

module tb_sra;

    // ==========================================
    // 1. Signal Declaration
    // ==========================================
    reg [63:0] a;      // Input value
    reg [63:0] b;      // Shift amount
    
    wire [63:0] res;   // Result

    // ==========================================
    // 2. Instantiate the Unit Under Test (UUT)
    // ==========================================
    op_sra uut (
        .a(a), 
        .b(b), 
        .res(res)
    );

    // ==========================================
    // 3. Test Stimulus
    // ==========================================
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_sra);

        $display("----------------------------------------------------------------------");
        $display("Testing 64-bit Shift Right Arithmetic (SRA)");
        $display("----------------------------------------------------------------------");

        // ------------------------------------------------------------
        // Test 1: Positive Number Shift (Acts like Logical Shift)
        // Logic: MSB is 0. 7 (0111) >> 4 becomes 0 (0000) filled with 0s.
        // ------------------------------------------------------------
        a = 64'h7000000000000000; // Positive number (MSB is 0)
        b = 64'd4;
        #10;
        // Expected: 0111... -> 00000111... (0700...)
        check_result("Positive >> 4 (0 Fill)", 64'h0700000000000000);

        // ------------------------------------------------------------
        // Test 2: Negative Number Shift (Sign Extension)
        // Logic: MSB is 1. We expect 1s to fill in from the left.
        // ------------------------------------------------------------
        a = 64'h8000000000000000; // Min Negative (Binary 1000...)
        b = 64'd1;
        #10;
        // Expected: 1000... >> 1 becomes 1100... (Hex C000...)
        check_result("Negative >> 1 (1 Fill)", 64'hC000000000000000);

        // ------------------------------------------------------------
        // Test 3: Shift -1 (All 1s)
        // Logic: -1 is all 1s. Shifting right arithmetic should KEEP it -1.
        //        1111... >> 8 (fill with 1s) -> 1111...
        // ------------------------------------------------------------
        a = 64'hFFFFFFFFFFFFFFFF; // -1
        b = 64'd8;
        #10;
        check_result("(-1) >> 8 (Stay -1)", 64'hFFFFFFFFFFFFFFFF);

        // ------------------------------------------------------------
        // Test 4: Shift Min Negative by Max Amount
        // Logic: 1000... (Min Int) >> 63.
        //        The sign bit (1) propagates all the way to the LSB.
        //        Result should be 1111... (-1)
        // ------------------------------------------------------------
        a = 64'h8000000000000000;
        b = 64'd63;
        #10;
        check_result("Min Neg >> 63", 64'hFFFFFFFFFFFFFFFF);

        // ------------------------------------------------------------
        // Test 5: Zero Shift (Identity)
        // ------------------------------------------------------------
        a = 64'hDEADBEEFCAFEBABE;
        b = 64'd0;
        #10;
        check_result("Shift by 0", a);

        $display("----------------------------------------------------------------------");
        $finish;
    end

    // Helper task
    task check_result;
        input [255:0] test_name;
        input [63:0] expected;
        begin
            if (res === expected)
                $display("Test: %0s \n  [PASS] Input: %h, Shift: %d \n         Res:   %h", test_name, a, b, res);
            else
                $display("Test: %0s \n  [FAIL] Input: %h, Shift: %d \n         Got:   %h \n         Exp:   %h", 
                         test_name, a, b, res, expected);
        end
    endtask

endmodule