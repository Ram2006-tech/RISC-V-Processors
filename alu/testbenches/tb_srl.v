`timescale 1ns / 1ps

module tb_srl;

    // ==========================================
    // 1. Signal Declaration
    // ==========================================
    reg [63:0] a;      // The value to shift
    reg [63:0] b;      // The shift amount
    
    wire [63:0] res;   // Result

    // ==========================================
    // 2. Instantiate the Unit Under Test (UUT)
    // ==========================================
    op_srl uut (
        .a(a), 
        .b(b), 
        .res(res)
    );

    // ==========================================
    // 3. Test Stimulus
    // ==========================================
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_srl);

        $display("----------------------------------------------------------------------");
        $display("Testing 64-bit Shift Right Logical (SRL)");
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
        // Test 2: Shift by 1 (Division by 2)
        // Logic: 4 (100) >> 1 becomes 2 (010).
        // ------------------------------------------------------------
        a = 64'd4;
        b = 64'd1;
        #10;
        check_result("4 >> 1", 64'd2);

        // ------------------------------------------------------------
        // Test 3: Zero Fill Check (MSB Shift)
        // Logic: The MSB is 1. After shifting right, the new MSB must be 0.
        // ------------------------------------------------------------
        a = 64'h8000000000000000; // Bit 63 is 1
        b = 64'd1;
        #10;
        // Expected: 1000... becomes 0100... (4000...)
        check_result("MSB >> 1 (Zero Fill)", 64'h4000000000000000);

        // ------------------------------------------------------------
        // Test 4: Shift by 4 (Nibble Shift)
        // Logic: F0 (11110000) >> 4 becomes 0F (00001111)
        // ------------------------------------------------------------
        a = 64'hF0;
        b = 64'd4;
        #10;
        check_result("F0 >> 4", 64'h0F);

        // ------------------------------------------------------------
        // Test 5: Shift by 32 (Halfway)
        // Logic: Upper 32 bits move to Lower 32 bits. Upper becomes 0.
        // ------------------------------------------------------------
        a = 64'hFFFFFFFF00000000;
        b = 64'd32;
        #10;
        check_result("Upper Half >> 32", 64'h00000000FFFFFFFF);

        // ------------------------------------------------------------
        // Test 6: Max Shift (Shift by 63)
        // Logic: The MSB moves all the way to the LSB.
        // ------------------------------------------------------------
        a = 64'h8000000000000000; 
        b = 64'd63;
        #10;
        check_result("MSB >> 63", 64'd1);

        // ------------------------------------------------------------
        // Test 7: Shift Out (Clear)
        // Logic: Shifting '1' (at pos 0) right by 1 should make it disappear.
        // ------------------------------------------------------------
        a = 64'd1;
        b = 64'd1;
        #10;
        check_result("1 >> 1 (Underflow)", 64'd0);

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