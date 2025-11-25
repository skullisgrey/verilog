# TEST BENCH 작성법

## TEST BENCH는 시뮬레이션 용이므로 input output이 필요가 없음.

인스턴스 모듈의 인풋 아웃풋은 전부 wire로 설정.

기본적으로 다음과 같이 실행.

module A ( input α, input β, output [3:0] γ );

...

endmodule

`timescale 1ns/1ps

module A_tb ( );

reg a;
reg b;
wire c;

A A_inst (.α(a), .β(b), .γ(c));

#time 1 동작실행
#time 2 동작실행
..
....
endmodule

여기서, 동작 실행에서 <=를 쓰면 논블로킹이라 순차적이 아닌 동시 실행이 되므로 문제가 발생할 가능성이 높음.

그리고, 모듈마다 timescale 작성 해주면 좋음. 실제 합성에서는 영향이 안가고, 시뮬레이션에서만 영향 가는 코드이기 때문.

## 주의사항

인스턴스 모듈에서 인풋이나 아웃풋이 wire, reg 상관 없이, TEST BENCH에서는 input은 reg, output은 wire로 지정해줘야 함!

이는 input은 시간에 따라 값을 변경해줘야 하기 때문에, wire가 아닌 reg로 작동.

### TB에서 시간에 대해 작동하는 거를 쓸 때 조심!!

예시를 보자.

always begin 
#5 clk <= ~clk;
#30 b <= ~b;
end

원래 원하는 동작은 5단위로 clk 토글과 동시에 30단위로 b가 토글.

<=가 논블로킹이라서, clk는 5단위로 토글, b는 30단위로 토글로 보이지만, 기본적으로 #는 딜레이, 블로킹임.

따라서, 위 함수는 순서대로 진행이 됨. --> 5 뒤에 clk 토글, 그 후 30뒤에 b가 토글. 이렇게 되면 clk는 결과적으로 35단위로 토글하게 됨.

원래 원하는 동작을 실행하려면, always를 나누어야만 함.

원하는 동작을 위해서는 다음과 같이 한다.

always #5 clk <= ~clk;

always #30 b <= ~b;

이렇게 해야 원래 원하는 동작으로 시뮬레이션.


