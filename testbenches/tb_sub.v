`timescale 1ns / 1ps

module tb_sub;

    // ==========================================
    // 1. Signal Declaration
    // ==========================================
    reg [63:0] a;
    reg [63:0] b;
    
    wire [63:0] res;
    wire cout;
    wire ovf;

    // ==========================================
    // 2. Instantiate the Subtractor (UUT)
    // ==========================================
    op_sub uut (
        .a(a), 
        .b(b), 
        .res(res), 
        .cout(cout), 
        .ovf(ovf)
    );

    // ==========================================
    // 3. Test Stimulus
    // ==========================================
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_sub);

        $display("----------------------------------------------------------------------");
        $display("Testing 64-bit Subtractor (op_sub)");
        $display("Note on Cout: In subtraction, Cout=1 usually means 'No Borrow' (A >= B)");
        $display("              and Cout=0 usually means 'Borrow' (A < B).");
        $display("----------------------------------------------------------------------");

        // ------------------------------------------------------------
        // Test 1: Simple Subtraction (Positive Result)
        // ------------------------------------------------------------
        a = 64'd100; b = 64'd40; 
        #10;
        check_result("100 - 40", 64'd60, 0);

        // ------------------------------------------------------------
        // Test 2: Zero Result
        // ------------------------------------------------------------
        a = 64'd555; b = 64'd555; 
        #10;
        check_result("555 - 555", 64'd0, 0);

        // ------------------------------------------------------------
        // Test 3: Negative Result (Borrow Check)
        // Logic: 10 - 20 = -10. In 2's complement, -10 is ...FFFFFFF6
        // Cout should be 0 (indicating a borrow occurred).
        // ------------------------------------------------------------
        a = 64'd10; b = 64'd20;
        #10;
        $display("Test: 10 - 20 (Negative Result)");
        // -10 in 64-bit hex is FFFFFFFFFFFFFFF6
        if (res == 64'hFFFFFFFFFFFFFFF6 && cout == 0)
            $display("  [PASS] Result: %d (as signed: -10), Cout: %b (Borrow)", res, cout);
        else
            $display("  [FAIL] Result: %h, Cout: %b", res, cout);


        // ------------------------------------------------------------
        // Test 4: Signed Overflow (Max Positive - Negative)
        // Logic: Max Pos - (-1) is like Max Pos + 1. This causes overflow.
        // ------------------------------------------------------------
        a = 64'h7FFFFFFFFFFFFFFF; // Max Positive
        b = 64'hFFFFFFFFFFFFFFFF; // -1 (Signed)
        #10;
        $display("Test: Overflow (Max Pos - (-1))");
        if (ovf == 1 && res[63] == 1) // Result becomes negative (error)
            $display("  [PASS] Overflow Triggered. Res: %h", res);
        else
            $display("  [FAIL] Overflow NOT Triggered. Res: %h, OVF: %b", res, ovf);


        // ------------------------------------------------------------
        // Test 5: Signed Overflow (Min Negative - Positive)
        // Logic: Min Neg - 1 becomes even more negative (underflow wraparound to positive)
        // ------------------------------------------------------------
        a = 64'h8000000000000000; // Min Negative
        b = 64'd1;
        #10;
        $display("Test: Overflow (Min Neg - 1)");
        if (ovf == 1 && res[63] == 0) // Result becomes positive (error)
            $display("  [PASS] Overflow Triggered. Res: %h", res);
        else
            $display("  [FAIL] Overflow NOT Triggered. Res: %h, OVF: %b", res, ovf);

        $display("----------------------------------------------------------------------");
        $finish;
    end

    // Helper task
    task check_result;
        input [255:0] test_name;
        input [63:0] expected_res;
        input expected_ovf;
        begin
            if (res === expected_res && ovf === expected_ovf)
                $display("Test: %0s \n  [PASS] %d - %d = %d", test_name, a, b, res);
            else
                $display("Test: %0s \n  [FAIL] %d - %d = %d (Expected: %d, Ovf: %b)", 
                         test_name, a, b, res, expected_res, expected_ovf);
        end
    endtask

endmodule