`timescale 1ns / 1ps


module Rename_Logic( clk,
                     reset,
                     valid,
                     src_arch_reg1,
                     src_arch_reg2,
                     dest_arch_reg,
                     src_phys_reg1,
                     src_phys_reg2,
                     dest_phys_reg,
                     rename_valid
    );
    input clk;
    input reset;
    
    // Incoming Instructions
    input valid;
    input [4:0] src_arch_reg1;
    input [4:0] src_arch_reg2;
    input [4:0] dest_arch_reg;
    
    // Outputs for execution stage
    output [5:0] src_phys_reg1;
    output [5:0] src_phys_reg2;
    output [5:0] dest_phys_reg;
    output rename_valid;
    
    wire free_valid;
    wire [5:0] new_phys_reg;
    reg allocate;
    
    Rename_Map_Table rename_table (
        .clk(clk),
        .reset(reset),
        .allocate(allocate),
        .arch_dest_reg(dest_arch_reg),
        .new_phys_reg(new_phys_reg),
        .src_reg1(src_arch_reg1),
        .src_reg2(src_arch_reg2),
        .src_phys_reg1(src_phys_reg1),
        .src_phys_reg2(src_phys_reg2)
    );
    
    
    Free_List free_list (
        .clk(clk),
        .reset(reset),
        .allocate(allocate),
        .allocate_valid(rename_valid),
        .allocated_phys_reg(new_phys_reg),
        .free_valid(1'b0),                                              // No freeing
        .free_phys_reg(6'b0)
    );
    
    assign dest_phys_reg = new_phys_reg;
    
    always@(*) begin
        allocate = (valid && dest_arch_reg != 5'd0);
    end
endmodule
