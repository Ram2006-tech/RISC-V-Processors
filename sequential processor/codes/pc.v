// pc.v - 64-bit Program Counter
module pc(
    input         clk,
    input         reset,
    input  [63:0] pc_in,
    output reg [63:0] pc_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 64'd0;
        else
            pc_out <= pc_in;
    end
endmodule
