`timescale 1ns / 1ps


module Exception_Handler(
    input clk,
    input reset,
    
    input exception_occurred,
    input [31:0] exception_pc,                                          // Address where the exception occurred(Like Error)
    
    output reg recover,
    output reg [3:0] recover_rob_ptr,                                   // Flushes all the instrutions after it , including it
    output reg [31:0] trap_pc                                           // Jumps to memory addr like to handle the exception
    );
    parameter TRAP_BASE = 32'h00000080;                                 // Here the info like Error, Cannot divide by zero
    
    always@(posedge clk or posedge reset) begin
        
        if (reset) begin
            recover <= 0;
            recover_rob_ptr <= 0;
            trap_pc <= 0;
        end
        else if (exception_occurred) begin
            recover <= 1;
            trap_pc <= TRAP_BASE;                                       // Can be enhanced to vector per cause
            recover_rob_ptr <= 4'b0000;                                 // Restore to head of ROB (can be replaced with specific pointer)
        end
        else
            recover <= 0;                                               // All other cases
    end
endmodule
