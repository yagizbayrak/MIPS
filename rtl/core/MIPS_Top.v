// Five-stage pipelined MIPS core with full forwarding, load-use stalling and branch and jump flushing.
module MIPS_Top (
    input  wire clk,
    input  wire reset
);
reg  [31:0] PC;
wire [31:0] pc_plus4;
wire [31:0] instruction;
wire [31:0] next_pc;
wire [31:0] jump_target;
wire [31:0] branch_target;
wire [31:0] branch_offset;
wire        branch_taken;
wire        jump_taken;
wire        flush_front;
wire        stall_pc;
wire        stall_IF_ID;
wire        bubble_ID_EX;
wire [31:0] IF_ID_pc_plus4;
wire [31:0] IF_ID_instruction;
wire [4:0]  IF_ID_rs;
wire [4:0]  IF_ID_rt;
wire [4:0]  IF_ID_rd;
wire [4:0]  IF_ID_shamt;
wire        RegDst;
wire        Jump;
wire        Branch;
wire        BranchNE;
wire        MemRead;
wire        MemtoReg;
wire        MemWrite;
wire        ALUSrc;
wire        RegWrite;
wire        SignZero;
wire [1:0]  ALUOp;
wire [3:0]  alu_op;
wire [31:0] read_data1;
wire [31:0] read_data2;
wire [31:0] sign_ext_imm;
wire [31:0] zero_ext_imm;
wire [31:0] imm_ext;
wire        ID_EX_RegWrite;
wire        ID_EX_MemtoReg;
wire        ID_EX_MemRead;
wire        ID_EX_MemWrite;
wire        ID_EX_Branch;
wire        ID_EX_BranchNE;
wire        ID_EX_ALUSrc;
wire        ID_EX_RegDst;
wire [3:0]  ID_EX_alu_op;
wire [31:0] ID_EX_pc_plus4;
wire [31:0] ID_EX_read_data1;
wire [31:0] ID_EX_read_data2;
wire [31:0] ID_EX_imm_ext;
wire [4:0]  ID_EX_rs;
wire [4:0]  ID_EX_rt;
wire [4:0]  ID_EX_rd;
wire [4:0]  ID_EX_shamt;
wire [4:0]  ID_EX_write_register;
wire [1:0]  forwardA;
wire [1:0]  forwardB;
wire [31:0] fwd_A;
wire [31:0] fwd_B;
wire [31:0] alu_B;
wire        alu_zero;
wire        alu_overflow;
wire [31:0] alu_result;
wire        EX_MEM_RegWrite;
wire        EX_MEM_MemtoReg;
wire        EX_MEM_MemRead;
wire        EX_MEM_MemWrite;
wire [31:0] EX_MEM_alu_result;
wire [31:0] EX_MEM_write_data;
wire [4:0]  EX_MEM_write_register;
wire [31:0] mem_read_data;
wire        MEM_WB_RegWrite;
wire        MEM_WB_MemtoReg;
wire [31:0] MEM_WB_alu_result;
wire [31:0] MEM_WB_mem_data;
wire [4:0]  MEM_WB_write_register;
wire [31:0] write_back_data;
assign pc_plus4    = PC + 32'd4;
assign flush_front = branch_taken | jump_taken;
assign next_pc     = branch_taken ? branch_target : (jump_taken ? jump_target : pc_plus4);
always @(posedge clk) begin
    if (reset)
        PC <= 32'd0;
    else if (!stall_pc | flush_front)
        PC <= next_pc;
