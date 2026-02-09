module ins_mem #(
    parameter INSTRUCTION_AMOUNT = 128
)
(
    input clk,
    input [$clog2(INSTRUCTION_AMOUNT)-1:0] addr_inst,
    output reg [31:0] cur_inst
);

    reg [31:0] inst_set [0:INSTRUCTION_AMOUNT - 1];

    always @(posedge clk) begin
        cur_inst <= inst_set[addr_inst];
    end

endmodule
    
