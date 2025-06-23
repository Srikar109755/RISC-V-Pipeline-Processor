`timescale 1ns / 1ps


module Top_Phase2( clk,
                   reset,
                   valid,
                   src_arch_reg1,
                   src_arch_reg2,
                   dest_arch_reg
    );
    input clk;
    input reset;
    input valid;
    input [4:0] src_arch_reg1;
    input [4:0] src_arch_reg2;
    input [4:0] dest_arch_reg;
    
    wire [5:0] src_phys_reg1;
    wire [5:0] src_phys_reg2;
    wire [5:0] dest_phys_reg;
    wire rename_valid;
    
    Rename_Logic rename_logic (
        .clk(clk),
        .reset(reset),
        .valid(valid),
        .src_arch_reg1(src_arch_reg1),
        .src_arch_reg2(src_arch_reg2),
        .dest_arch_reg(dest_arch_reg),
        .src_phys_reg1(src_phys_reg1),
        .src_phys_reg2(src_phys_reg2),
        .dest_phys_reg(dest_phys_reg),
        .rename_valid(rename_valid)
    );
endmodule
