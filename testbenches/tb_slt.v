`timescale 1ns / 1ps

module tb_slt;

    // ==========================================
    // 1. Signal Declaration
    // ==========================================
    reg [63:0] a;
    reg [63:0] b;
    
    wire [63:0] res;   // Result will be 1 (true) or 0 (false)

    // ==========================================
    // 2. Instantiate the Unit Under Test (UUT)
    // ==========================================
    op_slt uut (
        .a(a), 
        .b(b), 
        .res(res)
    );

    // ==========================================
    // 3. Test Stimulus
    // ==========================================
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_slt);

        $display("----------------------------------------------------------------------");
        $display("Testing 64-bit Set Less Than (SLT)");
        $display("Logic: Returns 1 if (a < b) using signed arithmetic");
        $display("----------------------------------------------------------------------");

        // ------------------------------------------------------------
        // Test 1: Basic Positive Case (10 < 20) -> True
        // ------------------------------------------------------------
        a = 64'd10; b = 64'd20; 
        #10;
        check_result("10 < 20", 64'd1);

        // ------------------------------------------------------------
        // Test 2: Basic False Case (20 < 10) -> False
        // ------------------------------------------------------------
        a = 64'd20; b = 64'd10;
        #10;
        check_result("20 < 10", 64'd0);

        // ------------------------------------------------------------
        // Test 3: Equality Case (10 < 10) -> False
        // ------------------------------------------------------------
        a = 64'd10; b = 64'd10;
        #10;
        check_result("10 < 10", 64'd0);

        // ------------------------------------------------------------
        // Test 4: Negative vs Positive (-5 < 10) -> True
        // Logic: -5 is F...FB. Subtraction gives negative result.
        // ------------------------------------------------------------
        a = -64'd5; b = 64'd10;
        #10;
        check_result("-5 < 10", 64'd1);

        // ------------------------------------------------------------
        // Test 5: Positive vs Negative (10 < -5) -> False
        // Logic: 10 - (-5) = 15. Result is positive.
        // ------------------------------------------------------------
        a = 64'd10; b = -64'd5;
        #10;
        check_result("10 < -5", 64'd0);

        // ------------------------------------------------------------
        // Test 6: Critical Overflow Case (Min Int < 1) -> True
        // Logic: (Min Int) - 1 causes UNDERFLOW to Max Positive.
        //        Result Sign = 0 (Positive, looks false), but Overflow = 1.
        //        SLT = Sign XOR Ovf = 0 ^ 1 = 1 (True).
        //        This proves your XOR logic is working correctly.
        // ------------------------------------------------------------
        a = 64'h8000000000000000; // Min Negative
        b = 64'd1;
        #10;
        check_result("Min Neg < 1 (Overflow Case)", 64'd1);

        // ------------------------------------------------------------
        // Test 7: Critical Overflow Case (Max Pos < -1) -> False
        // Logic: (Max Pos) - (-1) causes OVERFLOW to Min Negative.
        //        Result Sign = 1 (Negative, looks true), but Overflow = 1.
        //        SLT = Sign XOR Ovf = 1 ^ 1 = 0 (False).
        // ------------------------------------------------------------
        a = 64'h7FFFFFFFFFFFFFFF; // Max Positive
        b = -64'd1;
        #10;
        check_result("Max Pos < -1 (Overflow Case)", 64'd0);

        $display("----------------------------------------------------------------------");
        $finish;
    end

    // Helper task
    task check_result;
        input [255:0] test_name;
        input [63:0] expected;
        begin
            if (res === expected)
                $display("Test: %0s \n  [PASS] %d < %d -> Res: %d", test_name, $signed(a), $signed(b), res);
            else
                $display("Test: %0s \n  [FAIL] %d < %d -> Got: %d (Expected: %d)", 
                         test_name, $signed(a), $signed(b), res, expected);
        end
    endtask

endmodule