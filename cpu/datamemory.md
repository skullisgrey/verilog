# DataMemory에 대해 다룹니다.

## 코드

```
module DATAMEMORY (
input wire clk,
input wire rst,
input wire [31:0] data_in,
output reg [31:0] data_out,
input wire we,
input wire [31:0] wd
);

reg [31:0] memory [0:'h2010>>2];

always @(*)
data_out <= memory[data_in[31:2]];

integer i;
initial begin
for (i = 0; i<('h2010>>2); i = i+1) begin
memory[i] = 0;
end
memory[('h2000>>2)] = 10;
end

always @(posedge clk)
memory[data_in[31:2]] <= wd;

endmodule
```

## 분석

32비트 레지스터 memory가 총 'h805개 존재. // 2053개

data_out은 총 2^30 - 1개의 메모리를 가질 수 있음 --> 32비트는 4바이트이므로, 약 4GB. // reg에서 2053개만 제한을 걸어뒀기에, 사용에 주의!

initial 내부는 메모리 초기화를 시킴. --> 'h2000번째 메모리는 값이 10!

상승클럭마다 wd값이 memory에 기록. 


