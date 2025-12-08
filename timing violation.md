# timing violation에 대해 다룹니다.

## timing?

timing에는 세 가지가 존재. setup, hold, pulse width.

클럭 기반 시스템에서 발생.

slack = 요구시간(requirement) - 경로 지연(total delay)

일반적으로 요구시간은 클럭 주기로 표기 가능.

경로 지연은 클럭에 의해 시스템이 실행될 때, 래치를 안쓴다고 가정한다면 플립플롭 실행시간, 그 값이 다른 곳으로 이동하는데 걸리는 시간 등을 합친 값.


### slack < 0

slack < 0이면, 요구시간보다 경로 지연값이 더 크다는 걸 의미한다.

이는, 플립플롭에서 상승(혹은 하강) 클럭에서 다음 상승(혹은 하강)클럭이 올 때, 시스템이 제대로 처리되지 않았음을 뜻하고, 이로 인해 예기치 못한 오류가 발생하게 된다.

따라서, slack < 0이면 timing violation이 된다.

### slack > 0 

slack > 0이면, 요구시간이 경로 지연값보다 더 크다는 걸 의미한다.

이는, 플립플롭에서 상승(혹은 하강) 클럭에서 다음 상승(혹은 하강)클럭이 올 때, 시스템이 다 처리되었으므로 일반적으로는 오류가 나지 않는다.


### slack에 영향을 주는 요소

일반적으로, setup slack에서는 경로 지연값을 줄여야 한다.

어떤 시스템 블럭에서, 연산이 오래 걸리는 거는 최대한 피하는 게 좋다. (ex. divide, modulo... etc)

그리고, 일반적으로 hold slack에서는 경로 지연값을 어느 정도 늘려줘야 한다.

slack이 너무 작으면 양수여도 비정상적으로 작동할 수 있다.

## 정상작동 vs 비정상 작동

basys3에서, 초음파 거리 측정 모듈에 대해 보자.

여기서 정상적으로 작동하는 v파일에 대해 다음과 같은 타이밍을 가진다.

<img width="588" height="201" alt="image" src="https://github.com/user-attachments/assets/9529558e-83c8-4ab3-b790-2890a070a150" /> <img width="585" height="199" alt="image" src="https://github.com/user-attachments/assets/943c5f6b-a6bc-4017-987b-19c570289ea2" /> <img width="593" height="202" alt="image" src="https://github.com/user-attachments/assets/69708d6a-d194-44d6-859d-6d7cab439316" />


그리고 이 코드의 최종 연산값은 다음과 같이 표기된다. 

<img width="304" height="40" alt="image" src="https://github.com/user-attachments/assets/f4a0bf52-8ae3-4249-9013-868a7549926f" />



다음으로, 정상적으로 작동되지 않는 v파일은 다음과 같은 타이밍을 가진다.

<img width="588" height="192" alt="image" src="https://github.com/user-attachments/assets/43ece340-bcb1-43f8-af50-f2897d7995c6" /> <img width="581" height="194" alt="image" src="https://github.com/user-attachments/assets/9cfabc8f-ff08-4321-b246-51cc3a73de4c" /> <img width="588" height="187" alt="image" src="https://github.com/user-attachments/assets/cbbcb2d1-884b-42a0-b1ad-1ed69f224136" />


그리고 이 코드의 최종 연산값은 다음과 같이 표기된다.

<img width="275" height="46" alt="image" src="https://github.com/user-attachments/assets/eb3b6461-f8f0-40a8-acc7-af00980798e6" />


그리고 이는 다음과 같은 작동을 한다.


![20251208_144355(1)](https://github.com/user-attachments/assets/e8f96545-6248-4c69-b0d9-d91cf6adefed)



### 분석

583으로 나눈게 slack이 커서 문제 없어 보이지만, 실제로는 문제가 발생.

이는 slack의 문제가 아닌, 나눗셈 연산의 문제에서 발생.

583으로 나눈게 5830으로 나눈 것보다 더 빠르게 실행 --> 경로가 짧아짐

이로 인해서, 값을 빨리 받으려고 하므로, 결과적으로 멈추는 현상이 발생.

여기서는 setup을 줄였을 때 오히려 안정적으로 작동함.

## 결론

slack이 음수면 timing violation --> 이를 수정하지 않으면 위험!!

slack이 양수면 timing violation x 

그러나, timing violation이 없다고 해도, 제대로 동작하지 않는 문제가 생길 수 있음.

이럴 때는 역으로 timing을 낮추는 방향으로 가는 게 효과를 볼 수 있음.


