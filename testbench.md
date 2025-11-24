# TEST BENCH 작성법

## TEST BENCH는 시뮬레이션 용이므로 input output이 필요가 없음.

인스턴스 모듈의 인풋 아웃풋은 전부 wire로 설정.

기본적으로 다음과 같이 실행.

module A ( input α, input β, output [3:0] γ );

...

endmodule

`timescale 1ns/1ps

module A_tb ( );

wire a;
wire b;
wire c;

A A_inst (.α(a), .β(b), .γ(c));

#time 1 동작실행
#time 2 동작실행
..
....
endmodule

여기서, 동작 실행에서 <=를 쓰면 논블로킹이라 순차적이 아닌 동시 실행이 되므로 문제가 발생할 가능성이 높음.

그리고, 모듈마다 timescale 작성 해주면 좋음. 실제 합성에서는 영향이 안가고, 시뮬레이션에서만 영향 가는 코드이기 때문.
