`timescale 1ns / 1ps


module Speculation_Control( clk,
                            reset,
                            
                            predicted_taken,
                            actual_valid,
                            actual_taken,
                            actual_target,
                            
                            flush,
                            recover_pc
    );
    parameter PC_WIDTH = 32;
    input clk;
    input reset;
    
    input predicted_taken;
    input actual_valid;
    input actual_taken;
    input [PC_WIDTH-1 : 0] actual_target;
    
    output reg flush;
    output reg [PC_WIDTH-1 : 0] recover_pc;
    
    
    always@(posedge clk or posedge reset) begin
        
        if (reset) begin
            flush <= 0;
            recover_pc <= 0;
        end
            
        else begin
            if (actual_valid && (predicted_taken != actual_taken && (actual_taken && recover_pc != actual_target))) begin
                flush <= 1;
                recover_pc <= actual_valid ? (actual_taken ? actual_target : recover_pc + 4) : 0;           // next sequential 
            end
            
            else begin
                flush <= 0;
            end
        end 
    end
endmodule
