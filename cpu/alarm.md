# alarm.v파일에 대해 간단히 다룹니다.<br><br>코드는 파일을 참고해 주시길 바랍니다.<br><br>또한 이는 FSM이며, 특정 조건 하에서 작동을 하는 구조입니다. 

## FSM이란?

### Finite State Machine 혹은 유한 기계 상태

정해진 수의 상태를 가지며, 특정 입력이나 조건에 따라 상태가 다른 상태로 전환.

카운터는 FSM의 한 예시가 될 수 있음.

reg [31:0] count;<br>
reg toggle = 0;<br>

always @(posedge clk) begin<br>
if (rst) begin<br>
count <= 0;<br>
toggle <= 0;<br>
end else begin<br>
if (count <= 49_999_999) begin<br>
count <= count + 1;<br>
end else begin<br>
count <= 0;<br>
toggle <= ~toggle;<br>
end<br>
end<br>
end<br>


특정 입력 : rst가 0 아니면 1 

rst가 1 : count, toggle이 0 --> 초기화

rst가 0 : count가 49999999 이하면 count에 1을 더함.

count가 49999999를 초과하면 count 초기화 후, toggle의 값을 반전.

이를 클럭 상승마다 반복함.

특정 입력 및 조건이 count 값, rst값.

# alarm.v 분석

## 요약

front_door, rear_door, window 셋 중 하나 이상의 값이 1이 되고, keypad 값이 0011라면, 특정 시간이 지난 뒤에 alarm_siren 값이 1이 됨.

실생활에서 응용되는 사례는 냉장고가 있음.

냉장고 문을 일정 시간 열어두면, 삐 삐 경보가 울리는 것과 같음.

## localparameter

localparam[1:0]<br>
armed = 2'b00,<br>
disarmed = 2'b01,<br>
wait_delay = 2'b10,<br>
alarm = 2'b11;<br>

한 눈에 알아보기 쉽게 하기 위함. 안 써도 상관은 없음.

## sensors

assign sensors = {front_door, rear_door, window };<br>

sensors는 총 3비트. sensors[2]은 front_door, sensors[1]는 rear_door, sensors[0]은 window

## reset

always @ (posedge clk or posedge rst) begin : sync<br>

if (rst == 1'b1)<br>
curr_state <= disarmed;<br>
else<br>
curr_state <= next_state;<br>

end<br>

reset이 1이면 비활성.

## 신호 변화

always @(curr_state or sensors or keypad or count_done) begin : comb<br>

start_count = 1'b0;<br>

case(curr_state)<br>
disarmed: begin<br>
if (keypad == 4'b0011)<br>
next_state = armed;<br>
else<br>
next_state = disarmed;<br>
alarm_siren = 1'b0;<br>
end<br>

armed: begin<br>
if (sensors != 3'b000)<br>
next_state = wait_delay;<br>
else if (sensors == 3'b000 && keypad == 4'b1100)<br>
next_state = disarmed;<br>
else next_state = armed;<br>
alarm_siren = 1'b0;<br>
end<br>

wait_delay: begin<br>
start_count = 1'b1;<br>
if (count_done == 1'b1 && keypad == 4'b0011)<br>
next_state = alarm;<br>
else if (count_done == 1'b0 && keypad == 4'b1100)<br>
next_state = disarmed;<br>
else next_state = wait_delay;<br>
alarm_siren = 1'b0;<br>
end<br>

alarm: begin<br>
if (keypad == 4'b1100)<br>
next_state = disarmed;<br>
else next_state = alarm;<br>
alarm_siren = 1'b1;<br>
end<br>

default: begin next_state = disarmed;<br>
alarm_siren = 1'b0;<br>
end<br>

endcase<br>
end <br>


####curr_state, sensors, keypad, count_done 변화에 따라 블럭 작동

### 시스템 활성화

처음 disarmed 상태에서 keypad가 0011이면 armed로 변경 --> keypad 0011이면 시스템 활성

armed상태에서 sensors가 000이면 대기.

### 시스템 활성화 후

sensors가 000 외의 값이면 대기 상태로

sensors 000, keypad 1100이면 비활성 --> keypad 1100은 시스템 비활성

그 외에는 armed상태로. 이 때는 alarm_siren은 0. --> sensors가 000이므로 활성화 할 필요가 없음.

### sensors가 000 외의 상태일 때, 대기중

start_count가 기본적으로 1로.

keypad 0011, count_done이 1이면 alarm상태로

keypad 1100, count_done이 0이면 비활성화

그 외는 다시 대기 상태로. 이 때는 alarm_siren은 0

### alarm 상태일 때.

keypad가 1100이면 비활성화

그 외에는 다시 알람 상태로 가고, alarm_siren은 1 --> 알람 활성화!!

### 이 외의 경우

시스템 비활성화 및 alarm_siren은 0

## 알람 대기 시간

always @(posedge clk or posedge rst) begin: timer<br>
if (rst == 1'b1)<br>
delay_counter = 0;<br>
else if (curr_state == wait_delay && start_count == 1'b1)<br>
delay_counter = delay_counter + 1'b1;<br>
else delay_counter = 0;<br>
end

assign count_done = (delay_counter == 10) ? 1'b1 : 1'b0; // default 100 1000 1000 30<br>

### 리셋

rst가 1이면 리셋

### 카운트 시작

만약 현재 상태가 대기 상태이고, start_count가 1이면 카운트 시작.

클럭 상승마다 delay_count에 1이 더해짐.

그 외에는 delay_count가 0이 됨.

### 카운트 종료

delay_count가 10이 되면, count_done이 1이 됨. 그 외에는 0 

이 때 앞에 알람 상태가 활성화, 알람이 울리게 됨.

카운트는 clk의 주기에 따라 달라지므로, assign count_done = (delay_counter == **x** ) ? 1'b1 : 1'b0

여기서 **x**를 바꿔주거나, 클럭의 주기를 바꿔주면서 대기 시간 조절 가능.



