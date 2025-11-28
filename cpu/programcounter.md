# Program Counter (PC)에 대해 다룹니다.

## 코드 
```
module program_counter (
input wire rst,
input wire clk,
input wire [31:0] pc_next,
output wire [31:0] pc_out
);

reg [31:0] pc;

always @(posedge clk or posedge rst) begin
if (rst)
pc <= 32'h00001000;
else
pc <= pc_next;

end

assign pc_out = pc;

endmodule
```

## 분석

상승 클럭 혹은 rst가 상승할 때 (off->on)일 때 블럭이 작동.

만약 rst가 on이면 pc는 00001000이 됨 --> 기본값 초기화

rst가 off면, pc_next 값은 pc에 저장.

pc의 값은 pc_out에 연결.

### 참고

initial pc <= 32'h00001000; 넣어두는것도 좋음