end
ins_mem inst_mem_inst (
    .addr_inst(PC[8:2]),
    .cur_inst(instruction)
);
IF_ID if_id_inst (
    .clk(clk),
    .reset(reset),
    .stall(stall_IF_ID),
    .flush(flush_front),
    .i_pc_plus4(pc_plus4),
    .i_instruction(instruction),
    .o_pc_plus4(IF_ID_pc_plus4),
    .o_instruction(IF_ID_instruction)
);
assign IF_ID_rs    = IF_ID_instruction[25:21];
assign IF_ID_rt    = IF_ID_instruction[20:16];
assign IF_ID_rd    = IF_ID_instruction[15:11];
assign IF_ID_shamt = IF_ID_instruction[10:6];
control control_inst (
    .instruction(IF_ID_instruction),
    .RegDst(RegDst),
    .Jump(Jump),
    .Branch(Branch),
    .BranchNE(BranchNE),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .ALUOp(ALUOp),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .SignZero(SignZero)
);
ALUcontrol alu_control_inst (
    .instruction(IF_ID_instruction),
    .ALUop(ALUOp),
    .o_ALUcontrol(alu_op)
);
registers regs (
    .clk(clk),
    .reg_write(MEM_WB_RegWrite),
    .r_reg_1(IF_ID_rs),
    .r_reg_2(IF_ID_rt),
    .write_register(MEM_WB_write_register),
    .write_data(write_back_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);
sign_extend sign_extend_inst (
    .i_inst(IF_ID_instruction[15:0]),
    .o_inst(sign_ext_imm)
);
zero_extend zero_extend_inst (
    .i_inst(IF_ID_instruction[15:0]),
    .o_inst(zero_ext_imm)
);
mux_32 imm_mux (
    .address(SignZero),
    .i_1(zero_ext_imm),
    .i_0(sign_ext_imm),
    .out(imm_ext)
);
assign jump_target = {IF_ID_pc_plus4[31:28], IF_ID_instruction[25:0], 2'b00};
assign jump_taken  = Jump;
hazard_unit hazard_inst (
    .ID_EX_MemRead(ID_EX_MemRead),
    .ID_EX_rt(ID_EX_rt),
    .IF_ID_rs(IF_ID_rs),
    .IF_ID_rt(IF_ID_rt),
    .stall_pc(stall_pc),
    .stall_IF_ID(stall_IF_ID),
    .bubble_ID_EX(bubble_ID_EX)
);
ID_EX id_ex_inst (
    .clk(clk),
    .reset(reset),
    .flush(bubble_ID_EX | branch_taken),
    .i_RegWrite(RegWrite),
    .i_MemtoReg(MemtoReg),
    .i_MemRead(MemRead),
    .i_MemWrite(MemWrite),
    .i_Branch(Branch),
    .i_BranchNE(BranchNE),
    .i_ALUSrc(ALUSrc),
    .i_RegDst(RegDst),
    .i_alu_op(alu_op),
    .i_pc_plus4(IF_ID_pc_plus4),
    .i_read_data1(read_data1),
    .i_read_data2(read_data2),
    .i_imm_ext(imm_ext),
    .i_rs(IF_ID_rs),
    .i_rt(IF_ID_rt),
    .i_rd(IF_ID_rd),
    .i_shamt(IF_ID_shamt),
    .o_RegWrite(ID_EX_RegWrite),
    .o_MemtoReg(ID_EX_MemtoReg),
    .o_MemRead(ID_EX_MemRead),
    .o_MemWrite(ID_EX_MemWrite),
    .o_Branch(ID_EX_Branch),
    .o_BranchNE(ID_EX_BranchNE),
    .o_ALUSrc(ID_EX_ALUSrc),
    .o_RegDst(ID_EX_RegDst),
    .o_alu_op(ID_EX_alu_op),
    .o_pc_plus4(ID_EX_pc_plus4),
    .o_read_data1(ID_EX_read_data1),
    .o_read_data2(ID_EX_read_data2),
    .o_imm_ext(ID_EX_imm_ext),
    .o_rs(ID_EX_rs),
    .o_rt(ID_EX_rt),
    .o_rd(ID_EX_rd),
    .o_shamt(ID_EX_shamt)
);
forwarding_unit forwarding_inst (
    .ID_EX_rs(ID_EX_rs),
    .ID_EX_rt(ID_EX_rt),
    .EX_MEM_write_register(EX_MEM_write_register),
    .EX_MEM_RegWrite(EX_MEM_RegWrite),
    .MEM_WB_write_register(MEM_WB_write_register),
    .MEM_WB_RegWrite(MEM_WB_RegWrite),
    .forwardA(forwardA),
    .forwardB(forwardB)
);
assign fwd_A = (forwardA == 2'b10) ? EX_MEM_alu_result :
               (forwardA == 2'b01) ? write_back_data : ID_EX_read_data1;
assign fwd_B = (forwardB == 2'b10) ? EX_MEM_alu_result :
               (forwardB == 2'b01) ? write_back_data : ID_EX_read_data2;
assign alu_B = ID_EX_ALUSrc ? ID_EX_imm_ext : fwd_B;
assign ID_EX_write_register = ID_EX_RegDst ? ID_EX_rd : ID_EX_rt;
ALU alu_inst (
    .A(fwd_A),
    .B(alu_B),
    .operation(ID_EX_alu_op),
    .shamt(ID_EX_shamt),
    .zero(alu_zero),
    .overflow(alu_overflow),
    .o_alu(alu_result)
);
shift_left_two shift_left_two_inst (
    .inp(ID_EX_imm_ext),
    .out(branch_offset)
);
assign branch_target = ID_EX_pc_plus4 + branch_offset;
assign branch_taken  = ID_EX_Branch & (alu_zero ^ ID_EX_BranchNE);
EX_MEM ex_mem_inst (
    .clk(clk),
    .reset(reset),
    .i_RegWrite(ID_EX_RegWrite),
    .i_MemtoReg(ID_EX_MemtoReg),
    .i_MemRead(ID_EX_MemRead),
    .i_MemWrite(ID_EX_MemWrite),
    .i_alu_result(alu_result),
    .i_write_data(fwd_B),
    .i_write_register(ID_EX_write_register),
    .o_RegWrite(EX_MEM_RegWrite),
    .o_MemtoReg(EX_MEM_MemtoReg),
    .o_MemRead(EX_MEM_MemRead),
    .o_MemWrite(EX_MEM_MemWrite),
    .o_alu_result(EX_MEM_alu_result),
    .o_write_data(EX_MEM_write_data),
    .o_write_register(EX_MEM_write_register)
);
data_mem data_mem_inst (
    .clk(clk),
    .addr(EX_MEM_alu_result[11:2]),
    .i_data(EX_MEM_write_data),
    .mem_write(EX_MEM_MemWrite),
    .mem_read(EX_MEM_MemRead),
    .o_data(mem_read_data)
);
MEM_WB mem_wb_inst (
    .clk(clk),
    .reset(reset),
    .i_RegWrite(EX_MEM_RegWrite),
    .i_MemtoReg(EX_MEM_MemtoReg),
    .i_alu_result(EX_MEM_alu_result),
    .i_mem_data(mem_read_data),
    .i_write_register(EX_MEM_write_register),
    .o_RegWrite(MEM_WB_RegWrite),
    .o_MemtoReg(MEM_WB_MemtoReg),
    .o_alu_result(MEM_WB_alu_result),
    .o_mem_data(MEM_WB_mem_data),
    .o_write_register(MEM_WB_write_register)
);
mux_32 write_back_mux (
    .address(MEM_WB_MemtoReg),
    .i_1(MEM_WB_mem_data),
    .i_0(MEM_WB_alu_result),
    .out(write_back_data)
);
endmodule
