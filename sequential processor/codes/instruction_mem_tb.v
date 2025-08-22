`include "instruction_mem.v"

module instruction_mem_tb;
    reg  [63:0] addr;
    wire [31:0] instr;

    instruction_mem DUT(.addr(addr),.instr(instr));

    initial begin
        $dumpfile("gtk_instruction_mem.vcd");
        $dumpvars(0, instruction_mem_tb);
    end

    initial begin
        $display("=================================================");
        $display("  INSTRUCTION MEMORY TESTBENCH (Big-Endian)     ");
        $display("  Using TA sample instructions.txt              ");
        $display("=================================================");
        $display("%-6s | %-10s | Decoded opcode","Addr","Instr");
        $display("-------------------------------------------------");

        // Read instructions at each PC (TA sample program)
        addr=0;  #10; $display("PC=%-3d | %h | opcode=%b (addi)", addr, instr, instr[6:0]);
        addr=4;  #10; $display("PC=%-3d | %h | opcode=%b (addi)", addr, instr, instr[6:0]);
        addr=8;  #10; $display("PC=%-3d | %h | opcode=%b (add) ", addr, instr, instr[6:0]);
        addr=12; #10; $display("PC=%-3d | %h | opcode=%b (sub) ", addr, instr, instr[6:0]);
        addr=48; #10; $display("PC=%-3d | %h | opcode=%b (beq) ", addr, instr, instr[6:0]);
        addr=56; #10; $display("PC=%-3d | %h | opcode=%b (add) ", addr, instr, instr[6:0]);
        addr=60; #10; $display("PC=%-3d | %h | (past end, Exp:00000000) | %s",
                          addr, instr, (instr==32'h0)?"PASS":"FAIL");

        $display("=================================================");
        $display("  GTKWave: gtkwave gtk_instruction_mem.vcd");
        $display("=================================================");
        $finish;
    end
endmodule
