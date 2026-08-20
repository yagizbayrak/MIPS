// Checks operand forwarding selection including stage priority and the zero register guard.
module tb_forwarding_unit;
reg [4:0] ID_EX_rs;
reg [4:0] ID_EX_rt;
reg [4:0] EX_MEM_write_register;
reg EX_MEM_RegWrite;
reg [4:0] MEM_WB_write_register;
reg MEM_WB_RegWrite;
wire [1:0] forwardA;
wire [1:0] forwardB;
integer errors;
forwarding_unit dut (
    .ID_EX_rs(ID_EX_rs),
    .ID_EX_rt(ID_EX_rt),
    .EX_MEM_write_register(EX_MEM_write_register),
    .EX_MEM_RegWrite(EX_MEM_RegWrite),
    .MEM_WB_write_register(MEM_WB_write_register),
    .MEM_WB_RegWrite(MEM_WB_RegWrite),
    .forwardA(forwardA),
    .forwardB(forwardB)
);
task check(input [127:0] name, input [1:0] expA, input [1:0] expB);
    begin
        #1;
        if (forwardA !== expA || forwardB !== expB) begin
            errors = errors + 1;
            $display("FAIL %0s: forwardA=%b forwardB=%b, expected %b and %b",
                     name, forwardA, forwardB, expA, expB);
        end
    end
endtask
initial begin
    errors = 0;
    ID_EX_rs = 5'd1; ID_EX_rt = 5'd2;
    EX_MEM_write_register = 5'd7; EX_MEM_RegWrite = 1'b1;
    MEM_WB_write_register = 5'd8; MEM_WB_RegWrite = 1'b1;
    check("no match", 2'b00, 2'b00);
    EX_MEM_write_register = 5'd1;
    check("EX/MEM to rs", 2'b10, 2'b00);
    EX_MEM_write_register = 5'd2;
    check("EX/MEM to rt", 2'b00, 2'b10);
    EX_MEM_write_register = 5'd7;
    MEM_WB_write_register = 5'd1;
    check("MEM/WB to rs", 2'b01, 2'b00);
    MEM_WB_write_register = 5'd2;
    check("MEM/WB to rt", 2'b00, 2'b01);
    EX_MEM_write_register = 5'd1;
    MEM_WB_write_register = 5'd1;
    check("EX/MEM wins over MEM/WB", 2'b10, 2'b00);
    EX_MEM_RegWrite = 1'b0;
    check("MEM/WB used when EX/MEM idle", 2'b01, 2'b00);
    EX_MEM_RegWrite = 1'b1;
    MEM_WB_RegWrite = 1'b0;
    ID_EX_rs = 5'd0; ID_EX_rt = 5'd0;
    EX_MEM_write_register = 5'd0;
    check("zero register never forwarded", 2'b00, 2'b00);
    if (errors == 0)
        $display("tb_forwarding_unit PASS");
    else
        $display("tb_forwarding_unit FAIL with %0d errors", errors);
    $finish;
end
endmodule
