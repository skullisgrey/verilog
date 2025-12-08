# 초음파 거리 측정기에 대해 다룹니다.

### basys3 기준으로 작성됨. 자세한 코드는 첨부파일 참조 바람.

## 코드 분석

```

 localparam [2:0]
        IDLE = 0,
        TRIG = 1,
        WAIT = 2,
        MEASURE = 3,
        TENMS = 4;

```

### FSM 상태 값 정의. 

```

reg [2:0] current_state, next_state;

    reg [10:0] cnt12us = 0;
    
    reg waiting_start;
    reg [15:0] cnt460us = 0;
    
    reg measure_start;
    reg [24:0] cnt25ms = 0;
    
    reg tenms_start;
    reg [19:0] cnt10ms = 0;
    
    always @(posedge clk) begin
        if (rst) current_state <= IDLE;
        else current_state <= next_state;
    end

```

### 카운터 레지스터 및 상태 관련

```

    always @(*) begin
        next_state = current_state;
        trig_start = 0;
        waiting_start = 0;
        measure_start = 0;
        tenms_start = 0;
        case(current_state)
            IDLE: begin
            if (rst == 0 ) next_state = TRIG;
            end
            TRIG: begin
            trig_start = 1;
            if (cnt12us >=1_599) next_state = WAIT;
            
            end
            WAIT: begin
            waiting_start = 1;
            if (echo) next_state = MEASURE;
            else if (cnt460us >= 45_999) next_state = TRIG;
            
            end
            MEASURE: begin
            measure_start = 1;
            if (echo == 0) begin             
            next_state = TENMS;
            end else if (cnt25ms >= 25'd1_999_999) next_state = TRIG;
            
            end
            TENMS: begin
            tenms_start = 1;
            if (cnt10ms >= 20'd999_999) next_state = IDLE;
            
            end
            default: next_state = IDLE;
        endcase
    end    

```

### FSM상태. <br><br> TRIG상태 : 약 16μs동안 초음파를 쏨.<br><br> WAIT상태 : 쏜 초음파가 반사되어 들어올 때 까지 대기. 초음파가 들어오면 MEASURE 상태로. 만약 460μs를 넘어가면 다시 TRIG 상태로.  <br><br> MEASURE 상태 : echo가 1에서 0이 될 때까지 시간을 측정. 만약 20ms를 넘어서면 다시 TRIG 상태로. 시간을 측정하고 나면, TENMS상태로. <br><br> TENMS상태 : 10ms 대기 후, IDLE 상태로.

```

always @(posedge clk) begin
        if (trig_start == 0) begin
        cnt12us <= 0; 
        end else if (cnt12us == 1_599) begin
        cnt12us <= 0;
        end else cnt12us <= cnt12us + 1;
    end 
    
    always @(posedge clk) begin
        if (waiting_start == 0) begin
          cnt460us <= 0;
        end else if (cnt460us == 45_999) begin
          cnt460us <= 0;
        end else cnt460us <= cnt460us + 1;
    end
    
    always @(posedge clk) begin
        if (measure_start == 0) begin
          cnt25ms <= 0;
        end else if (cnt25ms == 1_999_999) begin
          cnt25ms <= 0;
        end else cnt25ms <= cnt25ms + 1;
    end
    
    always @(posedge clk) begin
        if (tenms_start == 0) begin
          cnt10ms <= 0;
        end else if (cnt10ms == 999_999) begin
          cnt10ms <= 0;
        end else cnt10ms <= cnt10ms + 1;
    end

```

### 각 상태가 될 때 마다 카운터.

```

 reg [24:0] distance = 0;
    
    always @(posedge clk) begin
    if (rst) distance <= 0;
    else if (current_state == MEASURE && (echo == 0)) begin
        distance <= cnt25ms;
    end
    end    
    
    assign distance_measure = distance/5830;

```

### MEASURE상태에서, 카운터의 마지막 값을 distance에 저장.<br><br> 그리고 이 값을 5830으로 나눠서 cm값으로 출력.
