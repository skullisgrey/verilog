# counter에 대해 다룹니다.

## basys3, 100MHz기준으로 작성. 자세한 코드는 첨부파일 참고 바람.

## 코드 분석

```

 reg [26:0] cnt;
    wire [26:0] top = top_in[26:0];
    wire [26:0] cmp = cmp_in[26:0];
    wire cnt_en = top_in[31];

```

### cnt값은 최대 27비트<br><br>top, cmp는 각각 인풋의 27비트에서 할당<br><br>카운트 활성화는 top의 최상위 비트

```

 always @(posedge clk) begin : CNT_MOD
    
    if (rstn == 0)
    cnt <= 0;
    else if (cnt_en) begin
    cnt <= cnt + 1;
    if (cnt >= top)
    cnt <= 0;
    end
    else cnt <= 0;
    end
    
    assign PWM = (cnt < cmp) ? 1 : 0;

```

### 카운터의 최대값은 top --> 카운트의 ARR 조정. cnt가 top값을 넘어가면 0으로 초기화.<br><br> cnt < cmp면 1, cnt >= cmp면 0 --> cmp값 제어로 duty 제어.<br>한 주기에서 cmp가 클수록 pwm이 1인 시간이 길어짐.

