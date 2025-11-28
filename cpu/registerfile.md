# Register File에 대해 다룹니다.

## 코드

```
module RegisterFile (
input wire clk,
input wire [4:0] A1,
output reg [31:0] RD1,
input wire [4:0] A2,
output reg [31:0] RD2,
input wire [4:0] A3,
input wire [31:0] WD3,
input wire WE3
);

reg [31:0] x[0:31];

integer i;
initial begin
for(i=0;i<31;i=i+1) // i=1 --> if.rd.else release
x[i]=0;
x[5]=6;
x[9]='h2004;
end

always @(*)
RD1 <= x[A1];

always @(*)
RD2 <= x[A2];

always @(posedge clk)
if(WE3 && A3!=0)
x[A3] <= WD3;

endmodule
```

## 분석

32비트의 레지스터 x를 총 32개 생성.

initial을 통해 레지스터 초기화. 5, 9번째 레지스터 값은 각각 6과 'h2004로 기본 설정.

RD1의 값은 x[A1]에서 불러옴.

RD2의 값은 x[A2]에서 불러옴.

상승 클럭때마다 아래와 같은 조건 실행.

만약 WE3가 1이고, A3가 0이 아닌 경우, x[A3]에 WD3 값을 저장.

