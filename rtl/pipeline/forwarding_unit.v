// Selects the newest available value for each execute-stage operand from the two later pipeline stages.
module forwarding_unit (
    input  wire [4:0] ID_EX_rs,
    input  wire [4:0] ID_EX_rt,
    input  wire [4:0] EX_MEM_write_register,
    input  wire       EX_MEM_RegWrite,
    input  wire [4:0] MEM_WB_write_register,
    input  wire       MEM_WB_RegWrite,
    output reg  [1:0] forwardA,
    output reg  [1:0] forwardB
);
always @(*) begin
    if (EX_MEM_RegWrite & (EX_MEM_write_register != 5'd0) & (EX_MEM_write_register == ID_EX_rs))
        forwardA = 2'b10;
    else if (MEM_WB_RegWrite & (MEM_WB_write_register != 5'd0) & (MEM_WB_write_register == ID_EX_rs))
        forwardA = 2'b01;
    else
        forwardA = 2'b00;
    if (EX_MEM_RegWrite & (EX_MEM_write_register != 5'd0) & (EX_MEM_write_register == ID_EX_rt))
        forwardB = 2'b10;
    else if (MEM_WB_RegWrite & (MEM_WB_write_register != 5'd0) & (MEM_WB_write_register == ID_EX_rt))
        forwardB = 2'b01;
    else
        forwardB = 2'b00;
end
endmodule
