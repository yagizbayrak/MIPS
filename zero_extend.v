module zero_extend(
    input [15:0] i_inst;
    output [31:0] o_inst;
)

assign o_inst = {16'b0, i_inst};

endmodule

