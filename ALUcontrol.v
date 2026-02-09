module ALUcontrol(
    input [31:0] instruction,
    input [1:0] ALUop,
    output reg [3:0] o_ALUcontrol
);

wire [7:0] ALUcontrol_in;
assign ALUcontrol_in = {ALUop, {instruction[5:0]}}

always @(*) begin
      casez (ALUControlIn)
        8'b11??????: ALUControl = 2'b01;
        8'b00??????: ALUControl = 2'b00;
        8'b01??????: ALUControl = 2'b10;
        8'b1010_0000: ALUControl = 2'b00;
        8'b1010_0010: ALUControl = 2'b10;
        8'b1010_1010: ALUControl = 2'b11;
      default:     ALUControl = 2'b00;
    endcase  
end

endmodule
