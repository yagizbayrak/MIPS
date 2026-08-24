// Shifts one 8N1 UART byte out when send is pulsed.
module uart_tx #(
    parameter CLKS_PER_BIT = 217
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       send,
    input  wire [7:0] data,
    output reg        tx,
    output wire       busy
);

localparam IDLE = 2'd0, START = 2'd1, PAYLOAD = 2'd2, STOP = 2'd3;

reg [1:0]  state;
reg [15:0] count;
reg [2:0]  index;
reg [7:0]  shifter;

assign busy = (state != IDLE);

always @(posedge clk) begin
    if (reset) begin
        state   <= IDLE;
        count   <= 16'd0;
        index   <= 3'd0;
        shifter <= 8'd0;
        tx      <= 1'b1;
    end
    else begin
        case (state)
            IDLE: begin
                tx    <= 1'b1;
                count <= 16'd0;
                index <= 3'd0;
                if (send) begin
                    shifter <= data;
                    state   <= START;
                end
            end
            START: begin
                tx <= 1'b0;
                if (count == CLKS_PER_BIT - 1) begin
                    count <= 16'd0;
                    state <= PAYLOAD;
                end
                else
                    count <= count + 16'd1;
            end
            PAYLOAD: begin
                tx <= shifter[0];
                if (count == CLKS_PER_BIT - 1) begin
                    count   <= 16'd0;
                    shifter <= {1'b0, shifter[7:1]};
                    if (index == 3'd7)
                        state <= STOP;
                    else
                        index <= index + 3'd1;
                end
                else
                    count <= count + 16'd1;
            end
            STOP: begin
                tx <= 1'b1;
                if (count == CLKS_PER_BIT - 1) begin
                    count <= 16'd0;
                    state <= IDLE;
                end
                else
                    count <= count + 16'd1;
            end
        endcase
    end
end

endmodule
