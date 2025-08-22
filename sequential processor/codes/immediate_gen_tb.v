`include "immediate_gen.v"

module immediate_gen_tb;
    reg  [31:0] instruction;
    wire [63:0] immediate;

    immediate_gen DUT(.instruction(instruction),.immediate(immediate));

    initial begin
        $dumpfile("gtk_immediate_gen.vcd");
        $dumpvars(0, immediate_gen_tb);
    end

    task test;
        input [31:0] instr;
        input [63:0] expected;
        input [63:0] iname;
        begin
            instruction = instr; #10;
            $display("instr=%h | imm=%016h (%0d) | %s",
                instr, immediate, $signed(immediate),
                (immediate==expected) ? "PASS" : "FAIL");
        end
    endtask

    initial begin
        $display("=================================================");
        $display("  IMMEDIATE GEN TESTBENCH                       ");
        $display("=================================================");

        // addi x1,x0,5  -> I-type imm=5
        test(32'h00500093, 64'd5,              "addi +5 ");
        // addi x1,x0,-1 -> I-type imm=-1
        test(32'hFFF00093, 64'hFFFFFFFFFFFFFFFF, "addi -1 ");
        // addi x1,x0,2048 -> imm=2047 max positive
        test(32'h7FF00093, 64'd2047,           "addi max");
        // sd x1,24(x5)  -> S-type imm=24
        test(32'h0012B023 | (24>>5)<<25 | (24&31)<<7,
             64'd24,                           "sd  +24 ");
        // beq x4,x5,8   -> B-type imm=8
        test(32'h00520463, 64'd8,              "beq +8  ");
        // beq backward  -> B-type imm=-8
        test(32'hFE520CE3, 64'hFFFFFFFFFFFFFFF8, "beq -8  ");

        $display("=================================================");
        $display("  GTKWave: gtkwave gtk_immediate_gen.vcd");
        $display("=================================================");
        $finish;
    end
endmodule
