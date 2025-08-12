`timescale 1ns / 1ps

module tb_sltu;

    // ==========================================
    // 1. Signal Declaration
    // ==========================================
    reg [63:0] a;
    reg [63:0] b;
    
    wire [63:0] res;

    // ==========================================
    // 2. Instantiate the Unit Under Test (UUT)
    // ==========================================
    op_sltu uut (
        .a(a), 
        .b(b), 
        .res(res)
    );

    // ==========================================
    // 3. Test Stimulus
    // ==========================================
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_sltu);

        $display("----------------------------------------------------------------------");
        $display("Testing 64-bit Set Less Than UNSIGNED (SLTU)");
        $display("Logic: Returns 1 if (a < b) treating inputs as unsigned integers");
        $display("----------------------------------------------------------------------");

        // ------------------------------------------------------------
        // Test 1: Basic Case (10 < 20) -> True
        // ------------------------------------------------------------
        a = 64'd10; b = 64'd20; 
        #10;
        check_result("10 < 20", 64'd1);

        // ------------------------------------------------------------
        // Test 2: Basic Case (20 < 10) -> False
        // ------------------------------------------------------------
        a = 64'd20; b = 64'd10;
        #10;
        check_result("20 < 10", 64'd0);

        // ------------------------------------------------------------
        // Test 3: Equality (50 < 50) -> False
        // ------------------------------------------------------------
        a = 64'd50; b = 64'd50;
        #10;
        check_result("50 < 50", 64'd0);

        // ============================================================
        // CRITICAL DIFFERENCES FROM SLT (SIGNED)
        // ============================================================

        // ------------------------------------------------------------
        // Test 4: "Negative" vs Small Positive
        // Case: (-1) vs 1
        // Signed Logic:   -1 < 1 is TRUE.
        // Unsigned Logic: FFFF... (Max Int) < 1 is FALSE.
        // ------------------------------------------------------------
        a = 64'hFFFFFFFFFFFFFFFF; // -1 in signed, Max Int in Unsigned
        b = 64'd1;
        #10;
        check_result("MaxUnsigned < 1", 64'd0); 

        // ------------------------------------------------------------
        // Test 5: Small Positive vs "Negative"
        // Case: 10 vs (-5)
        // Signed Logic:   10 < -5 is FALSE.
        // Unsigned Logic: 10 < FFFF...FB (Huge Number) is TRUE.
        // ------------------------------------------------------------
        a = 64'd10; 
        b = -64'd5; // Becomes a huge unsigned number
        #10;
        check_result("10 < (Huge Number)", 64'd1);

        // ------------------------------------------------------------
        // Test 6: Zero Check
        // 0 < 1 -> True
        // ------------------------------------------------------------
        a = 64'd0; b = 64'd1;
        #10;
        check_result("0 < 1", 64'd1);

        $display("----------------------------------------------------------------------");
        $finish;
    end

    // Helper task
    task check_result;
        input [255:0] test_name;
        input [63:0] expected;
        begin
            if (res === expected)
                $display("Test: %0s \n  [PASS] A=%h, B=%h -> Res: %d", test_name, a, b, res);
            else
                $display("Test: %0s \n  [FAIL] A=%h, B=%h -> Got: %d (Expected: %d)", 
                         test_name, a, b, res, expected);
        end
    endtask

endmodule