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


## if의 경우의 예시

다음과 같은 경우를 보자.

<img width="259" height="420" alt="image" src="https://github.com/user-attachments/assets/c63e4f04-fe51-4f21-9183-87f34f431d53" />


스케매틱은 다음과 같이 나온다.

<img width="1148" height="343" alt="image" src="https://github.com/user-attachments/assets/933cc28e-9e99-4fb6-90d8-5a93d250303f" />



래치가 생성되지 않았다.


다음의 경우를 보자.

<img width="228" height="407" alt="image" src="https://github.com/user-attachments/assets/aa9e6a86-3a71-43b7-9564-46178fc60b35" />


스케매틱은 다음과 같이 나온다.

<img width="1202" height="408" alt="image" src="https://github.com/user-attachments/assets/c6f311c9-89f9-4c68-ad27-fa600a5ca273" />



21mux가 3개에서 7개로 늘어났고, 마지막에 latch가 생성되었다.

else 하나만 안넣었을 뿐인데, 회로가 더 복잡해지고, latch까지 생성되었다.


## case 경우의 예시

다음과 같은 경우를 보자.

<img width="250" height="386" alt="image" src="https://github.com/user-attachments/assets/f0635f21-bbb6-42e5-8c8c-ad8a0d3f40e9" />


스케매틱은 다음과 같이 나온다.

<img width="847" height="488" alt="image" src="https://github.com/user-attachments/assets/fe5f4d7f-d190-4921-b29d-b0da2bc9326a" />



다음과 같은 경우를 보자.

<img width="320" height="440" alt="image" src="https://github.com/user-attachments/assets/04dc884d-4b35-4da9-b8af-36c38c2c26a6" />


스케매틱은 다음과 같이 나온다.

<img width="864" height="478" alt="image" src="https://github.com/user-attachments/assets/091d8f20-8fc6-4304-b180-5630549b671b" />



다음과 같은 경우를 보자.

<img width="240" height="405" alt="image" src="https://github.com/user-attachments/assets/de2ba7cc-790e-4fba-a8c4-4ab0a0f461be" />


스케매틱은 다음과 같이 나온다.

<img width="836" height="479" alt="image" src="https://github.com/user-attachments/assets/06a397bc-3f0b-47f8-89e3-f43affdbfa46" />



다음과 같은 경우를 보자.

<img width="235" height="402" alt="image" src="https://github.com/user-attachments/assets/f308abaa-296c-45a5-814d-0a3a451480cc" />


스케매틱은 다음과 같이 나온다.


<img width="828" height="477" alt="image" src="https://github.com/user-attachments/assets/8f4cc2d4-fc52-42d1-9c37-bdfbd22fb336" />


다음과 같은 경우를 보자.


<img width="271" height="396" alt="image" src="https://github.com/user-attachments/assets/d69344f1-7269-41d4-86f8-2220d5f1a0ca" />


스케매틱은 다음과 같이 나온다.




<img width="1006" height="480" alt="image" src="https://github.com/user-attachments/assets/21410010-4d43-4c31-9fc3-f67970bdac72" />




다음과 같은 경우를 보자.


<img width="223" height="396" alt="image" src="https://github.com/user-attachments/assets/73fc2e94-d83c-494a-bc01-65f65e6ee68c" />


스케매틱은 다음과 같이 나온다.



<img width="877" height="490" alt="image" src="https://github.com/user-attachments/assets/3a60be88-a684-446b-b798-30fe5294ce10" />



wire에 선언된 a, b, c, d가 전부 다 들어가지 않는다면, 래치가 생성된다.


### CASE는 IF에 비해 상대적으로 latch 생성 조건이 더 타이트하지만, case의 경우에도 latch 및 mux 증가가 발생할 수 있다.




## if에서 조심해야 할 점.

다음과 같은 경우를 보자. 


<img width="414" height="573" alt="image" src="https://github.com/user-attachments/assets/5a14efd5-9e32-499e-8baa-ada3a8a65861" />


스케매틱은 다음과 같다.


<img width="697" height="562" alt="image" src="https://github.com/user-attachments/assets/0afe260e-900d-4e1d-9052-dda62bc5625f" />




if로 들어가기 전, en0~3의 값이 기본적으로 할당되어 있다.

따라서, else가 없어도, 예외사항이 없어지기 때문에 저 상황에서 문제가 없고, latch가 발생하지 않는다.




다음과 같은 경우를 보자.


<img width="421" height="588" alt="image" src="https://github.com/user-attachments/assets/7e7d2106-8624-4d19-927d-48d0685b86f4" />


스케매틱은 다음과 같다.



<img width="977" height="499" alt="image" src="https://github.com/user-attachments/assets/6ae50a19-2ba2-4458-92a9-48e403e1c759" />


latch가 생긴 이유는, else만 보면 문제가 없어 보이지만, if 내에서 보면 맨 처음의 경우는 en 1~3의 경우가 빠져있기 때문에 예외가 생기고, latch가 발생한다.


그러므로, 예외사항을 없애려면 처음에 기본값을 주어주는 것이 좋다.








