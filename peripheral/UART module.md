# UART TX/RX module에 대해 다룹니다.

## Basys3, 100MHz 기준으로 작성. 코드는 첨부파일 참고 바람.

## 1. TX 코드 분석

```

localparam [4:0]
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

```

### START_BIT, STOP_BIT는 8비트 데이터의 포장지 개념. 이게 없으면 기본적으로 터미널에서도 인식 불가능.<br>총 2개의 묶음을 보냄.

```

parameter CLOCK_SPEED = 100_000_000;
 parameter BAUD_RATE = 9600;
 parameter CLOCKS_PER_BIT = (CLOCK_SPEED / BAUD_RATE) + 1;

```

### baud rate, clock에 따라서 값 조절 가능.

```

reg key_in = 0;
 reg [18:0] key_cnt = 0;
 always @(posedge clk) begin
     if(rst) key_cnt <= 0;
     else if (key_cnt <= 499_999) begin
         key_cnt <= 0;
         key_in <= ~key_in;
         end else key_in <= key_in + 1;
 end

wire key_in_now = key_in;
reg key_in_prev;

always @(posedge clk) begin
    if(rst) key_in_prev <= 0;
    else key_in_prev <= key_in_now;
end

wire key_pressed = (key_in_prev == 0 && key_in_now == 1);

```
### 100MHz기준, 10ms마다 데이터를 송신시키는 오토 키

```

reg [4:0] tx_current_state, tx_next_state;
 
 always @(posedge clk) begin
     if (rst) tx_current_state <= TX_IDLE;
     else tx_current_state <= tx_next_state;
 end

wire tx_counter_en = (tx_current_state != TX_IDLE) ? 1 : 0;

```

### FSM에서의 현재 상태 반영. 또한 IDLE상태가 아닐 때, counter enable. --> UART통신 on

```

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

```

### 카운터의 한 주기마다 1비트씩 송신을 가능하게 하는 신호 출력

```

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

```

### FSM상태. IDLE에서 key_pressed가 활성화되면, START_BIT -> D0 -> D1.... -> D7 -> STOP_BIT<br>이를 한 번 더 반복해서 2개의 8비트 데이터를 보냄.

```

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

```
### 데이터를 보내는 순서. 여기서는 하위비트부터 보냄.



## 2. RX 코드 분석

```

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

```

### TX에서, DONE이 추가 --> FSM에서 수신완료 상태를 나타냄. 실제 데이터는 없음.<br> 이는 데이터를 안전하게 처리하기 위함.

```

parameter CLOCK_SPEED = 100_000_000;
parameter BAUD_RATE = 9600;
parameter CLOCKS_PER_BIT = (CLOCK_SPEED / BAUD_RATE) + 1;

```

### 클럭, baud rate에 따라 값 조절 가능.

```

reg [3:0] rx_current_state = 0, rx_next_state = 0;

always @(posedge clk) begin
    if(rst) rx_current_state <= RX_IDLE;
    else rx_current_state <= rx_next_state;
end

wire rx_counter_en = (rx_current_state != RX_IDLE) ? 1 : 0;

```

### FSM의 현재 상태 표시, IDLE상태가 아닐 때 카운터 on --> FSM 전이 및 1비트당 데이터 수신 가능

```

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

```

### 카운터 주기당 FSM의 상태 전이. 이 때 카운터 주기당 1비트 데이터 수신 가능

```

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

```

### FSM. rxd가 0일 때, 총 8비트의 데이터 수신.

```
wire data_sampling_en = ((rx_counter == (CLOCKS_PER_BIT/2 -1))
                        &&(rx_current_state > RX_START_BIT)
                        &&(rx_current_state < RX_STOP_BIT)) ? 1 : 0;

```

### 카운터의 주기의 중앙, 현재 상태가 D0~D7일 때 데이터 샘플링 on<br><br>RX_DONE에서는 8비트 데이터의 끝부분을 확인하니 범위 내에 포함되도 됨.

```

reg [7:0] rx_data = 0;

always @(posedge clk) begin
    if(rst) rx_data <= 0;
    else if(data_sampling_en)
        rx_data <= {rxd, rx_data[7:1]};

end                        

```

### 데이터 샘플링. 이 때, rx_data는 상위 비트에서부터 채워나가는 방식.<br>위의 tx가 하위비트부터 보내는 방식이니, rx는 상위비트에서부터 채워나가는 방식이어야만 함.<br>상위비트에서 채워나가면서, 하위비트로 시프트하는 방식.

```

assign led = rx_data;

```

### 데이터 수신 시각적 확인용 led. 없어도 됨.
