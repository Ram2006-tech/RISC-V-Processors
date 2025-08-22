`include "pc.v"

module pc_tb;
    reg        clk, reset;
    reg [63:0] pc_in;
    wire[63:0] pc_out;

    pc DUT(.clk(clk),.reset(reset),.pc_in(pc_in),.pc_out(pc_out));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("gtk_pc.vcd");
        $dumpvars(0, pc_tb);
    end

    initial begin
        $display("=================================================");
        $display("  PC TESTBENCH                                  ");
        $display("=================================================");
        reset=1; pc_in=64'd0;
        @(posedge clk); #1;
        $display("After reset  | pc_out=%0d (Exp:0) | %s",
            pc_out, (pc_out==0)?"PASS":"FAIL");
        reset=0;
        pc_in=64'd4; @(posedge clk); #1;
        $display("PC+4 (4)     | pc_out=%0d (Exp:4) | %s",
            pc_out, (pc_out==4)?"PASS":"FAIL");

        pc_in=64'd8; @(posedge clk); #1;
        $display("PC+4 (8)     | pc_out=%0d (Exp:8) | %s",
            pc_out, (pc_out==8)?"PASS":"FAIL");
        pc_in=64'd48; @(posedge clk); #1;
        $display("Branch (48)  | pc_out=%0d (Exp:48) | %s",
            pc_out, (pc_out==48)?"PASS":"FAIL");

        pc_in=64'd52; @(posedge clk); #1;
        $display("PC+4 (52)    | pc_out=%0d (Exp:52) | %s",
            pc_out, (pc_out==52)?"PASS":"FAIL");

        reset=1; @(posedge clk); #1;
        $display("Reset again  | pc_out=%0d (Exp:0) | %s",
            pc_out, (pc_out==0)?"PASS":"FAIL");

        $display("=================================================");
        $display("  GTKWave: gtkwave gtk_pc.vcd");
        $display("=================================================");
        $finish;
    end
endmodule
