// Second-level decoder turning ALUOp and the funct field into the ALU's four-bit operation select.
module ALUcontrol(
    input  [31:0] instruction,
    input  [1:0]  ALUop,
    output reg [3:0] o_ALUcontrol   // 4-bit control that drives ALU.operation
);

    wire [5:0] funct;
    assign funct = instruction[5:0];

    always @(*) begin
        // default
        o_ALUcontrol = 4'b0000;

        case (ALUop)
            2'b00: begin
                // lw / sw  -> ADD
                o_ALUcontrol = 4'b0000; // add
            end

            2'b01: begin
                // branch equal / not-equal -> SUBTRACT (compare)
                o_ALUcontrol = 4'b0001; // sub
            end

            2'b11: begin
                // XORI (immediate XOR) path selected by your control unit
                o_ALUcontrol = 4'b1010; // xor
            end

            2'b10: begin
                // R-type: decode funct field
                case (funct)
                    6'b100000, // add
                    6'b100001: // addu (treat same as add)
                        o_ALUcontrol = 4'b0000; // add

                    6'b100010, // sub
                    6'b100011: // subu
                        o_ALUcontrol = 4'b0001; // sub

                    6'b100100: // and
                        o_ALUcontrol = 4'b1000; // and

                    6'b100101: // or
                        o_ALUcontrol = 4'b1001; // or

                    6'b100110: // xor
                        o_ALUcontrol = 4'b1010; // xor

                    6'b100111: // nor
                        o_ALUcontrol = 4'b1011; // nor

                    6'b101010: // slt  (set on less than)
                        o_ALUcontrol = 4'b1110;

                    // shifts use the shamt field
                    6'b000000: // sll
                        o_ALUcontrol = 4'b0100; // sll
                    6'b000010: // srl
                        o_ALUcontrol = 4'b0101; // srl

                    default: begin
                        // unknown funct; default to add (safe fallback)
                        o_ALUcontrol = 4'b0000;
                    end
                endcase
            end

            default: begin
                o_ALUcontrol = 4'b0000;
            end
        endcase
    end

endmodule
