module ALU (
    input  signed [31:0] A,
    input  signed [31:0] B,
    input  [3:0]         operation, // 4-bit control from ALUcontrol
    input  [4:0]         shamt,     // shift amount, typically instruction[10:6]
    output reg           zero,
    output reg           overflow,
    output reg signed [31:0] o_alu
);

    // temporaries wide enough to detect signed overflow
    reg signed [32:0] wide_sum;
    reg signed [32:0] wide_diff;
    reg [31:0] ua; // unsigned view of A for bitwise ops and rotates
    reg [31:0] ub;

    always @(*) begin
        // defaults
        o_alu   = 32'sd0;
        overflow = 1'b0;
        ua = A;
        ub = B;

        case (operation)
            // 0000 : ADD (signed)
            4'b0000: begin
                wide_sum = A + B;          // 33-bit to catch overflow
                o_alu = wide_sum[31:0];
                // signed overflow: inputs same sign, result different sign
                overflow = (A[31] & B[31] & ~wide_sum[31]) |
                           (~A[31] & ~B[31] &  wide_sum[31]);
            end

            // 0001 : SUB (signed) A - B
            4'b0001: begin
                wide_diff = A - B;
                o_alu = wide_diff[31:0];
                // signed overflow for subtraction
                overflow = (A[31] & ~B[31] & ~wide_diff[31]) |
                           (~A[31] &  B[31] &  wide_diff[31]);
            end

            // 0010 : MUL  -> low 32 bits of product
            4'b0010: begin
                o_alu = (A * B); // low 32 bits; full 64-bit product not returned
            end

            // 0011 : DIV  -> integer division (signed)
            4'b0011: begin
                if (B == 32'sd0) begin
                    o_alu = 32'sd0; // guard division by zero; alternative: leave undefined
                end else begin
                    o_alu = A / B;
                end
            end

            // 0100 : SLL — logical left by shamt
            4'b0100: begin
                o_alu = ua << shamt;
            end

            // 0101 : SRL — logical right by shamt
            4'b0101: begin
                o_alu = ua >> shamt;
            end

            // 0110 : ROL — rotate left by shamt
            4'b0110: begin
                // rotate left: (A << shamt) | (A >> (32 - shamt))
                o_alu = (ua << shamt) | (ua >> (32 - shamt));
            end

            // 0111 : ROR — rotate right by shamt
            4'b0111: begin
                // rotate right: (A >> shamt) | (A << (32 - shamt))
                o_alu = (ua >> shamt) | (ua << (32 - shamt));
            end

            // 1000 : AND
            4'b1000: begin
                o_alu = A & B;
            end

            // 1001 : OR
            4'b1001: begin
                o_alu = A | B;
            end

            // 1010 : XOR
            4'b1010: begin
                o_alu = A ^ B;
            end

            // 1011 : NOR
            4'b1011: begin
                o_alu = ~(A | B);
            end

            // 1100 : NAND
            4'b1100: begin
                o_alu = ~(A & B);
            end

            // 1101 : XNOR
            4'b1101: begin
                o_alu = ~(A ^ B);
            end

            // 1110 : SLT (set on less than), signed: 1 if A < B else 0
            4'b1110: begin
                o_alu = (A < B) ? 32'sd1 : 32'sd0;
            end

            // 1111 : SEQ (equal) 1 if equal else 0
            4'b11
