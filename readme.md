# VERILOG 사용 가이드

## 기본적 문법, 사용법 등...

### 기본적으로, module - endmodule로 하나의 모듈을 작성.

모듈에는 인풋과 아웃풋을 지정해야됨.

wire는 기본적으로 데이터가 흐르는 배관, reg는 기본적으로 연결되면서 저장도 되는, 특정 경우에만 오픈되는 배관이라고 생각하면 됨.

module modulename ( input wire A, output reg B); ... endmodule 이렇게 작성.

모듈은 하나의 하드웨어라고 생각하면 편함.

결과적으로는, 여러 모듈을 만들어서 연결이 가능함 --> pcb위에 여러 부품을 올린 뒤, 라우팅 하는 것과 같음.

### input, output처럼 하드웨어에 직접 제어하는 용도가 아니라면, 모듈 내에 wire 혹은 reg 사용

예를 들어서, 중간 배선 및 중간 저장고 역할이 필요하다면 모듈 내에 wire reg 사용.

vivado 기준, input output이 지정되어 있다면 무조건 xdc에서 지정을 해줘야 하기 때문에, xdc에서 지정할 필요가 없다면 input output이 아닌, 내부에서 wire reg 지정.

module modulename (input wire A, output reg B); 
wire C;
reg D;
...
endmodule

### [width-1, 0] 형태를 통해서 벡터 지정 가능.

예를 들어서, wire [31:0] C; 라고 하면, C는 C[0], C[1], C[2] ..... , C[31] 총 C는 32비트.

사용할 때, [31:20] 이런식으로도 사용이 가능.

### 탑 모듈에서 하위 모듈을 인스턴스 할 때, 인풋 아웃풋 지정이 다시 필요함.

예를 들어서, 하위 모듈이 module low_module (input wire A, output reg B); ... endmodule이라면,

상위 모듈에서는 module top_module (input wire C, output reg D); low_module module1 (.A(C), .B(D)); 이런 식으로 사용.

만약 하위 모듈에서 쓰지 않는 것이 있다면, 괄호를 비워두면 됨. 예를 들어서 아웃풋을 안쓴다면, .B() 이런식으로 쓰면 됨.

### 동작 묶는 법

기본적으로 begin ... end로 묶음.

이는 C에서 { } 와 동일함.

### assign

연속할당으로, wire 타입 신호에 연속 계산을 통하여 연결할 때 사용. 

assign A = ... ; 이렇게 사용 가능.

여기서, 왼쪽은 write가 가능한 wire만 사용, 왼쪽은 read만 가능한 reg 사용도 무방함.

wire A; wire B; reg C; 이렇게 있다고 하면,

assign A = B와C의 연산; 이건 되지만, assign C = A와B의 연산; 이러면 안 됨. --> C는 reg이고, read만 가능.

위에서 말했다시피, wire는 데이터가 흐르는 배관이고, assign은 이를 연결해주는건데, reg는 특정 경우에만 열리는 배관이므로, 충돌이 발생하는 거라고 이해하면 편함. // 데이터가 흘러야 되는데, 연결했더니 어느 부분에서 막혀서 흐르지 못하는 상황이 생김

### always

특정 조건에서 동작하는 블럭. 

기본적으로 always @ (조건) 이렇게 적음.

모든 값에 대해서 변할 때는, *이고, 어떤 특정 값이 변할때는 특정 값만 적음.

예를 들어서. clk라는 값이 변할때 실행하는거면, always @(clk) begin ... end 이렇게 적음. 모든 값에 대해서는 always @(*) begin ... end

always에서는 posedge negedge 를 적을 수 있음. // posedge : 상승에지, negedge : 하강에지

조건이 여러개면 or을 쓸 수 있음.

예를 들어서, clk가 상승, reset이 하강일 때라면, always @(posedge clk or negedge reset) begin ... end

조건에서, 일반적인 논리연산 기호는 쓸 수 없음. 예를 들어서, always @(clk == 1) begin ... end 이건 불가능.

### 조건문

if, for, case, while 등 사용 가능.

단, 일반적으로 혼자 쓸 수는 없고, always나 initial, generate 같은 블럭 안에서만 사용 가능. verilog에서는 while은 잘 안 씀.

### blocking, nonblocking

일반적으로 = 는 블로킹. 반면, <=는 논블로킹. always블록 안에서는 거의 <=를 사용함.

테스트 벤치에서는 시간에 따른 시뮬레이션을 할 때, <=를 쓰면 시뮬레이션이 순서대로 실행되지 않으므로 주의!

### 벡터 합성

예를 들어서, [3:0]a, b이고, [3:0] sum, c_out이 있다고 하면, {c_out, sum} = a + b; 에서, c_out은 a+b의 결과에서 상위 1비트에 할당, sum은 나머지 3비트 할당.

{c_out, sum}을 [4:0] X라고 보면, X의 [3:0]은 sum, X[4]는 c_out이라고 보면 됨.

