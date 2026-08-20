// Detects the load-use hazard and stalls the front of the pipeline for one cycle to resolve it.
module hazard_unit (
    input  wire       ID_EX_MemRead,
    input  wire [4:0] ID_EX_rt,
    input  wire [4:0] IF_ID_rs,
    input  wire [4:0] IF_ID_rt,
    output wire       stall_pc,
    output wire       stall_IF_ID,
    output wire       bubble_ID_EX
);
wire load_use;
assign load_use = ID_EX_MemRead & (ID_EX_rt != 5'd0) & ((ID_EX_rt == IF_ID_rs) | (ID_EX_rt == IF_ID_rt));
assign stall_pc     = load_use;
assign stall_IF_ID  = load_use;
assign bubble_ID_EX = load_use;
endmodule
