// Decode-to-execute pipeline register whose flush input inserts a bubble by clearing the control signals.
module ID_EX (
    input  wire        clk,
    input  wire        reset,
    input  wire        flush,
    input  wire        i_RegWrite,
    input  wire        i_MemtoReg,
    input  wire        i_MemRead,
    input  wire        i_MemWrite,
    input  wire        i_Branch,
    input  wire        i_BranchNE,
    input  wire        i_ALUSrc,
    input  wire        i_RegDst,
    input  wire [3:0]  i_alu_op,
    input  wire [31:0] i_pc_plus4,
    input  wire [31:0] i_read_data1,
    input  wire [31:0] i_read_data2,
    input  wire [31:0] i_imm_ext,
    input  wire [4:0]  i_rs,
    input  wire [4:0]  i_rt,
    input  wire [4:0]  i_rd,
    input  wire [4:0]  i_shamt,
    output reg         o_RegWrite,
    output reg         o_MemtoReg,
    output reg         o_MemRead,
    output reg         o_MemWrite,
    output reg         o_Branch,
    output reg         o_BranchNE,
    output reg         o_ALUSrc,
    output reg         o_RegDst,
    output reg  [3:0]  o_alu_op,
    output reg  [31:0] o_pc_plus4,
    output reg  [31:0] o_read_data1,
    output reg  [31:0] o_read_data2,
    output reg  [31:0] o_imm_ext,
    output reg  [4:0]  o_rs,
    output reg  [4:0]  o_rt,
    output reg  [4:0]  o_rd,
    output reg  [4:0]  o_shamt
);
always @(posedge clk) begin
    if (reset | flush) begin
        o_RegWrite   <= 1'b0;
        o_MemtoReg   <= 1'b0;
        o_MemRead    <= 1'b0;
        o_MemWrite   <= 1'b0;
        o_Branch     <= 1'b0;
        o_BranchNE   <= 1'b0;
        o_ALUSrc     <= 1'b0;
        o_RegDst     <= 1'b0;
        o_alu_op     <= 4'b0000;
        o_pc_plus4   <= 32'd0;
        o_read_data1 <= 32'd0;
        o_read_data2 <= 32'd0;
        o_imm_ext    <= 32'd0;
        o_rs         <= 5'd0;
        o_rt         <= 5'd0;
        o_rd         <= 5'd0;
        o_shamt      <= 5'd0;
    end
    else begin
        o_RegWrite   <= i_RegWrite;
        o_MemtoReg   <= i_MemtoReg;
        o_MemRead    <= i_MemRead;
        o_MemWrite   <= i_MemWrite;
        o_Branch     <= i_Branch;
        o_BranchNE   <= i_BranchNE;
        o_ALUSrc     <= i_ALUSrc;
        o_RegDst     <= i_RegDst;
        o_alu_op     <= i_alu_op;
        o_pc_plus4   <= i_pc_plus4;
        o_read_data1 <= i_read_data1;
        o_read_data2 <= i_read_data2;
        o_imm_ext    <= i_imm_ext;
        o_rs         <= i_rs;
        o_rt         <= i_rt;
        o_rd         <= i_rd;
        o_shamt      <= i_shamt;
    end
end
endmodule
