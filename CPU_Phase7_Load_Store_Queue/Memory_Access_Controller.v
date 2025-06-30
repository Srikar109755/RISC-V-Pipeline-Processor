`timescale 1ns / 1ps


module Memory_Access_Controller(
    input clk,
    input reset,
    
    input mem_write,
    input mem_read,
    
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
    );
    
    reg [31:0] memory [0:255];
    
    always@(posedge clk or posedge reset) begin
        
        if (reset) begin
            read_data <= 0;
        end
        else begin
            if (mem_write) 
                memory[address >> 2] <= write_data;
            if (mem_read)
                read_data <= memory[address >> 2];
        end
    end
endmodule
