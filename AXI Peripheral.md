# 사용자 모듈을 AXI Peripheral로 만들어 제어가능한 IP로 만드는 법을 간단하게 설명.

## 예시는 인풋을 제어하는 걸 목표로 함.

## 사용자 IP 생성법

Tools -> Create and Package New IP -> Create a new AXI4 peripheral

<img width="321" height="398" alt="image" src="https://github.com/user-attachments/assets/8c87fcfb-9676-4f70-922c-377c4e164d6e" />

<img width="826" height="548" alt="image" src="https://github.com/user-attachments/assets/eca41026-d8df-4b60-8857-a99fbc763a53" />

<img width="821" height="557" alt="image" src="https://github.com/user-attachments/assets/c5d6be4a-56a2-4e1a-83eb-97822167f884" />

IP 이름, IP설명은 자유롭게 기입하기. // 단, 어떤 IP인지 알아볼 수 있게 하는 걸 권장.

<img width="1004" height="593" alt="image" src="https://github.com/user-attachments/assets/5b727a0c-b879-4240-97d0-cad7e35fc003" />

데이터 위스 및 레지스터 갯수 기입. 예시로 32개의 레지스터 사용.

또한, 인터페이스 이름은 구분가능하게 짓는걸 추천.

<img width="484" height="208" alt="image" src="https://github.com/user-attachments/assets/7c773d31-be67-44d8-b970-8b0e61e6aced" />

<img width="1094" height="575" alt="image" src="https://github.com/user-attachments/assets/d946aebd-edac-4447-a9e6-c806009b5139" />

레지스터 갯수 확인. 방금 32개의 레지스터를 선언해줬으므로 32개 생성.

### 모듈을 AXI로 만들기

기존 모듈을 디자인 소스에 추가한 후, 인풋 아웃풋을 Users to add ports here에 등록, Add user logic here에 모듈 인스턴스

<img width="496" height="208" alt="image" src="https://github.com/user-attachments/assets/d6b4f075-c5ad-4452-998f-b7f78797c9d5" />

<img width="479" height="491" alt="image" src="https://github.com/user-attachments/assets/aabd7157-e245-4252-ab47-5d6ecc00ef00" />

<img width="665" height="86" alt="image" src="https://github.com/user-attachments/assets/553ec07f-992f-42dd-b851-7bed12c4b039" />

여기서, rstn은 active low. active high모듈을 쓴다면, 이걸 반전시켜줘야함.

여기서 인풋을 32비트 slv_reg0을 사용.


이 후, 탑모듈의 Users to add ports here에 추가한 포트 등록.

<img width="1081" height="488" alt="image" src="https://github.com/user-attachments/assets/a8d42948-86bd-49ce-9219-d76e73cae454" />

이 후, 패키지 IP 매니저에서 File groups, Customization Parameters 등에 있는 상단 ! 모양 클릭.

<img width="1114" height="572" alt="image" src="https://github.com/user-attachments/assets/c1f58d4a-cb27-48ac-8134-72f60dd14a19" />


이상 없이 모든게 다 되면 다음과 같이 됨.

<img width="1112" height="575" alt="image" src="https://github.com/user-attachments/assets/7a98b127-9a0f-4e96-a410-36a2032c7fd6" />

Re - Package IP를 클릭, IP 최종 등록.

### 주의할 점

소스파일은 ip_repo - ip name directory -> hdl 폴더 내에 있어야만 함!


## 유저 IP 사용

Block design에서 Add ip -> 사용자 ip 이름 검색, 더한 후 Auto Connection.

<img width="295" height="425" alt="image" src="https://github.com/user-attachments/assets/4a5c465c-08f2-4151-8b54-d12d21c9db06" />

<img width="1369" height="570" alt="image" src="https://github.com/user-attachments/assets/19a7920b-6869-49f4-b901-82089c4bcadf" />

