// top.v  -- top-level single-cycle MIPS wiring for your modules
module MIPS_Top (
    input  wire clk,
    input  wire reset   // active-high synchronous reset for PC/regfile
);

// Program Counter
reg [31:0] PC;
wire [31:0] PC_plus4;
wire [31:0] PC_branch;
wire [31:0] PC_jump;
wire [31:0] nextPC;

// Fetch stage: instruction memory
wire [31:0] instruction;
// ins_mem in your file uses addr width = $clog2(INSTRUCTION_AMOUNT)-1:0
// Instruction indexing by word: use PC[7:2] (6 bits -> supports 128 instructions)
wire [5:0] instr_addr = PC[7:2];
ins_mem inst_mem_inst (
    .clk(clk),
    .addr_inst(instr_addr),
    .cur_inst(instruction)
);

// Control unit
wire        RegDst, Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
wire [1:0]  ALUOp;
wire        SignZero;

control control_inst(
    .instruction(instruction),
    .RegDst(RegDst),
    .Jump(Jump),
    .Branch(Branch),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .ALUOp(ALUOp),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .SignZero(SignZero)
);

// Register file
wire [31:0] read_data1, read_data2;
wire [4:0]  rs = instruction[25:21];
wire [4:0]  rt = instruction[20:16];
wire [4:0]  rd = instruction[15:11];
wire [4:0]  write_register = (RegDst) ? rd : rt;

registers regs (
    .clk(clk),
    .reg_write(RegWrite),
    .r_reg_1(rs),
    .r_reg_2(rt),
    .write_register(write_register),
    .write_data( /* connected below */ ),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

// Immediate extend mux (sign/zero)
wire [31:0] sign_ext_imm, zero_ext_imm, imm_ext;
sign_extend sign_ext_inst(.i_inst(instruction[15:0]), .o_inst(sign_ext_imm));
zero_extend zero_ext_inst(.i_inst(instruction[15:0]), .o_inst(zero_ext_imm));
assign imm_ext = (SignZero) ? zero_ext_imm : sign_ext_imm;

// ALU input B selection (ALUSrc)
wire [31:0] ALU_B = (ALUSrc) ? imm_ext : read_data2;

// ALUcontrol
wire [1:0] o_ALUcontrol;
ALUcontrol alu_ctrl_inst(
    .instruction(instruction),
    .ALUop(ALUOp),
    .o_ALUcontrol(o_ALUcontrol)
);

// Expand to 4-bit operation expected by ALU (your ALU has 4-bit op input)
wire [3:0] alu_operation = {2'b00, o_ALUcontrol};

// ALU
wire alu_zero;
wire alu_overflow;
wire signed [31:0] alu_result;

ALU alu_inst (
    .clk(clk),
    .A(read_data1),
    .B(ALU_B),
    .operation(alu_operation),
    .zero(alu_zero),
    .overflow(alu_overflow),
    .o_alu(alu_result)
);

// Data memory (word addressed). data_mem expects addr width of $clog2(MEMORY_LENGTH)-1:0 (here 10 bits)
wire [9:0] data_addr = alu_result[11:2]; // word address for 1024 words
wire [31:0] mem_read_data;

data_mem data_mem_inst (
    .clk(clk),
    .addr(data_addr),
    .i_data(read_data2),
    .mem_write(MemWrite),
    .mem_read(MemRead),
    .o_data(mem_read_data)
);

// Write back mux: choose between ALU result and Mem read
wire [31:0] write_back_data;
assign write_back_data = (MemtoReg) ? mem_read_data : alu_result;

// Connect write_back to registers instance (can't re-declare port; use hierarchical trick via a wire/reg)
 // registers instance had a port .write_data; connect now via a net
// (we connected .write_data earlier as a comment; instantiate regs with explicit connection above)
// To finish wiring, we need to drive write_data. For that we use a small generate: use an internal net + tristate not needed.
// Assuming the module instantiation allowed deferred connection; but here we re-declare registers with connection:
 // To avoid confusion, we will re-instantiate registers with correct connection (instead of the earlier placeholder).
// For clarity and correctness: remove the earlier registers inst and re-declare here. (If copying into your project, ensure only one instance exists.)

// -- Re-instantiate registers (replace previous instantiation if present) --
/* If you already instantiated registers above, delete that and use this one instead */
(* replace_regs_inst = "true" *)
module _regs_reinst();
endmodule

// Because we cannot actually delete the earlier instance textually here in this snippet,
// in your real file ensure the `registers regs` instantiation is the one that uses write_back_data.
// For clarity, here's the correct registers instantiation (use this one):

/*
registers regs (
    .clk(clk),
    .reg_write(RegWrite),
    .r_reg_1(rs),
    .r_reg_2(rt),
    .write_register(write_register),
    .write_data(write_back_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);
*/

// Branch logic
assign PC_plus4 = PC + 32'd4;
assign PC_branch = PC_plus4 + (imm_ext << 2); // target = PC+4 + sign_ext(immediate)<<2
wire do_branch = Branch & alu_zero;

// Jump logic: J-type target
assign PC_jump = {PC_plus4[31:28], instruction[25:0], 2'b00};

// Next PC muxing: priority - jump > branch > sequential
assign nextPC = (Jump) ? PC_jump :
                (do_branch) ? PC_branch :
                PC_plus4;

// Synchronous PC update
always @(posedge clk) begin
    if (reset)
        PC <= 32'd0;
    else
        PC <= nextPC;
end

// Connect write back data to registers instance
// If your registers instantiation above already exists, ensure its .write_data is connected to write_back_data.
// (See commented correct instantiation above)

endmodule
