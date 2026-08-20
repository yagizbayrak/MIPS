// Asynchronous-read instruction memory addressed by word index.
module ins_mem #(
    parameter INSTRUCTION_AMOUNT = 128
)
(
    input [$clog2(INSTRUCTION_AMOUNT)-1:0] addr_inst,
    output [31:0] cur_inst
);

    reg [31:0] inst_set [0:INSTRUCTION_AMOUNT - 1];

    assign cur_inst = inst_set[addr_inst];

endmodule
    
