module control (
    input instruction,
    output reg RegDst,
    output reg Jump,
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg [1:0] ALUOp,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite
);

localparam  opcode = instruction[31:26] ;    

always @(posedge clk) begin
   
    casex (opcode)
    6'b000000 : begin // R - type
        RegDst = 1'b1;
        ALUSrc = 1'b0;
        MemtoReg= 1'b0;
        RegWrite= 1'b1;
        MemRead = 1'b0;
        MemWrite= 1'b0;
        Branch = 1'b0;
        ALUOp = 2'b10;
        Jump = 1'b0;
        SignZero= 1'b0;
        end
    6'b100011 : begin // lw - load word
        RegDst = 1'b0;
        ALUSrc = 1'b1;
        MemtoReg= 1'b1;
        RegWrite= 1'b1;
        MemRead = 1'b1;
        MemWrite= 1'b0;
        Branch = 1'b0;
        ALUOp = 2'b00;
        Jump = 1'b0;
        SignZero= 1'b0; // sign extend
        end
    6'b101011 : begin // sw - store word
        RegDst = 1'bx;
        ALUSrc = 1'b1;
        MemtoReg= 1'bx;
        RegWrite= 1'b0;
        MemRead = 1'b0;
        MemWrite= 1'b1;
        Branch = 1'b0;
        ALUOp = 2'b00;
        Jump = 1'b0;
        SignZero= 1'b0;
        end
    6'b000101 : begin // bne - branch if not equal
        RegDst = 1'b0;
        ALUSrc = 1'b0;
        MemtoReg= 1'b0;
        RegWrite= 1'b0;
        MemRead = 1'b0;
        MemWrite= 1'b0;
        Branch = 1'b1;
        ALUOp = 2'b01;
        Jump = 1'b0;
        SignZero= 1'b0; // sign extend
        end
    6'b001110 : begin // XORI - XOR immidiate
        RegDst = 1'b0;
        ALUSrc = 1'b1;
        MemtoReg= 1'b0;
        RegWrite= 1'b1;
        MemRead = 1'b0;
        MemWrite= 1'b0;
        Branch = 1'b0;
        ALUOp = 2'b11;
        Jump = 1'b0;
        SignZero= 1'b1; // zero extend
        end
    6'b000010 : begin // j - Jump
        RegDst = 1'b0;
        ALUSrc = 1'b0;
        MemtoReg= 1'b0;
        RegWrite= 1'b0;
        MemRead = 1'b0;
        MemWrite= 1'b0;
        Branch = 1'b0;
        ALUOp = 2'b00;
        Jump = 1'b1;
        SignZero= 1'b0;
        end
    default : begin 
        RegDst = 1'b0;
        ALUSrc = 1'b0;
        MemtoReg= 1'b0;
        RegWrite= 1'b0;
        MemRead = 1'b0;
        MemWrite= 1'b0;
        Branch = 1'b0;
        ALUOp = 2'b10;
        Jump = 1'b0;
        SignZero= 1'b0;
        end
    endcase
end
endmodule


