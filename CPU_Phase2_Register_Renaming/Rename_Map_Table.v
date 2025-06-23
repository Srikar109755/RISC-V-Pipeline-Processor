`timescale 1ns / 1ps


module Rename_Map_Table( clk,
                         reset,
                         allocate,
                         arch_dest_reg,
                         new_phys_reg,
                         src_reg1,
                         src_reg2,
                         src_phys_reg1,
                         src_phys_reg2
                    );
    input clk;
    input reset;
    
    // Allocation Interface
    input allocate;
    input [4:0] arch_dest_reg;
    input [5:0] new_phys_reg;
    
    // Read Interface
    input [4:0] src_reg1;
    input [4:0] src_reg2;
    output reg [5:0] src_phys_reg1;
    output reg [5:0] src_phys_reg2;
    
    reg [5:0] map_table [31:0];                                             // Mapping Arch reg to Physical reg
    
    integer i;
    
    always@(posedge clk or negedge reset) begin
        
        if (reset) begin
            // Mapping: x0 permanently mapped to P0
            for (i = 0; i <= 31; i = i+1) begin
                map_table[i] <= (i == 0) ? 6'd0 : 6'd0;
            end
        end
        
        else if (allocate && (arch_dest_reg !== 0))
            // Updating only non - zero(X0) registers
            map_table[arch_dest_reg] <= new_phys_reg;

    end
    
    always@(*) begin
        src_phys_reg1 <= map_table[src_reg1];
        src_phys_reg2 <= map_table[src_reg2];
    end
endmodule
