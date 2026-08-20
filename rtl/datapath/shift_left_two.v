// Shifts a 32-bit branch or jump offset left by two to convert it into a byte address.
module shift_left_two(
    input  [31:0] inp,
    output [31:0] out
);
assign out = inp << 2;
endmodule
