`timescale 1ns / 1ps

module tb_xor;

    // ==========================================
    // 1. Signal Declaration
    // ==========================================
    reg [63:0] a;
    reg [63:0] b;
    
    wire [63:0] res;

    // ==========================================
    // 2. Instantiate the XOR Module (UUT)
    // ==========================================
    op_xor uut (
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
        $dumpvars(0, tb_xor);

        $display("----------------------------------------------------------------------");
        $display("Testing 64-bit Bitwise XOR (op_xor)");
        $display("----------------------------------------------------------------------");

        // ------------------------------------------------------------
        // Test 1: Identity Check (XOR with 0s)
        // Logic: X ^ 0 = X. Bits should not change.
        // ------------------------------------------------------------
        a = 64'hDEADBEEFCAFEBABE; 
        b = 64'd0; 
        #10;
        check_result("Identity (X ^ 0)", a);

        // ------------------------------------------------------------
        // Test 2: Inverter Check (XOR with 1s)
        // Logic: X ^ 1 = ~X. All bits should flip (toggle).
        // ------------------------------------------------------------
        a = 64'h00000000FFFFFFFF; 
        b = 64'hFFFFFFFFFFFFFFFF; // All 1s
        #10;
        // 00...FF ^ FF...FF should result in FF...00
        check_result("Invert/Toggle (X ^ 1s)", 64'hFFFFFFFF00000000);

        // ------------------------------------------------------------
        // Test 3: Self-Inverse / Equality (XOR with Self)
        // Logic: X ^ X = 0. This is often used to clear registers or check equality.
        // ------------------------------------------------------------
        a = 64'h123456789ABCDEF0;
        b = 64'h123456789ABCDEF0;
        #10;
        check_result("Self-XOR (X ^ X)", 64'd0);

        // ------------------------------------------------------------
        // Test 4: Alternating Pattern Reconstruction
        // Logic: 1010... ^ 0101... = 1111...
        // ------------------------------------------------------------
        a = 64'hAAAAAAAAAAAAAAAA; // 1010...
        b = 64'h5555555555555555; // 0101...
        #10;
        check_result("Alternating Pattern", 64'hFFFFFFFFFFFFFFFF);

        // ------------------------------------------------------------
        // Test 5: Selective Toggling
        // Logic: Only toggle specific bits where B is 1
        // ------------------------------------------------------------
        a = 64'hF0F0F0F0F0F0F0F0;
        b = 64'hFFFF0000FFFF0000; // Toggle the upper halves of every 32-bit chunk
        // Expected: 
        // F0 ^ FF = 0F (Inverted)
        // F0 ^ 00 = F0 (Same)
        #10;
        check_result("Selective Toggle", 64'h0F0FF0F00F0FF0F0);

        $display("----------------------------------------------------------------------");
        $finish;
    end

    // Helper task
    task check_result;
        input [255:0] test_name;
        input [63:0] expected;
        begin
            if (res === expected)
                $display("Test: %0s \n  [PASS] %h ^ %h = %h", test_name, a, b, res);
            else
                $display("Test: %0s \n  [FAIL] %h ^ %h = %h (Expected: %h)", 
                         test_name, a, b, res, expected);
        end
    endtask

endmodule