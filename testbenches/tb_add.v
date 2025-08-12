`timescale 1ns / 1ps

module tb_add;

    // ==========================================
    // 1. Signal Declaration
    // ==========================================
    reg [63:0] a;
    reg [63:0] b;
    
    wire [63:0] res;
    wire cout;
    wire ovf;

    // ==========================================
    // 2. Instantiate the Unit Under Test (UUT)
    // ==========================================
    op_add uut (
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
        // Setup for waveform viewing (optional)
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_add);

        $display("----------------------------------------------------------------------");
        $display("Testing 64-bit Adder (op_add)");
        $display("----------------------------------------------------------------------");

        // ------------------------------------------------------------
        // Test 1: Basic Addition (Zero check)
        // ------------------------------------------------------------
        a = 64'd0; b = 64'd0; 
        #10;
        check_result("0 + 0", 64'd0, 0, 0);

        // ------------------------------------------------------------
        // Test 2: Standard Random Addition
        // ------------------------------------------------------------
        a = 64'd123456789; b = 64'd987654321; 
        #10;
        check_result("Standard Add", a + b, 0, 0);

        // ------------------------------------------------------------
        // Test 3: Carry Out Check (Unsigned Overflow)
        // Logic: Max Unsigned Value + 1 should result in 0 with Cout=1
        // ------------------------------------------------------------
        a = 64'hFFFFFFFFFFFFFFFF; // All 1s
        b = 64'd1; 
        #10;
        $display("Test: Carry Out Trigger (Max Unsigned + 1)");
        if (res == 0 && cout == 1 && ovf == 0) 
            $display("  [PASS] Result: %h, Cout: %b", res, cout);
        else 
            $display("  [FAIL] Result: %h, Cout: %b (Expected Res: 0, Cout: 1)", res, cout);

        // ------------------------------------------------------------
        // Test 4: Signed Overflow Check (Positive + Positive = Negative)
        // Logic: Max Positive (0111...) + 1 -> Negative (1000...)
        // This is invalid in signed arithmetic, so OVF should be 1.
        // ------------------------------------------------------------
        a = 64'h7FFFFFFFFFFFFFFF; // Max Positive (Signed)
        b = 64'd1;
        #10;
        $display("Test: Signed Overflow (Max Pos + 1)");
        // Expected: Result has sign bit 1 (negative), OVF is 1
        if (ovf == 1 && res[63] == 1) 
            $display("  [PASS] Overflow detected correctly. Res: %h (Negative)", res);
        else 
            $display("  [FAIL] Overflow NOT detected. OVF: %b, Res: %h", ovf, res);

        // ------------------------------------------------------------
        // Test 5: Signed Overflow Check (Negative + Negative = Positive)
        // Logic: Min Negative (1000...) + (-1) -> Positive/Underflow
        // ------------------------------------------------------------
        a = 64'h8000000000000000; // Min Negative (Signed)
        b = 64'hFFFFFFFFFFFFFFFF; // -1 (Signed)
        #10;
        $display("Test: Signed Overflow (Min Neg + -1)");
        if (ovf == 1 && res[63] == 0) 
            $display("  [PASS] Overflow detected correctly. Res: %h (Positive)", res);
        else 
            $display("  [FAIL] Overflow NOT detected. OVF: %b, Res: %h", ovf, res);

        $display("----------------------------------------------------------------------");
        $finish;
    end

    // Helper task to clean up the display code
    task check_result;
        input [255:0] test_name;
        input [63:0] expected_res;
        input expected_cout;
        input expected_ovf;
        begin
            if (res === expected_res && cout === expected_cout && ovf === expected_ovf)
                $display("Test: %0s \n  [PASS] %d + %d = %d", test_name, a, b, res);
            else
                $display("Test: %0s \n  [FAIL] %d + %d = %d (Expected: %d, Cout: %b, Ovf: %b)", 
                         test_name, a, b, res, expected_res, expected_cout, expected_ovf);
        end
    endtask

endmodule