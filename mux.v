module mux_32(
    input address,
    input [31:0] i_1,
    input [31:0] i_0,
    output [31:0] out
);

assign out = (address == 1'b0)?i_0:i_1 ;

endmodule