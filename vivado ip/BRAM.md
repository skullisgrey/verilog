# Block RAM을 AXI를 이용하여 접근하는 법을 다룹니다.<br>단순 저장은 Alone mode로 사용바람.

## Block RAM이란?

FPGA 내부에 있는 고속 메모리 블럭. 보통 저장소가 필요할 때 사용.

## Block design 생성

IP INTEGRATOR -> Create Block Design -> add IP -> ZYNQ Processing System, Block memory generator, AXI BRAM Controller 추가

<img width="699" height="329" alt="image" src="https://github.com/user-attachments/assets/773ae6df-028c-422c-b7bd-97e70de9c0a9" />


<img width="1137" height="759" alt="image" src="https://github.com/user-attachments/assets/6b5594c0-ac60-49af-a162-40c66c13a300" />

Block memory generator -> BRAM Controller mode 설정, True Dual Port RAM으로 Memory Type 설정.

<img width="535" height="28" alt="image" src="https://github.com/user-attachments/assets/485e138c-3adb-41c7-8eb1-21e6efb7214a" />

상단의 Automation 전부 클릭.

<img width="1119" height="423" alt="image" src="https://github.com/user-attachments/assets/f3b9cd16-b1f4-4e08-8c81-39e75dc74f91" />


Window - Address editor - Range 변경을 통해 BRAM Controller의 Range(Memory depth) 변경을 할 수 있다.

<img width="278" height="567" alt="image" src="https://github.com/user-attachments/assets/24a7f92d-6200-406b-879a-8852ab2585ef" />

<img width="926" height="166" alt="image" src="https://github.com/user-attachments/assets/65d1c1c5-3cd8-43ed-8204-4c03012d7b94" />

## BRAM 연결

Bram에 저장하고싶은 데이터를 Bram의 한 포트에 연결한다. 이 때, 데이터가 들어오는 포트는 Controller와 연결되면 안된다.

듀얼포트를 이용하였기에, 한 포트는 읽기 전용, 한 포트는 쓰기 전용으로 사용해야만 한다.

최종적으로 다음과 같은 형태로 만든다.

<img width="1372" height="562" alt="image" src="https://github.com/user-attachments/assets/d79c84b6-1e85-4ba4-a8e7-1a04f79408ce" />

이에 맞춰서 XDC을 추가한다. 여기서 xdc는 clk, rst, ena, we, addr up을 추가한다.

이 후, block design을 wrap 한다.

<img width="395" height="752" alt="image" src="https://github.com/user-attachments/assets/ca32a810-ae37-4044-9c99-fcbbf7becf0d" />

Wrap한 후, 비트스트림 생성, 그 후 Export -> include bitstream -> XSA파일 생성 후, Vitis에서 사용하면 된다.

## 주의사항

Bram Controller모드로 사용하였다면, 32비트 데이터 기준으로, 주소가 1단위가 아닌 4 단위로 올라가야 한다.

<img width="421" height="146" alt="image" src="https://github.com/user-attachments/assets/9c63d52b-d3a4-44a3-9fff-81ad07dc9531" />

여기서 보면, 데이터 x 데이터 깊이 최댓값이 30비트지만, 주소는 32비트로 할당되어있음 --> 주소가 1 단위로 올라가면 안 됨을 유추 가능.

따라서, 주소를 올릴 때는 최소 4 혹은 하위에 2'b00을 추가해준다.

예시)

```

output [31:0] addr;
reg [29:0] addr_cnt;

always @(posedge clk)
  if (rst) addr_cnt <= 0;
  else addr_cnt <= addr_cnt + 1;
end

assign addr = {addr_cnt, 2'b00};

```