<img width="1126" height="586" alt="image" src="https://github.com/user-attachments/assets/6cd1ebaf-3d0a-4618-bba4-5e14ec12ea19" />


xdc 최종 확인 후, 비트스트림 생성 -> XSA파일 생성.

## 유저 IP Makefile 수정

vitis 2022.2 기준, 유저 IP가 있는 platform을 build하면 다음과 같은 오류가 나온다.

<img width="808" height="237" alt="image" src="https://github.com/user-attachments/assets/547c3f4a-7116-446d-8c28-910e273d7b2b" />

다음 경로에서 유저 IP의 Makefile을 보면 다음과 같이 나온다.

<img width="282" height="460" alt="image" src="https://github.com/user-attachments/assets/a81b2c12-9e29-4793-a44f-b910b7fb1839" />

<img width="1018" height="570" alt="image" src="https://github.com/user-attachments/assets/cb460a72-a035-4433-af4d-37435d1d1a30" />

Makefile에 내용이 없어서 빌드 오류가 뜬다.

이를 해결하기 위해, PS의 UART모듈에서 Makefile을 복사 붙여넣기 한다.

<img width="437" height="791" alt="image" src="https://github.com/user-attachments/assets/e210470d-fc88-4890-beb6-2680cb5f7299" />


zynq_fsbl_bsp, ps7_cortexa9_0에서도 유저 ip의 Makefile을 찾아 변경해준다.

그러면, build할 때 다음과 같이 오류가 안 뜨고 정상적으로 수행된다.

<img width="205" height="158" alt="image" src="https://github.com/user-attachments/assets/75258a98-fc70-4119-ac4a-d78815c00482" />

.경고, 에러 표시 사라짐 확인

## 주소 확인

slv_reg를 제어하므로, 주소를 알아야만 한다. 

유저 IP에서 h파일을 보면 다음과 같이 되어 있다.

<img width="478" height="648" alt="image" src="https://github.com/user-attachments/assets/1407c17e-500e-4291-bc73-a508573a56aa" />

slv reg 0만 사용할 것이므로, 오프셋은 0이 된다.

또, include 폴더에서 xparameters.h파일을 확인한다. 그러면 유저 IP의 주소를 확인할 수 있다.

<img width="571" height="157" alt="image" src="https://github.com/user-attachments/assets/3ba1c19a-3cae-4a95-af27-12c6969c8329" />

## Application project를 통하여 Slv_reg 제어

테스트 우선이므로 우선, application project 생성 후, sprj에서 sd카드 이미지 생성 체크아웃.

<img width="1017" height="522" alt="image" src="https://github.com/user-attachments/assets/1ea6ee0e-7a6e-49ed-9a4b-033d2d330892" />

이 후, 다음과 같은 코드 작성.

```

#include "xil_io.h"
#include "xparameters.h"
#include <stdio.h>

#define slv_reg0 XPAR_LED_CONTROL_0_LEDON_BASEADDR

int main() {

    printf("program start...\r\n");
    
    char c;

    while (1) {
        c = inbyte(); // UART에서 키 입력 대기

        if (c == 's') {
            Xil_Out32(slv_reg0, 124999999); // SLV 레지스터에 124_999_999 특정값으로 변경가능
            printf("on\r\n");                      // 상태 출력
        } else {
            Xil_Out32(slv_reg0, 0);         // SLV 레지스터 0
            printf("off\r\n");                     // 상태 출력
        }
    }
}

```

s키를 누르면 reg에 특정 값을 주고, 그 외는 0을 줌.

Build -> rus as를 통해 컴파일


## 알아두면 나름 좋은 점

현재, slv reg를 input에 연결을 하였지만, 이를 output 혹은 output신호를 저장하는 레지스터로 쓸 경우,

이를 vitis를 이용하여 읽어낼 수 있다.

방법은 위에서와 같이 모듈의 주소를 가져와서 사용하면 된다.
