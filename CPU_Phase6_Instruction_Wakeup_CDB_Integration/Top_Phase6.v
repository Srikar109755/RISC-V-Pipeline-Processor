`timescale 1ns / 1ps


module Top_Phase6(
    input clk,
    input reset,
    
    input exec_done,
    input [5:0] exec_dest_prf,
    
    input [4:0] opcode,
    input [5:0] src1_prf,
    input [5:0] src2_prf,
    input src1_ready,
    input src2_ready,
    input [5:0] dest_prf,
    
    output issue_valid
    );
    
    wire cdb_valid;
    wire [5:0] cdb_tag;
    
    wire [4:0] issue_opcode;
    wire [5:0] issue_src1_prf;
    wire [5:0] issue_src2_prf;
    wire [5:0] issue_dest_prf;
    
    
    // CDB Broadcaster
    CDB_Broadcaster cdb (
        .clk(clk),
        .reset(reset),
        .exec_done(exec_done),
        .exec_dest_prf(exec_dest_prf),
        .cdb_valid(cdb_valid),
        .cdb_tag(cdb_tag)
    );
    
    
    // Issue Controller
    Issue_Controller issue_ctrl (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .src1_prf(src1_prf),
        .src1_ready(src1_ready),
        .src2_prf(src2_prf),
        .src2_ready(src2_ready),
        .dest_prf(dest_prf),
        .cdb_valid(cdb_valid),
        .cdb_tag(cdb_tag),
        .issue_valid(issue_valid),
        .issue_opcode(issue_opcode),
        .issue_src1_prf(issue_src1_prf),
        .issue_src2_prf(issue_src2_prf),
        .issue_dest_prf(issue_dest_prf)
    );

endmodule
