`timescale 1ns / 1ps

module uart_rx(
input wire clk,
input wire rst,
input wire rxd,
  output wire [7:0] led  // 시각적 확인 필요없으면 지워도 됨.
);

 localparam [3:0]
        RX_IDLE = 4'b1111,
        RX_START_BIT = 4'b0000,
        RX_D0 = 4'b0001,
        RX_D1 = 4'b0010,
        RX_D2 = 4'b0011,
        RX_D3 = 4'b0100,
        RX_D4 = 4'b0101,
        RX_D5 = 4'b0110,
        RX_D6 = 4'b0111,
        RX_D7 = 4'b1000,
        RX_DONE = 4'b1001,
        RX_STOP_BIT = 4'b1010;
parameter CLOCK_SPEED = 100_000_000;
parameter BAUD_RATE = 9600;
parameter CLOCKS_PER_BIT = (CLOCK_SPEED / BAUD_RATE) + 1;

reg [3:0] rx_current_state = 0, rx_next_state = 0;

always @(posedge clk) begin
    if(rst) rx_current_state <= RX_IDLE;
    else rx_current_state <= rx_next_state;
end

wire rx_counter_en = (rx_current_state != RX_IDLE) ? 1 : 0;

reg [13:0] rx_counter = 0;

always @(posedge clk) begin
    if(rst) rx_counter <= 0;
    else if (rx_counter_en) begin
        rx_counter <= rx_counter + 1;
        if(rx_counter == (CLOCKS_PER_BIT - 1))
            rx_counter <= 0;
        end
        else rx_counter <= 0;
end

wire state_transition = (rx_counter == (CLOCKS_PER_BIT - 1)) ? 1 : 0;

always @(*) begin
    rx_next_state = rx_current_state;
    case(rx_current_state)
    RX_IDLE: if(rxd==0) rx_next_state = RX_START_BIT;
    RX_START_BIT: if(state_transition) rx_next_state = RX_D0;
    RX_D0: if(state_transition) rx_next_state = RX_D1;
    RX_D1: if(state_transition) rx_next_state = RX_D2;
    RX_D2: if(state_transition) rx_next_state = RX_D3;
    RX_D3: if(state_transition) rx_next_state = RX_D4;
    RX_D4: if(state_transition) rx_next_state = RX_D5;
    RX_D5: if(state_transition) rx_next_state = RX_D6;
    RX_D6: if(state_transition) rx_next_state = RX_D7;
    RX_D7: if(state_transition) rx_next_state = RX_DONE;
    RX_DONE: if(rxd) rx_next_state = RX_STOP_BIT;
    RX_STOP_BIT: if(state_transition) rx_next_state = RX_IDLE;
    default: rx_next_state = RX_IDLE;
    endcase
end

wire data_sampling_en = ((rx_counter == (CLOCKS_PER_BIT/2 -1))
                        &&(rx_current_state != RX_START_BIT)
                        &&(rx_current_state != RX_STOP_BIT)) ? 1 : 0;
                        
reg [7:0] rx_data = 0;

always @(posedge clk) begin
    if(rst) rx_data <= 0;
    else if(data_sampling_en)
        rx_data <= {rxd, rx_data[7:1]};

end                        

assign led = rx_data;

endmodule
