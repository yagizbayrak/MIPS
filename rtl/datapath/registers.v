module registers(
  input clk,
  input reg_write,
  input  [4:0] r_reg_1, r_reg_2, write_register,
  input  [31:0] write_data,
  output [31:0] read_data1,
  output [31:0] read_data2
);

reg [31:0] all_registers [0:31];

// WRITE 
always @(posedge clk) begin
    if (reg_write && (write_register != 5'd0))
        all_registers[write_register] <= write_data;
end

// READ 
assign read_data1 = (r_reg_1 == 5'd0) ? 32'd0 : all_registers[r_reg_1];
assign read_data2 = (r_reg_2 == 5'd0) ? 32'd0 : all_registers[r_reg_2];

endmodule
