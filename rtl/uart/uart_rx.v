// Receives one 8N1 UART byte and pulses valid when it is complete.
module uart_rx #(
    parameter CLKS_PER_BIT = 217
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       rx,
    output reg  [7:0] data,
    output reg        valid
);

localparam IDLE = 2'd0, START = 2'd1, PAYLOAD = 2'd2, STOP = 2'd3;

reg [1:0]  state;
reg [15:0] count;
reg [2:0]  index;
reg        rx_meta, rx_sync;

always @(posedge clk) begin
    if (reset) begin
        rx_meta <= 1'b1;
        rx_sync <= 1'b1;
    end
    else begin
        rx_meta <= rx;
        rx_sync <= rx_meta;
    end
end

always @(posedge clk) begin
    if (reset) begin
        state <= IDLE;
        count <= 16'd0;
        index <= 3'd0;
        data  <= 8'd0;
        valid <= 1'b0;
    end
    else begin
        valid <= 1'b0;
        case (state)
            IDLE: begin
                count <= 16'd0;
                index <= 3'd0;
                if (!rx_sync)
                    state <= START;
            end
            START: begin
                if (count == (CLKS_PER_BIT - 1) / 2) begin
                    count <= 16'd0;
                    state <= rx_sync ? IDLE : PAYLOAD;
                end
                else
                    count <= count + 16'd1;
            end
            PAYLOAD: begin
                if (count == CLKS_PER_BIT - 1) begin
                    count <= 16'd0;
                    data  <= {rx_sync, data[7:1]};
                    if (index == 3'd7)
                        state <= STOP;
                    else
                        index <= index + 3'd1;
                end
                else
                    count <= count + 16'd1;
            end
            STOP: begin
                if (count == CLKS_PER_BIT - 1) begin
                    count <= 16'd0;
                    valid <= 1'b1;
                    state <= IDLE;
                end
                else
                    count <= count + 16'd1;
            end
        endcase
    end
end

endmodule
