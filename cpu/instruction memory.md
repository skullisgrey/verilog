# instruction memory에 대해 다룹니다.

## 코드
```
module instruction_memory (
input wire [31:0] pc_in,
output reg [31:0] instr_out
);

always @ (*) begin 
case(pc_in)
32'h00001000: instr_out = 32'hFFC4A303;
32'h00001004: instr_out = 32'h0064A423;
32'h00001008: instr_out = 32'h0062E233;
32'h0000100C: instr_out = 32'hFE420AE3;
default: instr_out = 32'h00000000;
endcase
end
endmodule
```

## 분석

pc에서 보낸 신호를 읽고, 이에 따라 신호를 생성함.

들어오는 신호에서, 00001000 + 4n 일 때만 신호 생성.(n은 0 이상의 정수)

이 외에는 00000000으로 보냄.

들어오는 신호는 주소이고, 각 주소에 대응되는 신호가 들어있음. // 도서관에서 책장 번호마다 책 분야가 나뉜걸 생각하면 나름 적절함.
