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
                        // note: your ALU currently has op 1110 as "A > B -> 1". 
                        // Implementing slt usually sets 1 if A < B. Choose one:
                        // - map SLT to a dedicated code and update ALU, or
                        // - map it here and swap operands upstream.
                        o_ALUcontrol = 4'b1110; // (use with caution; see note)

                    // shifts (if using 'shamt' and the appropriate funct)
                    6'b000000: // sll
                        o_ALUcontrol = 4'b0100; // shift left by 1 (currently fixed by your ALU)
                    6'b000010: // srl
                        o_ALUcontrol = 4'b0101; // shift right arithmetic/logical depending on ALU
                    // add other funct codes here if needed

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
