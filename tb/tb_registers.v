// Checks register file writes, the hardwired zero register and write-first read forwarding.
module tb_registers;
reg clk;
reg reg_write;
reg [4:0] r_reg_1;
reg [4:0] r_reg_2;
reg [4:0] write_register;
reg [31:0] write_data;
wire [31:0] read_data1;
wire [31:0] read_data2;
integer errors;
registers dut (
    .clk(clk),
    .reg_write(reg_write),
    .r_reg_1(r_reg_1),
    .r_reg_2(r_reg_2),
    .write_register(write_register),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);
task check(input [127:0] name, input [31:0] got, input [31:0] expected);
    begin
        if (got !== expected) begin
            errors = errors + 1;
            $display("FAIL %0s: got %0d, expected %0d", name, got, expected);
        end
    end
endtask
task write_reg(input [4:0] index, input [31:0] value);
    begin
        write_register = index;
        write_data = value;
        reg_write = 1'b1;
        @(posedge clk);
        #1;
        reg_write = 1'b0;
    end
endtask
always #5 clk = ~clk;
initial begin
    errors = 0;
    clk = 1'b0;
    reg_write = 1'b0;
    r_reg_1 = 5'd0;
    r_reg_2 = 5'd0;
    write_reg(5'd5, 32'd123);
    write_reg(5'd6, 32'd456);
    r_reg_1 = 5'd5;
    r_reg_2 = 5'd6;
    #1;
    check("read port 1", read_data1, 32'd123);
    check("read port 2", read_data2, 32'd456);
    write_reg(5'd0, 32'hDEADBEEF);
    r_reg_1 = 5'd0;
    #1;
    check("zero register stays zero", read_data1, 32'd0);
    write_register = 5'd5;
    write_data = 32'd999;
    reg_write = 1'b1;
    r_reg_1 = 5'd5;
    #1;
    check("write-first forwarding", read_data1, 32'd999);
    reg_write = 1'b0;
    #1;
    check("no forwarding when reg_write low", read_data1, 32'd123);
    if (errors == 0)
        $display("tb_registers PASS");
    else
        $display("tb_registers FAIL with %0d errors", errors);
    $finish;
end
endmodule
