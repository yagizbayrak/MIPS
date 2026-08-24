// Data memory with asynchronous reads and synchronous writes for the memory stage.
module data_mem #(
    parameter MEMORY_LENGTH = 512
)
(
    input clk,
    input [$clog2(MEMORY_LENGTH)-1:0] addr,
    input [31:0] i_data,
    input mem_write,
    input mem_read,
    output reg [31:0] o_data
);

    reg [31:0] mem [0:MEMORY_LENGTH - 1];

    always @(posedge clk) begin
        if (mem_write)
            mem[addr] <= i_data;
        if (mem_read)
            o_data <= mem[addr];
    end

endmodule
