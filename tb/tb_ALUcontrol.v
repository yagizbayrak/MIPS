// Checks that each ALUOp and funct combination selects the intended ALU operation.
module tb_ALUcontrol;
reg [31:0] instruction;
reg [1:0] ALUop;
wire [3:0] o_ALUcontrol;
integer errors;
ALUcontrol dut (
    .instruction(instruction),
    .ALUop(ALUop),
    .o_ALUcontrol(o_ALUcontrol)
);
task check(input [127:0] name, input [1:0] op, input [5:0] funct, input [3:0] expected);
    begin
        ALUop = op;
        instruction = {26'd0, funct};
        #1;
        if (o_ALUcontrol !== expected) begin
            errors = errors + 1;
            $display("FAIL %0s: got %b, expected %b", name, o_ALUcontrol, expected);
        end
    end
endtask
initial begin
    errors = 0;
    check("lw/sw add",  2'b00, 6'b000000, 4'b0000);
    check("branch sub", 2'b01, 6'b000000, 4'b0001);
    check("xori",       2'b11, 6'b000000, 4'b1010);
    check("r-type add", 2'b10, 6'b100000, 4'b0000);
    check("r-type addu",2'b10, 6'b100001, 4'b0000);
    check("r-type sub", 2'b10, 6'b100010, 4'b0001);
    check("r-type subu",2'b10, 6'b100011, 4'b0001);
    check("r-type and", 2'b10, 6'b100100, 4'b1000);
    check("r-type or",  2'b10, 6'b100101, 4'b1001);
    check("r-type xor", 2'b10, 6'b100110, 4'b1010);
    check("r-type nor", 2'b10, 6'b100111, 4'b1011);
    check("r-type slt", 2'b10, 6'b101010, 4'b1110);
    check("r-type sll", 2'b10, 6'b000000, 4'b0100);
    check("r-type srl", 2'b10, 6'b000010, 4'b0101);
    check("unknown funct", 2'b10, 6'b111111, 4'b0000);
    if (errors == 0)
        $display("tb_ALUcontrol PASS");
    else
        $display("tb_ALUcontrol FAIL with %0d errors", errors);
    $finish;
end
endmodule
