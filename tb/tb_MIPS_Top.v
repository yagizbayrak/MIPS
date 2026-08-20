// Runs a program through the pipelined core and checks the resulting register file and data memory.
module tb_MIPS_Top;
reg clk;
reg reset;
integer errors;
integer i;
MIPS_Top dut (
    .clk(clk),
    .reset(reset)
);
task check_reg(input [4:0] index, input [31:0] expected);
    begin
        if (dut.regs.all_registers[index] !== expected) begin
            errors = errors + 1;
            $display("FAIL $%0d = %0d, expected %0d", index, dut.regs.all_registers[index], expected);
        end
    end
endtask
task check_mem(input [9:0] index, input [31:0] expected);
    begin
        if (dut.data_mem_inst.mem[index] !== expected) begin
            errors = errors + 1;
            $display("FAIL mem[%0d] = %0d, expected %0d", index, dut.data_mem_inst.mem[index], expected);
        end
    end
endtask
always #5 clk = ~clk;
initial begin
    errors = 0;
    clk = 1'b0;
    reset = 1'b1;
    for (i = 0; i < 32; i = i + 1)
        dut.regs.all_registers[i] = 32'd0;
    $readmemh("tb/program.hex", dut.inst_mem_inst.inst_set);
    repeat (2) @(posedge clk);
    reset = 1'b0;
    repeat (100) @(posedge clk);
    check_reg(5'd1,  32'd10);
    check_reg(5'd2,  32'd3);
    check_reg(5'd3,  32'd13);
    check_reg(5'd4,  32'd7);
    check_reg(5'd5,  32'd2);
    check_reg(5'd6,  32'd11);
    check_reg(5'd7,  32'd9);
    check_reg(5'd8,  32'd1);
    check_reg(5'd9,  32'd40);
    check_reg(5'd10, 32'd5);
    check_reg(5'd11, 32'd245);
    check_reg(5'd12, 32'd13);
    check_reg(5'd13, 32'd16);
    check_reg(5'd14, 32'd1);
    check_reg(5'd15, 32'd0);
    check_reg(5'd16, 32'd7);
    check_reg(5'd17, 32'd0);
    check_reg(5'd18, 32'd21);
    check_reg(5'd19, 32'd5);
    check_reg(5'd20, 32'd0);
    check_reg(5'd21, 32'd7);
    check_reg(5'd22, 32'd0);
    check_reg(5'd23, 32'd12);
    check_mem(10'd0, 32'd13);
    check_mem(10'd1, 32'd21);
    if (errors == 0)
        $display("tb_MIPS_Top PASS");
    else
        $display("tb_MIPS_Top FAIL with %0d errors", errors);
    $finish;
end
endmodule
