`timescale 1ns / 1ps

module security (
input wire front_door,
input wire rear_door,
input wire window,
input wire [3:0] keypad,
input wire clk,
input wire rst,
input wire timer_osc,
output reg alarm_siren
);

localparam[1:0]
armed = 2'b00,
disarmed = 2'b01,
wait_delay = 2'b10,
alarm = 2'b11;

reg [1:0] curr_state = 0, next_state = 0;
reg start_count = 0;
wire count_done;
wire [2:0] sensors;
reg [31:0] delay_counter = 0;

assign sensors = {front_door, rear_door, window };

always @ (posedge clk or posedge rst) begin : sync

if (rst == 1'b1)
curr_state <= disarmed;
else
curr_state <= next_state;

end

always @(curr_state or sensors or keypad or count_done) begin : comb

start_count = 1'b0;

case(curr_state)
disarmed: begin
if (keypad == 4'b0011)
next_state = armed;
else
next_state = disarmed;
alarm_siren = 1'b0;
end

armed: begin
if (sensors != 3'b0000)
next_state = wait_delay;
else if (sensors == 3'b0000 && keypad == 4'b1100)
next_state = disarmed;
else next_state = armed;
alarm_siren = 1'b0;
end

wait_delay: begin
start_count = 1'b1;
if (count_done == 1'b1 && keypad == 4'b0011)
next_state = alarm;
else if (count_done == 1'b0 && keypad == 4'b1100)
next_state = disarmed;
else next_state = wait_delay;
alarm_siren = 1'b0;
end

alarm: begin
if (keypad == 4'b1100)
next_state = disarmed;
else next_state = alarm;
alarm_siren = 1'b1;
end

default: begin next_state = disarmed;
alarm_siren = 1'b0;
end

endcase
end 

always @(posedge clk or posedge rst) begin: timer
if (rst == 1'b1)
delay_counter = 0;
else if (curr_state == wait_delay && start_count == 1'b1)
delay_counter = delay_counter + 1'b1;
else delay_counter = 0;
end

assign count_done = (delay_counter == 10) ? 1'b1 : 1'b0; // default 100 1000 1000 30

endmodule
