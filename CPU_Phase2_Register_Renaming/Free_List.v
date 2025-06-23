`timescale 1ns / 1ps


module Free_List( clk,
                  reset,
                  allocate,
                  allocate_valid,
                  allocated_phys_reg,
                  free_valid,
                  free_phys_reg
    );
    input clk;
    input reset;
    input free_valid;
    input [5:0] free_phys_reg;
    input allocate;
    output reg allocate_valid;
    output reg [5:0] allocated_phys_reg;
    
    reg [63:0] free_bitmap;                                             // 64 Physical Registers
    
    integer i;
    
    always@(posedge clk or posedge reset) begin
        
        if (reset) begin
            free_bitmap <= 64'hFFFFFFFFFFFFFFFE;                        // P0 is reserved for X0
        end
        
        else begin
            if (allocate) begin
                for(i = 0; i<= 63; i = i+1) begin
                    if(free_bitmap[i]) begin
                        free_bitmap[i] <= 0;                            // Allocating
                        allocated_phys_reg <= i[5:0];                   // integer is 32-bit wide
                        allocate_valid <= 1'b1;
                    end
                end
            end
            
            else begin
                allocate_valid <= 1'b0;
            end
            
            if (free_valid) begin
                free_bitmap[free_phys_reg] <= 1'b1;
            end
        end
    end
endmodule
