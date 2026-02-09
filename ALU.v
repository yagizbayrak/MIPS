module ALU(
    input clk,                // added clock port
    input signed [31:0] A,
    input signed [31:0] B,
    input [3:0] operation,
    output reg zero, 
    output reg overflow,
    output reg signed [31:0] o_alu);
    
  	reg signed [32:0] sum;
  
    always @(posedge clk )
    
     begin
     overflow = 1'b0;
     o_alu = 32'sd0;
        case (operation)
            //Addition
            4'b0000: begin
              	sum = A + B;
                o_alu = sum;
                overflow = (A[31] & B[31] & ~sum[31]) | (~A[31] & ~B[31] & sum[31]);
            end
            //Subtraction
            4'b0001: begin
                o_alu = A - B;
            end
            //Multiplication
            4'b0010: begin
                o_alu = A * B;
            end
            //Division
            4'b0011: begin
                o_alu = A / B;
            end
            //Shift left by 
            4'b0100: begin
                o_alu = A <<< 1;
            end
            //Shift right by 
            4'b0101: begin
                o_alu = A >>> 1;
            end
            //Rotate left
            4'b0110: begin
                o_alu = {A[30:0], A[31]};
            end
            //Rotate right
            4'b0111: begin
                o_alu = {A[0], A[31:1]};
            end
            //logical AND
            4'b1000: begin
            o_alu = A & B;
            end
            //logical OR
            4'b1001: begin
                o_alu = A | B;
            end
            //logical XOR
            4'b1010: begin
                o_alu = A ^ B ;
            end
            //logical NOR
            4'b1011: begin
                o_alu = ~(A | B);
            end
            //logical NAND
            4'b1100: begin
                o_alu = ~(A & B);
            end
            //Logical XNOR
            4'b1101: begin
                o_alu =  A ~^ B;
            end
            //Greater than comparison
            4'b1110: begin
                o_alu = (A>B)?32'd1:32'd0;
            end
            // Equal comparison  
            4'b1111: begin
                o_alu= (A == B)?32'd1:32'd0;
            end
            default: o_alu = 0 ;
        endcase

        zero = (o_alu==0);
    
    end


endmodule


`timescale 1ns / 1ps

// -----------------------------
// Testbench
// -----------------------------
module tb_alu;
  // Inputs (make them signed to match ALU signed ports)
  reg signed [31:0] A, B;
  reg [3:0]  op;
  reg clk;

  // Outputs
  wire signed [31:0] ALU_Out;
  wire               o_overflow;
  wire               o_zero;

  integer i;

  // Instantiate DUT (named port connections)
  ALU test_unit (
    .clk(clk),
    .A(A),
    .B(B),
    .operation(op),
    .zero(o_zero),
    .overflow(o_overflow),
    .o_alu(ALU_Out)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $display("time A B op ALU_Out zero overflow");
    $monitor("%0t %0d %0d %b %0d %b %b", $time, A, B, op, ALU_Out, o_zero, o_overflow);

    $dumpfile("dump.vcd");
    $dumpvars(0, tb_alu);

    // initialize inputs
    A  = 32'sd101;     // decimal 101, signed
    B  = 32'sd4;       // decimal 4
    op = 4'd0;

    // apply operations 0..15
    for (i = 0; i <= 15; i = i + 1) begin
      op = i[3:0];    // ensure op is 4-bit
      #10;
    end

    // some corner cases to exercise overflow and zero
    #10;
    A = 32'sd2147483647; // max positive
    B = 32'sd1;
    op = 4'b0000; // add -> overflow expected
    #10;

    A = -32'sd5;
    B = 32'sd5;
    op = 4'b0001; // subtract -> zero expected if equal, here -5 - 5 = -10
    #10;

    A = 32'sd7;
    B = 32'sd7;
    op = 4'b1111; // equality -> 1
    #10;

    #10;
    $finish;
  end
endmodule