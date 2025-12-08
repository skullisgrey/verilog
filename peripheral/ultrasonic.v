`timescale 1ns / 1ps

module ultrasonic_fsm(
input wire clk,
input wire rst,
input wire echo,
output reg trig_start,
output wire [13:0] distance_measure
    
    );
    
    localparam [2:0]
        IDLE = 0,
        TRIG = 1,
        WAIT = 2,
        MEASURE = 3,
        TENMS = 4;
        
    reg [2:0] current_state, next_state;

    reg [10:0] cnt12us = 0;
    
    reg waiting_start;
    reg [15:0] cnt460us = 0;
    
    reg measure_start;
    reg [24:0] cnt25ms = 0;
    
    reg tenms_start;
    reg [19:0] cnt10ms = 0;
    
    always @(posedge clk) begin
        if (rst) current_state <= IDLE;
        else current_state <= next_state;
    end
    
    always @(*) begin
        next_state = current_state;
        trig_start = 0;
        waiting_start = 0;
        measure_start = 0;
        tenms_start = 0;
        case(current_state)
            IDLE: begin
            if (rst == 0 ) next_state = TRIG;
            end
            TRIG: begin
            trig_start = 1;
            if (cnt12us >=1_599) next_state = WAIT;
            
            end
            WAIT: begin
            waiting_start = 1;
            if (echo) next_state = MEASURE;
            else if (cnt460us >= 45_999) next_state = TRIG;
            
            end
            MEASURE: begin
            measure_start = 1;
            if (echo == 0) begin             
            next_state = TENMS;
            end else if (cnt25ms >= 25'd1_999_999) next_state = TRIG;
            
            end
            TENMS: begin
            tenms_start = 1;
            if (cnt10ms >= 20'd999_999) next_state = IDLE;
            
            end
            default: next_state = IDLE;
        endcase
    end    
    
    
    
    always @(posedge clk) begin
        if (trig_start == 0) begin
        cnt12us <= 0; 
        end else if (cnt12us == 1_599) begin
        cnt12us <= 0;
        end else cnt12us <= cnt12us + 1;
    end 
    
    always @(posedge clk) begin
        if (waiting_start == 0) begin
          cnt460us <= 0;
        end else if (cnt460us == 45_999) begin
          cnt460us <= 0;
        end else cnt460us <= cnt460us + 1;
    end
    
    always @(posedge clk) begin
        if (measure_start == 0) begin
          cnt25ms <= 0;
        end else if (cnt25ms == 1_999_999) begin
          cnt25ms <= 0;
        end else cnt25ms <= cnt25ms + 1;
    end
    
    always @(posedge clk) begin
        if (tenms_start == 0) begin
          cnt10ms <= 0;
        end else if (cnt10ms == 999_999) begin
          cnt10ms <= 0;
        end else cnt10ms <= cnt10ms + 1;
    end

    reg [24:0] distance = 0;
    
    always @(posedge clk) begin
    if (rst) distance <= 0;
    else if (current_state == MEASURE && (echo == 0)) begin
        distance <= cnt25ms;
    end
    end    
    
    assign distance_measure = distance/5830;
    
endmodule
