`timescale 1ns / 1ps


module Precise_Retirement_Logic(
    input clk,
    input reset,
    
    input rob_commit_valid,                                         // Whether the instruction wants to retire or not
    input [4:0] rob_commit_arch,                                    // Instruction after the retirement can be free to update or not
    input exception_detected,
    output reg retirement_enable                                    // Retires register when it 1 else 0
    );
    
    always@(posedge clk) begin
        
        if (reset) begin
            retirement_enable <= 0;
        end 
        else if (exception_detected) begin
            retirement_enable <= 0;
        end 
        else if (rob_commit_valid) begin
            retirement_enable <= 1;
        end
        else begin
            retirement_enable <= 0;
        end
    end
endmodule
