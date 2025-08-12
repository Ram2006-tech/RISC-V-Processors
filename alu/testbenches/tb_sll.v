`timescale 1ns / 1ps

module tb_sll;

    // ==========================================
    // 1. Signal Declaration
    // ==========================================
    reg [63:0] a;      // The value to shift
    reg [63:0] b;      // The shift amount (only lower 6 bits used)
    
    wire [63:0] res;   // Result

    // ==========================================
    // 2. Instantiate the Unit Under Test (UUT)
    // ==========================================
    op_sll uut (
        .a(a), 
        .b(b), 
        .res(res)
    );

    // ==========================================
    // 3. Test Stimulus
    // ==========================================
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_sll);

        $display("----------------------------------------------------------------------");
        $display("Testing 64-bit Shift Left Logical (SLL)");
        $display("----------------------------------------------------------------------");

        // ------------------------------------------------------------
        // Test 1: Shift by 0 (Identity)
        // Logic: Should remain unchanged.
        // ------------------------------------------------------------
        a = 64'hDEADBEEFCAFEBABE;
        b = 64'd0;
        #10;
        check_result("Shift by 0", a);

        // ------------------------------------------------------------
        // Test 2: Shift by 1
        // Logic: Multiply by 2. LSB becomes 0.
        // ------------------------------------------------------------
        a = 64'd1;
        b = 64'd1;
        #10;
        check_result("1 << 1", 64'd2);

        // ------------------------------------------------------------
        // Test 3: Shift by 4 (Nibble Shift)
        // Logic: F (1111) << 4 becomes F0 (11110000)
        // ------------------------------------------------------------
        a = 64'h000000000000000F;
        b = 64'd4;
        #10;
        check_result("F << 4", 64'h00000000000000F0);

        // ------------------------------------------------------------
        // Test 4: Shift by 32 (Halfway)
        // Logic: Lower 32 bits move to Upper 32 bits. Lower 32 become 0.
        // ------------------------------------------------------------
        a = 64'h00000000FFFFFFFF;
        b = 64'd32;
        #10;
        check_result("Shift by 32", 64'hFFFFFFFF00000000);

        // ------------------------------------------------------------
        // Test 5: Max Shift (Shift by 63)
        // Logic: Only the LSB (bit 0) survives and moves to MSB (bit 63).
        // ------------------------------------------------------------
        a = 64'd1; // Binary ...001
        b = 64'd63;
        #10;
        check_result("1 << 63", 64'h8000000000000000);

        // ------------------------------------------------------------
        // Test 6: Shift moves everything out (Clear)
        // Note: With 6 bits (b[5:0]), max shift is 63. 
        // If we want to test "shifting everything out", input must be higher up.
        // e.g., Shifting '1' at pos 63 by 1.
        // ------------------------------------------------------------
        a = 64'h8000000000000000; // Bit 63 is set
        b = 64'd1;
        #10;
        check_result("MSB << 1 (becomes 0)", 64'd0);

        // ------------------------------------------------------------
        // Test 7: Verify 'fill_bit' is 0 (Logical Shift)
        // Logic: When we shift left, the new bits on the right must be 0.
        // ------------------------------------------------------------
        a = 64'hFFFFFFFFFFFFFFFF;
        b = 64'd8;
        #10;
        check_result("All 1s << 8", 64'hFFFFFFFFFFFFFF00);

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