// Checks that the load-use hazard stalls only when a pending load feeds the instruction in decode.
module tb_hazard_unit;
reg ID_EX_MemRead;
reg [4:0] ID_EX_rt;
reg [4:0] IF_ID_rs;
reg [4:0] IF_ID_rt;
wire stall_pc;
wire stall_IF_ID;
wire bubble_ID_EX;
integer errors;
hazard_unit dut (
    .ID_EX_MemRead(ID_EX_MemRead),
    .ID_EX_rt(ID_EX_rt),
    .IF_ID_rs(IF_ID_rs),
    .IF_ID_rt(IF_ID_rt),
    .stall_pc(stall_pc),
    .stall_IF_ID(stall_IF_ID),
    .bubble_ID_EX(bubble_ID_EX)
);
task check(input [127:0] name, input expected);
    begin
        #1;
        if (stall_pc !== expected || stall_IF_ID !== expected || bubble_ID_EX !== expected) begin
            errors = errors + 1;
            $display("FAIL %0s: stall_pc=%b stall_IF_ID=%b bubble_ID_EX=%b, expected all %b",
                     name, stall_pc, stall_IF_ID, bubble_ID_EX, expected);
        end
    end
endtask
initial begin
    errors = 0;
    ID_EX_MemRead = 1'b0; ID_EX_rt = 5'd4; IF_ID_rs = 5'd4; IF_ID_rt = 5'd4;
    check("no load in execute", 1'b0);
    ID_EX_MemRead = 1'b1; IF_ID_rs = 5'd4; IF_ID_rt = 5'd9;
    check("load feeds rs", 1'b1);
    IF_ID_rs = 5'd9; IF_ID_rt = 5'd4;
    check("load feeds rt", 1'b1);
    IF_ID_rs = 5'd9; IF_ID_rt = 5'd9;
    check("load unrelated", 1'b0);
    ID_EX_rt = 5'd0; IF_ID_rs = 5'd0; IF_ID_rt = 5'd0;
    check("load into zero register", 1'b0);
    if (errors == 0)
        $display("tb_hazard_unit PASS");
    else
        $display("tb_hazard_unit FAIL with %0d errors", errors);
    $finish;
end
endmodule
