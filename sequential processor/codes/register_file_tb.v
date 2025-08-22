`include "register_file.v"

module register_file_tb;
    reg        clk, reset;
    reg  [4:0] read_reg1, read_reg2, write_reg;
    reg  [63:0] write_data;
    reg         reg_write_en;
    wire [63:0] read_data1, read_data2;

    register_file DUT(.clk(clk),.reset(reset),
        .read_reg1(read_reg1),.read_reg2(read_reg2),
        .write_reg(write_reg),.write_data(write_data),
        .reg_write_en(reg_write_en),
        .read_data1(read_data1),.read_data2(read_data2));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("gtk_register_file.vcd");
        $dumpvars(0, register_file_tb);
    end

    initial begin
        $display("=================================================");
        $display("  REGISTER FILE TESTBENCH                       ");
        $display("=================================================");


        reset=1; reg_write_en=0;
        write_reg=0; write_data=0;
        read_reg1=0; read_reg2=0;
        @(posedge clk); #1; reset=0;
        write_reg=5'd1; write_data=64'd100; reg_write_en=1;
        @(posedge clk); #1;
        read_reg1=5'd1; read_reg2=5'd0;
        #1;
        $display("Write x1=100 | Read x1=%0d (Exp:100) | Read x0=%0d (Exp:0) | %s",
            read_data1, read_data2,
            (read_data1==100 && read_data2==0) ? "PASS" : "FAIL");

        write_reg=5'd2; write_data=64'hFFFFFFFFFFFFFFFB; reg_write_en=1;
        @(posedge clk); #1;
        read_reg1=5'd2;
        #1;
        $display("Write x2=-5  | Read x2=%0d (Exp:-5)  | %s",
            $signed(read_data1),
            ($signed(read_data1)==-5) ? "PASS" : "FAIL");

        write_reg=5'd0; write_data=64'd99; reg_write_en=1;
        @(posedge clk); #1;
        read_reg1=5'd0; #1;
        $display("Write x0=99  | Read x0=%0d (Exp:0, hardwired) | %s",
            read_data1, (read_data1==0) ? "PASS" : "FAIL");

        read_reg1=5'd1; read_reg2=5'd2; #1;
        $display("Read x1=%0d x2=%0d simultaneously | %s",
            read_data1, $signed(read_data2),
            (read_data1==100 && $signed(read_data2)==-5) ? "PASS":"FAIL");

        $display("=================================================");
        $display("  GTKWave: gtkwave gtk_register_file.vcd");
        $display("=================================================");
        $finish;
    end
endmodule
