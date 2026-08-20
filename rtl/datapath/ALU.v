// Combinational 32-bit ALU providing the sixteen operations selected by ALUcontrol.
module ALU (
    input  signed [31:0] A,
    input  signed [31:0] B,
    input  [3:0]         operation,
    input  [4:0]         shamt,
    output reg           zero,
    output reg           overflow,
    output reg signed [31:0] o_alu
);
    reg [31:0] ua;
    reg [31:0] ub;
    always @(*) begin
        o_alu    = 32'sd0;
        overflow = 1'b0;
        ua = A;
        ub = B;
        case (operation)
            4'b0000: begin
                o_alu    = A + B;
                overflow = (A[31] & B[31] & ~o_alu[31]) | (~A[31] & ~B[31] & o_alu[31]);
            end
            4'b0001: begin
                o_alu    = A - B;
                overflow = (A[31] & ~B[31] & ~o_alu[31]) | (~A[31] & B[31] & o_alu[31]);
            end
            4'b0010: o_alu = A * B;
            4'b0011: o_alu = (B == 32'sd0) ? 32'sd0 : A / B;
            4'b0100: o_alu = ub << shamt;
            4'b0101: o_alu = ub >> shamt;
            4'b0110: o_alu = (shamt == 5'd0) ? ub : ((ub << shamt) | (ub >> (6'd32 - shamt)));
            4'b0111: o_alu = (shamt == 5'd0) ? ub : ((ub >> shamt) | (ub << (6'd32 - shamt)));
            4'b1000: o_alu = ua & ub;
            4'b1001: o_alu = ua | ub;
            4'b1010: o_alu = ua ^ ub;
            4'b1011: o_alu = ~(ua | ub);
            4'b1100: o_alu = ~(ua & ub);
            4'b1101: o_alu = ~(ua ^ ub);
            4'b1110: o_alu = (A < B) ? 32'sd1 : 32'sd0;
            4'b1111: o_alu = (A == B) ? 32'sd1 : 32'sd0;
        endcase
        zero = (o_alu == 32'sd0);
    end
endmodule
