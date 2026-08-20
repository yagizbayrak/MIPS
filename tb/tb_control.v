// Verifies the control signal bundle produced for every supported opcode.
module tb_control;
reg [31:0] instruction;
wire RegDst;
wire Jump;
wire Branch;
wire BranchNE;
wire MemRead;
wire MemtoReg;
wire [1:0] ALUOp;
wire MemWrite;
wire ALUSrc;
wire RegWrite;
wire SignZero;
integer errors;
control dut (
    .instruction(instruction),
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
task check(input [127:0] name, input [5:0] opcode, input e_RegDst, input e_Jump,
           input e_Branch, input e_BranchNE, input e_MemRead, input e_MemtoReg,
           input [1:0] e_ALUOp, input e_MemWrite, input e_ALUSrc, input e_RegWrite,
           input e_SignZero);
    begin
        instruction = {opcode, 26'd0};
        #1;
        if (RegDst !== e_RegDst || Jump !== e_Jump || Branch !== e_Branch ||
            BranchNE !== e_BranchNE || MemRead !== e_MemRead || MemtoReg !== e_MemtoReg ||
            ALUOp !== e_ALUOp || MemWrite !== e_MemWrite || ALUSrc !== e_ALUSrc ||
            RegWrite !== e_RegWrite || SignZero !== e_SignZero) begin
            errors = errors + 1;
            $display("FAIL %0s: RegDst=%b Jump=%b Branch=%b BranchNE=%b MemRead=%b MemtoReg=%b ALUOp=%b MemWrite=%b ALUSrc=%b RegWrite=%b SignZero=%b",
                     name, RegDst, Jump, Branch, BranchNE, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite, SignZero);
        end
    end
endtask
initial begin
    errors = 0;
    check("r-type", 6'b000000, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b10, 1'b0, 1'b0, 1'b1, 1'b0);
    check("lw",     6'b100011, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 2'b00, 1'b0, 1'b1, 1'b1, 1'b0);
    check("sw",     6'b101011, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'bx, 2'b00, 1'b1, 1'b1, 1'b0, 1'b0);
    check("beq",    6'b000100, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 2'b01, 1'b0, 1'b0, 1'b0, 1'b0);
    check("bne",    6'b000101, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b01, 1'b0, 1'b0, 1'b0, 1'b0);
    check("addi",   6'b001000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1, 1'b1, 1'b0);
    check("xori",   6'b001110, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b1, 1'b1, 1'b1);
    check("j",      6'b000010, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);
    check("undefined opcode", 6'b111111, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b10, 1'b0, 1'b0, 1'b0, 1'b0);
    if (errors == 0)
        $display("tb_control PASS");
    else
        $display("tb_control FAIL with %0d errors", errors);
    $finish;
end
endmodule
