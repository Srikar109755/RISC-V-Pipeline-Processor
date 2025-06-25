`timescale 1ns / 1ps


module Commit_Unit( clk,
                    reset,
                    
                    commit_valid,
                    commit_dest_arch,
                    commit_value,
                    
                    arch_wr_addr,
                    arch_wr_data,
                    arch_wr_enable
                );
    input clk;
    input reset;
    
    input commit_valid;
    input [4:0] commit_dest_arch;
    input [31:0] commit_value;
    
    output reg [4:0] arch_wr_addr;
    output reg [31:0] arch_wr_data;
    output reg arch_wr_enable;
    
    always@(posedge clk or posedge reset) begin
        if (reset) begin
            arch_wr_enable <= 0;
        end
        
        else if (commit_valid) begin
            arch_wr_addr <= commit_dest_arch;
            arch_wr_data <= commit_value;
            arch_wr_enable <= 1;
        end
        
        else begin
            arch_wr_enable <= 0;
        end
    end
endmodule
