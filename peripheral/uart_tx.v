`timescale 1ns / 1ps

module uart_tx(
      input wire clk,
      input wire rst,
      input wire [15:0] sw,
//      input wire key_in,  // 오토 키 필요하면 추가하고, 아래의 reg key_in 부분 지울것.
      output reg txd      
    );
        
  localparam [4:0]           // 8비트 데이터 한묶음만 원한다면 TX_START_BIT2 ~ TX_STOP_BIT2 지울것.
        TX_IDLE = 5'b11111,
        TX_START_BIT = 5'b00000,
        TX_D0 = 5'b00001,
        TX_D1 = 5'b00010,
        TX_D2 = 5'b00011,
        TX_D3 = 5'b00100,
        TX_D4 = 5'b00101,
        TX_D5 = 5'b00110,
        TX_D6 = 5'b00111,
        TX_D7 = 5'b01000,
        TX_STOP_BIT = 5'b01001,
        TX_START_BIT2 = 5'b01010,
        TX_D8 = 5'b01011,
        TX_D9 = 5'b01100,
        TX_D10 = 5'b01101,
        TX_D11 = 5'b01110,
        TX_D12 = 5'b01111,
        TX_D13 = 5'b10000,
        TX_D14 = 5'b10001,
        TX_D15 = 5'b10010,
        TX_STOP_BIT2 = 5'b10011;
 parameter CLOCK_SPEED = 100_000_000;
 parameter BAUD_RATE = 9600;
 parameter CLOCKS_PER_BIT = (CLOCK_SPEED / BAUD_RATE) + 1;
 
 reg key_in = 0;
 reg [18:0] key_cnt = 0;
 always @(posedge clk) begin
     if(rst) key_cnt <= 0;
       else if (key_cnt == 499_999) begin
         key_cnt <= 0;
         key_in <= ~key_in;
         end else key_in <= key_in + 1;
 end
 
 
 reg [4:0] tx_current_state, tx_next_state;
 
 always @(posedge clk) begin
     if (rst) tx_current_state <= TX_IDLE;
     else tx_current_state <= tx_next_state;
 end

wire tx_counter_en = (tx_current_state != TX_IDLE) ? 1 : 0;
reg [13:0] tx_counter = 0;

always @(posedge clk) begin
    if(rst) tx_counter<=0;
    else if (tx_counter_en) begin
        tx_counter <= tx_counter + 1;
        if (tx_counter == (CLOCKS_PER_BIT - 1))
            tx_counter <=0;
    end
        else tx_counter <= 0;
end

wire state_transition = (tx_counter == (CLOCKS_PER_BIT - 1)) ? 1 : 0;

wire key_in_now = key_in;
reg key_in_prev;

always @(posedge clk) begin
    if(rst) key_in_prev <= 0;
    else key_in_prev <= key_in_now;
end

wire key_pressed = (key_in_prev == 0 && key_in_now == 1);

always @(*) begin
    tx_next_state = tx_current_state;
    case(tx_current_state)
        TX_IDLE: if(key_pressed) tx_next_state = TX_START_BIT;
        TX_START_BIT: if(state_transition) tx_next_state = TX_D0;
        TX_D0: if(state_transition) tx_next_state = TX_D1;
        TX_D1: if(state_transition) tx_next_state = TX_D2;
        TX_D2: if(state_transition) tx_next_state = TX_D3;
        TX_D3: if(state_transition) tx_next_state = TX_D4;
        TX_D4: if(state_transition) tx_next_state = TX_D5;
        TX_D5: if(state_transition) tx_next_state = TX_D6;
        TX_D6: if(state_transition) tx_next_state = TX_D7;
        TX_D7: if(state_transition) tx_next_state = TX_STOP_BIT;
        TX_STOP_BIT: if(state_transition) tx_next_state = TX_START_BIT2;
        TX_START_BIT2: if(state_transition) tx_next_state = TX_D8;
        TX_D8: if(state_transition) tx_next_state = TX_D9;
        TX_D9: if(state_transition) tx_next_state = TX_D10;
        TX_D10: if(state_transition) tx_next_state = TX_D11;
        TX_D11: if(state_transition) tx_next_state = TX_D12;
        TX_D12: if(state_transition) tx_next_state = TX_D13;
        TX_D13: if(state_transition) tx_next_state = TX_D14;
        TX_D14: if(state_transition) tx_next_state = TX_D15;
        TX_D15: if(state_transition) tx_next_state = TX_STOP_BIT2;
        TX_STOP_BIT2: if(state_transition) tx_next_state = TX_IDLE;
        default: tx_next_state = TX_IDLE;
    endcase

end

always @(*) begin
    txd = 1;
    case(tx_current_state)
        TX_START_BIT: txd = 0;
        TX_D0: txd = sw[0];
        TX_D1: txd = sw[1];
        TX_D2: txd = sw[2];
        TX_D3: txd = sw[3];
        TX_D4: txd = sw[4];
        TX_D5: txd = sw[5];
        TX_D6: txd = sw[6];
        TX_D7: txd = sw[7];
        TX_STOP_BIT: txd = 1;
        TX_START_BIT2: txd = 0;
        TX_D8: txd = sw[8];
        TX_D9: txd = sw[9];
        TX_D10: txd = sw[10];
        TX_D11: txd = sw[11];
        TX_D12: txd = sw[12];
        TX_D13: txd = sw[13];
        TX_D14: txd = sw[14];
        TX_D15: txd = sw[15];
        TX_STOP_BIT2: txd = 1;
        default: txd = 1;
    endcase
end

endmodule
