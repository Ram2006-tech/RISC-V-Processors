`include "data_memory.v"

module data_memory_tb;
    reg        clk;
    reg [63:0] address;
    reg [63:0] write_data;
    reg        MemRead, MemWrite;
    wire[63:0] read_data;

    data_memory DUT(.clk(clk),.address(address),
        .write_data(write_data),.MemRead(MemRead),
        .MemWrite(MemWrite),.read_data(read_data));

    initial clk=0;
    always #5 clk=~clk;

    initial begin
        $dumpfile("gtk_data_memory.vcd");
        $dumpvars(0, data_memory_tb);
    end

    initial begin
        $display("=================================================");
        $display("  DATA MEMORY TESTBENCH (Big-Endian 64-bit)     ");
        $display("=================================================");

        MemRead=0; MemWrite=0;

        address=64'd0; write_data=64'hDEADBEEFCAFEBABE; MemWrite=1; MemRead=0;
        @(posedge clk); #1; MemWrite=0;
        MemRead=1; #1;
        $display("Write 0xDEADBEEFCAFEBABE @ addr=0");
        $display("Read  back = %016h | %s",
            read_data,
            (read_data==64'hDEADBEEFCAFEBABE)?"PASS":"FAIL");

        address=64'd8; write_data=64'd15; MemWrite=1; MemRead=0;
        @(posedge clk); #1; MemWrite=0;
        MemRead=1; #1;
        $display("Write 15 @ addr=8 | Read=%0d (Exp:15) | %s",
            read_data, (read_data==15)?"PASS":"FAIL");

        address=64'd16; write_data=64'hFFFFFFFFFFFFFFFB; MemWrite=1; MemRead=0;
        @(posedge clk); #1; MemWrite=0;
        MemRead=1; #1;
        $display("Write -5 @ addr=16 | Read=%0d (Exp:-5) | %s",
            $signed(read_data), ($signed(read_data)==-5)?"PASS":"FAIL");

        address=64'd0; MemRead=1; MemWrite=0; #1;
        $display("Big-endian check: mem[0]=%h (Exp:DE) | %s",
            DUT.mem[0], (DUT.mem[0]==8'hDE)?"PASS":"FAIL");

        $display("=================================================");
        $display("  GTKWave: gtkwave gtk_data_memory.vcd");
        $display("=================================================");
        $finish;
    end
endmodule
