// processor.v 
`include "pc.v"
`include "instruction_mem.v"
`include "control_unit.v"
`include "register_file.v"
`include "immediate_gen.v"
`include "alu_control.v"
`include "alu.v"
`include "data_memory.v"

module processor(
    input clk,
    input reset
);
    wire [63:0] pc_out, pc_next, pc_plus4, branch_target;
    wire [31:0] instr;
    wire        RegWrite, MemRead, MemWrite, Branch, ALUSrc, MemtoReg;
    wire [1:0]  ALUOp;
    wire [63:0] read_data1, read_data2, write_back_data;
    wire [63:0] immediate;
    wire [3:0]  alu_ctrl;
    wire [63:0] alu_input2, alu_result;
    wire        zero_flag;
    wire [63:0] mem_read_data;


    wire        branch_taken;

    pc PC(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_next),
        .pc_out(pc_out)
    );
    assign pc_plus4 = pc_out + 64'd4;
    assign branch_target = pc_out + immediate;
    assign branch_taken = Branch & zero_flag;
    assign pc_next = branch_taken ? branch_target : pc_plus4;
    instruction_mem IMEM(
        .addr(pc_out),
        .instr(instr)
    );

    control_unit CU(
        .opcode(instr[6:0]),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp)
    );
    register_file RF(
        .clk(clk),
        .reset(reset),
        .read_reg1(instr[19:15]),
        .read_reg2(instr[24:20]),
        .write_reg(instr[11:7]),
        .write_data(write_back_data),
        .reg_write_en(RegWrite),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
    immediate_gen IMM(
        .instruction(instr),
        .immediate(immediate)
    );
    alu_control ALUCTRL(
        .ALUOp(ALUOp),
        .funct3(instr[14:12]),
        .funct7(instr[31:25]),
        .alu_ctrl(alu_ctrl)
    );
    assign alu_input2 = ALUSrc ? immediate : read_data2;
    alu ALU(
        .input1(read_data1),
        .input2(alu_input2),
        .control_signal(alu_ctrl),
        .result(alu_result),
        .zero_flag(zero_flag)
    );
    data_memory DMEM(
        .clk(clk),
        .address(alu_result),
        .write_data(read_data2),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .read_data(mem_read_data)
    );
    assign write_back_data = MemtoReg ? mem_read_data : alu_result;

endmodule
