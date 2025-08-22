`include "control_unit.v"

module control_unit_tb;
    reg  [6:0] opcode;
    wire       RegWrite, MemRead, MemWrite, Branch, ALUSrc, MemtoReg;
    wire [1:0] ALUOp;

    control_unit DUT(.opcode(opcode),
        .RegWrite(RegWrite),.MemRead(MemRead),.MemWrite(MemWrite),
        .Branch(Branch),.ALUSrc(ALUSrc),.MemtoReg(MemtoReg),.ALUOp(ALUOp));

    initial begin
        $dumpfile("gtk_control_unit.vcd");
        $dumpvars(0, control_unit_tb);
    end

    task test;
        input [6:0]  op;
        input [47:0] iname;
        input exp_RegWrite, exp_MemRead, exp_MemWrite;
        input exp_Branch,   exp_ALUSrc,  exp_MemtoReg;
        input [1:0] exp_ALUOp;
        reg pass;
        begin
            opcode = op; #10;
            pass = (RegWrite==exp_RegWrite && MemRead==exp_MemRead &&
                    MemWrite==exp_MemWrite && Branch==exp_Branch &&
                    ALUSrc==exp_ALUSrc && MemtoReg==exp_MemtoReg &&
                    ALUOp==exp_ALUOp);
            $display("%-8s | opcode=%b | RW=%b MR=%b MW=%b Br=%b AS=%b M2R=%b ALUOp=%b | %s",
                iname, op,
                RegWrite,MemRead,MemWrite,Branch,ALUSrc,MemtoReg,ALUOp,
                pass ? "PASS" : "FAIL");
        end
    endtask

    initial begin
        $display("=================================================================");
        $display("  CONTROL UNIT TESTBENCH                                        ");
        $display("=================================================================");
        $display("%-8s | %-38s | Status","Instr","opcode | RW MR MW Br AS M2R ALUOp");
        $display("-----------------------------------------------------------------");

        test(7'b0110011, "R-type", 1, 0, 0,  0, 0, 0,  2'b10);
        test(7'b0010011, "addi  ", 1, 0, 0,  0, 1, 0,  2'b00);
        test(7'b0000011, "ld    ", 1, 1, 0,  0, 1, 1,  2'b00);
        test(7'b0100011, "sd    ", 0, 0, 1,  0, 1, 0,  2'b00);
        test(7'b1100011, "beq   ", 0, 0, 0,  1, 0, 0,  2'b01);

        $display("=================================================================");
        $display("  GTKWave: gtkwave gtk_control_unit.vcd");
        $display("=================================================================");
        $finish;
    end
endmodule
