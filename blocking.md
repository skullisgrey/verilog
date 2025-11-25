# 블럭 내에서 blockng과 nonblocking에 대해 다룹니다.

## blocking? nonblocking?

간단하게 직렬, 병렬을 생각하면 편하다. 직렬은 순서대로 가고, 병렬은 동시에 처리.


## 예시

다음과 같은 예시를 보자. 

<img width="268" height="267" alt="image" src="https://github.com/user-attachments/assets/1ead98c9-fcf0-427c-a892-7bf0b71f2d77" />


스케매틱은 다음과 같다.

<img width="1058" height="468" alt="image" src="https://github.com/user-attachments/assets/2603887b-2130-4408-93f8-f4613d849504" />



다음과 같은 예시를 보자.

<img width="281" height="296" alt="image" src="https://github.com/user-attachments/assets/f01d6e18-ea3c-4cd9-bafa-9e233ca356ed" />


스케매틱은 다음과 같다.

<img width="1070" height="495" alt="image" src="https://github.com/user-attachments/assets/377b260f-17f9-42ac-9a42-866792cc961f" />


여기서는 차이가 발생하지 않는다. 왜냐면 always 두 개를 써서 나눴기 때문이다.

이렇게 쓰면, 논블로킹, 블로킹 상관 없이 논블로킹으로 실행이 된다.



이제 다음과 같은 예시를 보자.

<img width="314" height="323" alt="image" src="https://github.com/user-attachments/assets/d080d378-8858-49c3-81a7-05e0701f9892" />



스케매틱은 다음과 같다.

<img width="968" height="492" alt="image" src="https://github.com/user-attachments/assets/7c9569f7-a90f-47f9-9ea7-11a123734db5" />



다음과 같은 예시를 보자.

<img width="275" height="324" alt="image" src="https://github.com/user-attachments/assets/0e19f3de-f2b3-4a6e-9901-e002e768dcd3" />



스케매틱은 다음과 같다.

<img width="1118" height="485" alt="image" src="https://github.com/user-attachments/assets/fb02890b-81ee-4b68-91e7-2b1dcb842816" />


전자는 블로킹을 사용하였기에, 순서대로 b -> a -> c 순으로 전달이 되지만, 후자는 논블로킹이기 때문에, b -> a와 a->c가 동시에 실행.



## Simulation

시뮬레이션에서, 다음과 같은 TB를 사용한다.

<img width="341" height="365" alt="image" src="https://github.com/user-attachments/assets/92543670-014f-4359-9165-53017a90eb8b" />



블로킹에서의 경우를 보자.

<img width="253" height="274" alt="image" src="https://github.com/user-attachments/assets/50dbdaf2-10ec-4b8c-b659-4229f2a7ed70" />


시뮬레이션 결과는 다음과 같다.

<img width="1045" height="575" alt="image" src="https://github.com/user-attachments/assets/88bfc236-8b6c-43c0-9be2-699d225df3f0" />




논블로킹에서의 경우를 보자.

<img width="265" height="264" alt="image" src="https://github.com/user-attachments/assets/b9b92449-b50a-448b-a82c-82efc7f3c993" />


시뮬레이션 결과는 다음과 같다.

<img width="1047" height="591" alt="image" src="https://github.com/user-attachments/assets/d5c67d2f-042b-4315-bf7d-ca5cea1afbb8" />


### 결과 및 분석

블로킹에서의 경우 : c가 x가 아니게 되는 시간이 5ns

논블로킹에서의 경우 : c가 x가 아니게 되는 시간이 15ns


첫 clk가 rising 되는 시간이 5ns임!!

블로킹의 경우, 이 때 b -> a -> c 순서로 전달되기 때문에 맞아떨어짐.

논블로킹의 경우, b->a와 동시에 a->c 순서로 전달. a는 기본값이 할당되지 않았기 때문에, x값을 가짐 --> 첫 클럭 rising일 때, c는 x값 할당.

두번째 rising에, a의 값은 b의 값을 가짐. 따라서, 두번째 rising인 15ns에 c에 b의 값이 할당됨.


블로킹, 논블로킹을 사용함에 따라서 이와 같은 차이가 발생할 수가 있음.
