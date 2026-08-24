// Thirty-two entry register file with write-first forwarding so a writeback is visible to decode in the same cycle.
module registers(
  input clk,
  input reset,
  input reg_write,
  input  [4:0] r_reg_1, r_reg_2, write_register,
  input  [31:0] write_data,
  input  [4:0] dbg_reg,
  output [31:0] read_data1,
  output [31:0] read_data2,
  output [31:0] dbg_data
);

reg [31:0] all_registers [0:31];
integer i;

// WRITE 
always @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < 32; i = i + 1)
            all_registers[i] <= 32'd0;
    end
    else if (reg_write && (write_register != 5'd0))
        all_registers[write_register] <= write_data;
end

// READ 
assign read_data1 = (r_reg_1 == 5'd0) ? 32'd0 :
                    (reg_write && (write_register == r_reg_1)) ? write_data : all_registers[r_reg_1];
assign read_data2 = (r_reg_2 == 5'd0) ? 32'd0 :
                    (reg_write && (write_register == r_reg_2)) ? write_data : all_registers[r_reg_2];

assign dbg_data = all_registers[dbg_reg];

endmodule
