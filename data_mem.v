module data_mem #(
    parameter MEMORY_LENGTH = 1024
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
        if (mem_read & !mem_write)
            o_data <= mem[addr];
        else if (!mem_read & mem_write)
            mem[addr] <= i_data;
        else
            ;

    end

endmodule
    
