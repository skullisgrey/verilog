# Verilog에서, LATCH 문제에 대해 다룹니다

## LATCH란?

기본적으로 LATCH는 Level sensitive memory : clk이 high 혹은 low일 때 데이터를 저장함

clk가 켜져있거나 꺼져있을 때, 데이터가 계속 통과하게됨. 타이밍이 맞지 않으면 glitch 발생 가능.

쉽게 말하자면, 수도꼭지를 열었을 때 물이 계속 흐르는데, 수도꼭지를 잠글 때 물이 안흐르게 되지만, 완전히 물이 멈추는 게 아닌, 순간 물이 튀는 현상이 생기는 것과 유사함.

## 일반적으로, 합성 단계에서 LATCH가 생기면 문제가 생기는 이유

LATCH는 기본적으로 Level trigger : clock이 high 혹은 low일때 작동함. FF는 edge에서만 동작하니 타이밍 분석과 디버깅이 쉽지만, latch는 어려워짐.

의도하지 않는 동작이 발생함 : 어떤 조건문에서, if (A) a = b; 여기서, 조건을 만족하지 않는다면, a는 기존 값이 되고, 이로 인해서 LATCH가 생김

LATCH를 만들기 위해서 자원이 낭비됨 : FF나 다른 회로가 LATCH의 역할을 수행하게 되므로 효율 떨어짐

RESET의 명확성이 없음 : FF는 reset으로 초기화를 할 수 있지만, latch는 초기화 불가능.

glitch 문제 발생 : level trigger라서, 신호가 흔들리면 glitch 발생, 의도하지 않은 동작 발생 가능성 생김

### 따라서, 의도한 LATCH가 아니라면, 대부분은 LATCH를 피해야만 함.

### 하드웨어에서 보면, meta stable을 방지하기 위한 것과 유사.

## LATCH는 기본적으로 always같은 조합 논리 블록에서 assign 누락 시에 발생

예를 들어서, 다음과 같은 경우를 보자.

always@ (*) begin
case(sel)
2'b00: y=a;
2'b01: y=b;
2'b10: y=c;
2'b11: y=d;
endcase
end


여기서, 경우의 수가 전부 다 있으니 문제가 없을 거 같지만, 실제로는 0도 아니고 1이 아닌 정의되지 않은 값 생길 수 있음

이로 인해서 latch가 생기고, 의도하지 않은 동작 발생 가능.

따라서, 다음과 같은 형태로 변경.

always@ (*) begin
case(sel)
2'b00: y=a;
2'b01: y=b;
2'b10: y=c;
2'b11: y=d;
default: y=1'bx;
endcase
end

혹은, default가 아닌, case 전에 기본값으로 부여해 줄 수 있음.

### 같은 의미로, if의 경우에는, else로 처리해줘야 LATCH가 생기지 않음.
