// seq_tb.v 
`include "processor.v"
module seq_tb;
    reg clk, reset;
    integer cycle_count;
    integer fd;
    integer i;

    processor DUT(
        .clk(clk),
        .reset(reset)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    reg [63:0] prev_pc;
    reg        halted;
    reg        extra_cycle;

    initial begin
        cycle_count = 0;
        halted      = 0;
        extra_cycle = 0;
        prev_pc     = 64'hFFFFFFFFFFFFFFFF;
        reset = 1;
        @(posedge clk);
        #1;
        reset = 0;

        while (!halted) begin
            @(posedge clk);
            #1;
            cycle_count = cycle_count + 1;
            if (DUT.pc_out == prev_pc) begin
                halted      = 1;
                extra_cycle = 1; 
            end
            else if (DUT.instr == 32'h00000000) begin
                halted      = 1;
                extra_cycle = 1; 
            end
            else if (cycle_count >= 100000) begin
                halted = 1;
            end

            prev_pc = DUT.pc_out;
        end

        if (extra_cycle)
            cycle_count = cycle_count + 1;

        fd = $fopen("register_file.txt", "w");
        for (i = 0; i < 32; i = i + 1) begin
            if (i == 0)
                $fdisplay(fd, "%016h", 64'd0);
            else
                $fdisplay(fd, "%016h", DUT.RF.regs[i]);
        end
        $fdisplay(fd, "%0d", cycle_count);
        $fclose(fd);

        $finish;
    end

endmodule