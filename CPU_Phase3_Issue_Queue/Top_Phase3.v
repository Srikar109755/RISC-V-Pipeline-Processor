`timescale 1ns / 1ps


module Top_Phase3( clk,
                   reset,
                   insert_valid,
                   opcode,
                   src1_prf,
                   src1_ready,
                   src2_prf,
                   src2_ready,
                   dest_prf,
                   src1_data,
                   src2_data
    );
    input clk;
    input reset;
    
    // Input Interface
    input insert_valid;
    input [4:0] opcode;
    input [5:0] src1_prf;
    input [5:0] src2_prf;
    input src1_ready;
    input src2_ready;
    input [5:0] dest_prf;
    
    // Physical register file inputs
    output [31:0] src1_data;
    output [31:0] src2_data;
    
    wire rs_issue_valid;
    wire [4:0] rs_opcode;
    wire [5:0] rs_src1_prf;
    wire [5:0] rs_src2_prf;
    wire [5:0] rs_dest_prf;
    
    wire alu_done;
    wire [31:0] alu_result;
    
    wire cdb_valid;
    wire [5:0] cdb_tag;
    
    
    // Reservation Station
    Reservation_Stations rs (
        .clk(clk),
        .reset(reset),
        .insert_valid(insert_valid),
        .opcode(opcode),
        .src1_prf(src1_prf),
        .src1_ready(src1_ready),
        .src2_prf(src2_prf),
        .src2_ready(src2_ready),
        .dest_prf(dest_prf),
        .cdb_valid(cdb_valid),
        .cdb_tag(cdb_tag),
        .issue_valid(rs_issue_valid),
        .issue_opcode(rs_opcode),
        .issue_src1_prf(rs_src1_prf),
        .issue_src2_prf(rs_src2_prf),
        .issue_dest_prf(rs_dest_prf)
    );
    
    
    // ALU
    ALU_Execution_Unit alu (
        .clk(clk),
        .reset(reset),
        .execute_valid(rs_issue_valid),
        .opcode(rs_opcode),
        .src1_data(src1_data),
        .src2_data(src2_data),
        .result(alu_result),
        .done(alu_done)
    );
    
    
    // CDB
    Common_Data_Bus cdb (
        .clk(clk),
        .reset(reset),
        .broadcast_valid(alu_done),
        .broadcast_tag(rs_dest_prf),
        .cdb_valid(cdb_valid),
        .cdb_tag(cdb_tag)
    );
endmodule
