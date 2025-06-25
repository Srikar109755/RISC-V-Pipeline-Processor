`timescale 1ns / 1ps


module Top_Phase4(
    input clk, reset,
    
    // Insert interface
    input alloc_valid,
    input [4:0] alloc_dest_arch,
    input [5:0] alloc_dest_phys,


    // CDB from execution
    input cdb_valid,
    input [5:0] cdb_tag,
    input [31:0] cdb_value,


    // Branch mispredict recovery trigger
    input branch_mispredict,
    input [3:0] correct_head_ptr,


    // Architectural register file write interface
    output [4:0] arch_wr_addr,
    output [31:0] arch_wr_data,
    output arch_wr_enable
);
    wire alloc_done;
    wire commit_valid;
    wire [4:0] commit_dest_arch;
    wire [5:0] commit_dest_phys;
    wire [31:0] commit_value;
    wire free_phys_valid;
    wire [5:0] free_phys;
    wire recover;
    wire [3:0] recover_ptr;


    Reorder_Buffer rob (
        .clk(clk),
        .reset(reset),
        .alloc_valid(alloc_valid),
        .alloc_dest_arch(alloc_dest_arch),
        .alloc_dest_phys(alloc_dest_phys),
        .alloc_accepted(alloc_done),
        .cdb_valid(cdb_valid),
        .cdb_tag(cdb_tag),
        .cdb_result(cdb_value),
        .commit_valid(commit_valid),
        .commit_dest_arch(commit_dest_arch),
        .commit_dest_phys(commit_dest_phys),
        .commit_value(commit_value),
        .free_phys_valid(free_phys_valid),
        .free_phys(free_phys),
        .recover(recover),
        .recover_ptr(recover_ptr)
    );


    Commit_Unit cu (
        .clk(clk), .reset(reset),
        .commit_valid(commit_valid),
        .commit_dest_arch(commit_dest_arch),
        .commit_value(commit_value),
        .arch_wr_addr(arch_wr_addr),
        .arch_wr_data(arch_wr_data),
        .arch_wr_enable(arch_wr_enable)
    );


    Recovery_Logic rec (
        .clk(clk), .reset(reset),
        .branch_mispredict(branch_mispredict),
        .valid_head_ptr(commit_valid ? commit_dest_arch[3:0] : 0),
        .correct_ptr(correct_head_ptr),
        .recover(recover),
        .recover_ptr(recover_ptr)
    );
endmodule
