`timescale 1ns / 1ps


module BTB( clk,
            reset,
            
            lookup_valid,
            lookup_pc,
            
            hit,
            target_pc,
            
            update_valid,
            update_pc,
            update_target
          );
    parameter DEPTH = 16, PTR_WIDTH = 4, PC_WIDTH = 32;
    input clk;
    input reset;
    
    input lookup_valid;
    input [PC_WIDTH-1 : 0] lookup_pc;
    
    output reg hit;
    output reg [PC_WIDTH-1 : 0] target_pc;
    
    input update_valid;
    input [PC_WIDTH-1 : 0] update_pc;
    input [PC_WIDTH-1 : 0] update_target;
    
    reg valid [DEPTH-1 : 0];
    reg [PC_WIDTH-1 : 0] tag [DEPTH-1 : 0];
    reg [PC_WIDTH-1 : 0] trgt [DEPTH-1 : 0];
    
    integer i;
    
    
    always@(posedge clk or posedge reset) begin
        
        if (reset) begin
            for(i = 0; i < DEPTH; i = i+1) begin
                valid[i] <= 0;
            end
            hit <= 0;
            target_pc <= 0;
        end
        
        else begin
            if (lookup_valid) begin
                hit <= 0;
                target_pc <= 0;
                
                for(i = 0; i < DEPTH; i = i+1) begin
                    if (valid[i] && tag[i] == lookup_pc) begin
                        hit <= 1;
                        target_pc <= trgt[i];
                    end
                end
            end
            
            if (update_valid) begin
                tag[update_pc[PTR_WIDTH-1 : 0]] <= update_pc;
                trgt[update_pc[PTR_WIDTH-1 : 0]] <= update_target;
            end
        end
    end
endmodule
