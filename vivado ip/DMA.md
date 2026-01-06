# AXI Direct Memory Access에 대해 다룹니다.

## Direct Memory Access란?

CPU 개입 없이 저장장치 -> 주변장치로 데이터를 흘려주는 장치. CPU개입이 없으므로 하드웨어 부담을 줄여줌.

## 연결법

add IP -> dma 혹은 AXI Direct Memory Access 검색 -> 추가

<img width="293" height="423" alt="image" src="https://github.com/user-attachments/assets/fbd31b13-d18a-40bb-9cc8-877cb074e74a" />

<img width="1148" height="808" alt="image" src="https://github.com/user-attachments/assets/8722b293-4ce2-4e20-aa22-39c6d326deaf" />

Scatter gather Engine은 여러 메모리에서 순차적으로 읽거나 쓸 수 있는 기능. 하나의 메모리만 사용, 데이터를 보내기만 한다면 비활성화 권장.

이 후, Auto connection을 누르면 자동으로 연결이 된다.

Window - address editor를 누르면 다음과 같이 나온다.

<img width="268" height="520" alt="image" src="https://github.com/user-attachments/assets/c612a7bd-dc01-478b-8839-c9ca536dc4e2" />

<img width="945" height="300" alt="image" src="https://github.com/user-attachments/assets/63d854c6-2e5f-46c3-b648-2ac65a03080c" />

현재 BRAM을 사용하고 있으므로, BRAM이 DMA 내부에 존재한다. (Master - Slave)

이렇게 확인이 되었다면, DMA를 통해 BRAM의 데이터를 읽거나 쓸 수 있는 상태가 된다.

<img width="266" height="239" alt="image" src="https://github.com/user-attachments/assets/b406d9ae-0797-4188-8f16-6f345a59a5c3" />

MM2S를 통해 주거나 데이터를 주거나 받을 수 있음.

현재 Scatter gather Engine이 비활성화 되어 있는 상태이므로, 데이터를 보내는 것만 가능. 그러나, 활성화하고 데이터를 받는 것도 이와 유사함.

### tkeep : 유효비트. 예를 들어 0001이면 하위 8비트만 유효데이터, 1111이면 32비트 데이터 전부 유효.

### tlast : DMA에서 보내는 데이터에서, 마지막 데이터임을 나타내는 신호

### tready : DMA에서 받는 신호로, 이를 받아야 데이터를 보낼 수 있음.

### tvalid : 유효 데이터 구간. 실제 보내는 데이터와 마스킹됨.

DMA를 통해 데이터를 흘려보내면, DMA에 연결된 클럭마다 데이터를 보냄.
