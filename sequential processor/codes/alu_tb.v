`include "alu.v"

module alu_tb;
    reg  [63:0] input1, input2;
    reg  [3:0]  control_signal;
    wire [63:0] result;
    wire        zero_flag;

    alu DUT(.input1(input1),.input2(input2),
            .control_signal(control_signal),
            .result(result),.zero_flag(zero_flag));

    initial begin
        $dumpfile("gtk_alu.vcd");
        $dumpvars(0, alu_tb);
    end

    task test;
        input [63:0] a, b;
        input [3:0]  op;
        input [63:0] expected;
        input [63:0] exp_zero;
        input [127:0] name;
        begin
            input1 = a; input2 = b; control_signal = op;
            #10;
            $display("%-6s | in1=%016h  in2=%016h | result=%016h | zero=%b | %s",
                (op==4'b0000)?"ADD":(op==4'b1000)?"SUB":(op==4'b0111)?"AND":"OR ",
                a, b, result, zero_flag,
                (result==expected && zero_flag==exp_zero[0]) ? "PASS" : "FAIL");
        end
    endtask

    initial begin
        $display("=================================================");
        $display("  ALU TESTBENCH                                  ");
        $display("=================================================");
        $display("%-6s | %-18s  %-18s | %-18s | zero | Status",
                 "Op","input1","input2","result");
        $display("-------------------------------------------------");

        // ADD
        test(64'd15,  64'd10,  4'b0000, 64'd25,  0, "ADD pos");
        test(64'd0,   64'd0,   4'b0000, 64'd0,   1, "ADD zero");
        test(64'hFFFFFFFFFFFFFFFF, 64'd1, 4'b0000, 64'd0, 1, "ADD overflow->0");

        // SUB
        test(64'd20,  64'd5,   4'b1000, 64'd15,  0, "SUB pos");
        test(64'd5,   64'd5,   4'b1000, 64'd0,   1, "SUB equal");
        test(64'd5,   64'd10,  4'b1000, 64'hFFFFFFFFFFFFFFFB, 0, "SUB neg");

        // AND
        test(64'hFF,  64'h0F,  4'b0111, 64'h0F,  0, "AND");
        test(64'hFF,  64'h00,  4'b0111, 64'h00,  1, "AND zero");

        // OR
        test(64'hF0,  64'h0F,  4'b0110, 64'hFF,  0, "OR");
        test(64'h00,  64'h00,  4'b0110, 64'h00,  1, "OR zero");

        $display("=================================================");
        $display("  GTKWave: gtkwave gtk_alu.vcd");
        $display("=================================================");
        $finish;
    end
endmodule
