// Fetch-to-decode pipeline register with independent stall and flush controls.
module IF_ID (
    input  wire        clk,
    input  wire        reset,
    input  wire        stall,
    input  wire        flush,
    input  wire [31:0] i_pc_plus4,
    output reg  [31:0] o_pc_plus4,
    output reg         o_squash
);
always @(posedge clk) begin
    if (reset | flush) begin
        o_pc_plus4 <= 32'd0;
        o_squash   <= 1'b1;
    end
    else if (!stall) begin
        o_pc_plus4 <= i_pc_plus4;
        o_squash   <= 1'b0;
    end
end
endmodule
