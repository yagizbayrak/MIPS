// Execute-to-memory pipeline register carrying the ALU result and the store data.
module EX_MEM (
    input  wire        clk,
    input  wire        reset,
    input  wire        i_RegWrite,
    input  wire        i_MemtoReg,
    input  wire        i_MemRead,
    input  wire        i_MemWrite,
    input  wire [31:0] i_alu_result,
    input  wire [31:0] i_write_data,
    input  wire [4:0]  i_write_register,
    output reg         o_RegWrite,
    output reg         o_MemtoReg,
    output reg         o_MemRead,
    output reg         o_MemWrite,
    output reg  [31:0] o_alu_result,
    output reg  [31:0] o_write_data,
    output reg  [4:0]  o_write_register
);
always @(posedge clk) begin
    if (reset) begin
        o_RegWrite       <= 1'b0;
        o_MemtoReg       <= 1'b0;
        o_MemRead        <= 1'b0;
        o_MemWrite       <= 1'b0;
        o_alu_result     <= 32'd0;
        o_write_data     <= 32'd0;
        o_write_register <= 5'd0;
    end
    else begin
        o_RegWrite       <= i_RegWrite;
        o_MemtoReg       <= i_MemtoReg;
        o_MemRead        <= i_MemRead;
        o_MemWrite       <= i_MemWrite;
        o_alu_result     <= i_alu_result;
        o_write_data     <= i_write_data;
        o_write_register <= i_write_register;
    end
end
endmodule
