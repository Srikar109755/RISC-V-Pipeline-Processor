`timescale 1ns / 1ps


module Top_Phase5 #(
    parameter PC_WIDTH = 32,
    parameter IDX_WIDTH = 8,
    parameter BTB_DEPTH = 16,
    parameter BTB_IDX_WIDTH = 4
)(
    input clk, reset,

    // Fetch stage interaction
    input fetch_valid,
    input [PC_WIDTH-1:0] fetch_pc,
    output predicted_taken,
    output [PC_WIDTH-1:0] predicted_target,
    output btb_hit,

    // After branch resolves
    input actual_valid,
    input actual_taken,
    input [PC_WIDTH-1:0] actual_pc,
    input [PC_WIDTH-1:0] actual_target,

    // Flush control
    output flush,
    output [PC_WIDTH-1:0] recover_pc
);
    wire prediction;
    Branch_Predictor #(.ADDR_WIDTH(IDX_WIDTH)) bp (
        .clk(clk), .reset(reset),
        .predict_valid(fetch_valid),
        .pc_idx(fetch_pc[IDX_WIDTH+1:2]),                                   // index by PC bits
        .prediction(prediction),
        .update_valid(actual_valid),
        .update_idx(actual_pc[IDX_WIDTH+1:2]),
        .actual_taken(actual_taken)
    );


    wire btb_hit_w;
    wire [PC_WIDTH-1:0] btb_tgt;
    BTB #(.DEPTH(BTB_DEPTH), .PTR_WIDTH(BTB_IDX_WIDTH), .PC_WIDTH(PC_WIDTH)) btb (
        .clk(clk), .reset(reset),
        .lookup_valid(fetch_valid),
        .lookup_pc(fetch_pc),
        .hit(btb_hit_w),
        .target_pc(btb_tgt),
        .update_valid(actual_valid && actual_taken),
        .update_pc(actual_pc),
        .update_target(actual_target)
    );


    Speculation_Control #(.PC_WIDTH(PC_WIDTH)) sc (
        .clk(clk), .reset(reset),
        .predicted_taken(prediction),
        .actual_valid(actual_valid),
        .actual_taken(actual_taken),
        .actual_target(actual_target),
        .flush(flush),
        .recover_pc(recover_pc)
    );

    assign predicted_taken = prediction;
    assign predicted_target = btb_tgt;
    assign btb_hit = btb_hit_w;
endmodule
