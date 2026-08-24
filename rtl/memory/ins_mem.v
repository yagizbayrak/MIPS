// Asynchronous-read instruction memory addressed by word index.
module ins_mem #(
    parameter INSTRUCTION_AMOUNT = 256
)
(
    input clk,
    input ce,
    input [$clog2(INSTRUCTION_AMOUNT)-1:0] addr_inst,
    input we,
    input [$clog2(INSTRUCTION_AMOUNT)-1:0] addr_write,
    input [31:0] data_write,
    output reg [31:0] cur_inst
);

    reg [31:0] inst_set [0:INSTRUCTION_AMOUNT - 1];

    always @(posedge clk) begin
        if (we)
            inst_set[addr_write] <= data_write;
        if (ce)
            cur_inst <= inst_set[addr_inst];
    end

endmodule
