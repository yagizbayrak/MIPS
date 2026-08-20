// Exercises every ALU operation together with the zero and overflow flags.
module tb_ALU;
reg signed [31:0] A;
reg signed [31:0] B;
reg [3:0] operation;
reg [4:0] shamt;
wire zero;
wire overflow;
wire signed [31:0] o_alu;
integer errors;
ALU dut (
    .A(A),
    .B(B),
    .operation(operation),
    .shamt(shamt),
    .zero(zero),
    .overflow(overflow),
    .o_alu(o_alu)
);
task check(input [127:0] name, input signed [31:0] expected);
    begin
        #1;
        if (o_alu !== expected) begin
            errors = errors + 1;
            $display("FAIL %0s: got %0d, expected %0d", name, o_alu, expected);
        end
    end
endtask
task check_flags(input [127:0] name, input exp_zero, input exp_overflow);
    begin
        #1;
        if (zero !== exp_zero || overflow !== exp_overflow) begin
            errors = errors + 1;
            $display("FAIL %0s: zero=%b overflow=%b, expected zero=%b overflow=%b",
                     name, zero, overflow, exp_zero, exp_overflow);
        end
    end
endtask
initial begin
    errors = 0;
    shamt = 5'd0;
    A = 32'sd20; B = 32'sd12; operation = 4'b0000; check("add", 32'sd32);
    A = 32'sd20; B = 32'sd12; operation = 4'b0001; check("sub", 32'sd8);
    A = -32'sd7; B = 32'sd3;  operation = 4'b0010; check("mul", -32'sd21);
    A = -32'sd20; B = 32'sd4; operation = 4'b0011; check("div", -32'sd5);
    A = 32'sd20; B = 32'sd0;  operation = 4'b0011; check("div by zero", 32'sd0);
    A = 32'sd0; B = 32'h0000000F; shamt = 5'd4; operation = 4'b0100; check("sll", 32'h000000F0);
    A = 32'sd0; B = 32'h000000F0; shamt = 5'd4; operation = 4'b0101; check("srl", 32'h0000000F);
    A = 32'sd0; B = 32'h8000000F; shamt = 5'd4; operation = 4'b0110; check("rol", 32'h000000F8);
    A = 32'sd0; B = 32'h0000000F; shamt = 5'd4; operation = 4'b0111; check("ror", 32'hF0000000);
    A = 32'sd0; B = 32'h0000000F; shamt = 5'd0; operation = 4'b0110; check("rol by zero", 32'h0000000F);
    A = 32'sd0; B = 32'h0000000F; shamt = 5'd0; operation = 4'b0111; check("ror by zero", 32'h0000000F);
    shamt = 5'd0;
    A = 32'hF0F0F0F0; B = 32'h00FF00FF; operation = 4'b1000; check("and", 32'h00F000F0);
    A = 32'hF0F0F0F0; B = 32'h00FF00FF; operation = 4'b1001; check("or",  32'hF0FFF0FF);
    A = 32'hF0F0F0F0; B = 32'h00FF00FF; operation = 4'b1010; check("xor", 32'hF00FF00F);
    A = 32'hF0F0F0F0; B = 32'h00FF00FF; operation = 4'b1011; check("nor", 32'h0F000F00);
    A = 32'hF0F0F0F0; B = 32'h00FF00FF; operation = 4'b1100; check("nand", 32'hFF0FFF0F);
    A = 32'hF0F0F0F0; B = 32'h00FF00FF; operation = 4'b1101; check("xnor", 32'h0FF00FF0);
    A = -32'sd5; B = 32'sd3; operation = 4'b1110; check("slt true", 32'sd1);
    A = 32'sd9; B = 32'sd3;  operation = 4'b1110; check("slt false", 32'sd0);
    A = 32'sd7; B = 32'sd7;  operation = 4'b1111; check("seq true", 32'sd1);
    A = 32'sd7; B = 32'sd8;  operation = 4'b1111; check("seq false", 32'sd0);
    A = 32'sd5; B = 32'sd5; operation = 4'b0001; check_flags("sub to zero", 1'b1, 1'b0);
    A = 32'sd5; B = 32'sd4; operation = 4'b0001; check_flags("sub nonzero", 1'b0, 1'b0);
    A = 32'h7FFFFFFF; B = 32'sd1; operation = 4'b0000; check_flags("add overflow", 1'b0, 1'b1);
    A = 32'h80000000; B = 32'sd1; operation = 4'b0001; check_flags("sub overflow", 1'b0, 1'b1);
    if (errors == 0)
        $display("tb_ALU PASS");
    else
        $display("tb_ALU FAIL with %0d errors", errors);
    $finish;
end
endmodule
