`include "alu_control.v"

module alu_control_tb;
    reg  [1:0] ALUOp;
    reg  [2:0] funct3;
    reg  [6:0] funct7;
    wire [3:0] alu_ctrl;

    alu_control DUT(.ALUOp(ALUOp),.funct3(funct3),
                    .funct7(funct7),.alu_ctrl(alu_ctrl));

    initial begin
        $dumpfile("gtk_alu_control.vcd");
        $dumpvars(0, alu_control_tb);
    end

    task test;
        input [1:0] op;
        input [2:0] f3;
        input [6:0] f7;
        input [3:0] expected;
        input [47:0] iname;
        begin
            ALUOp=op; funct3=f3; funct7=f7; #10;
            $display("%-8s | ALUOp=%b funct3=%b funct7=%b | alu_ctrl=%b | %s",
                iname, op, f3, f7, alu_ctrl,
                (alu_ctrl==expected) ? "PASS" : "FAIL");
        end
    endtask

    initial begin
        $display("=================================================");
        $display("  ALU CONTROL TESTBENCH                         ");
        $display("=================================================");
        $display("%-8s | %-30s | ctrl | Status","Instr","ALUOp funct3 funct7");
        $display("-------------------------------------------------");

        test(2'b00, 3'b000, 7'b0000000, 4'b0000, "ADD(ld)");
        test(2'b01, 3'b000, 7'b0000000, 4'b1000, "SUB(beq)");
        test(2'b10, 3'b000, 7'b0000000, 4'b0000, "ADD(R)");
        test(2'b10, 3'b000, 7'b0100000, 4'b1000, "SUB(R)");
        test(2'b10, 3'b110, 7'b0000000, 4'b0110, "OR(R)");
        test(2'b10, 3'b111, 7'b0000000, 4'b0111, "AND(R)");

        $display("=================================================");
        $display("  GTKWave: gtkwave gtk_alu_control.vcd");
        $display("=================================================");
        $finish;
    end
endmodule
