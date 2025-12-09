`timescale 1ns / 1ps

module Tcounter(
input wire clk,
input wire rstn,
input wire [31:0] top_in,
input wire [31:0] cmp_in,
output wire PWM

    );
    
    reg [26:0] cnt;
    wire [26:0] top = top_in[26:0];
    wire [26:0] cmp = cmp_in[26:0];
    wire cnt_en = top_in[31];
    
    always @(posedge clk) begin : CNT_MOD
    
    if (rstn == 0)
    cnt <= 0;
    else if (cnt_en) begin
    cnt <= cnt + 1;
    if (cnt >= top)
    cnt <= 0;
    end
    else cnt <= 0;
    end
    
    assign PWM = (cnt < cmp) ? 1 : 0;
    
endmodule
