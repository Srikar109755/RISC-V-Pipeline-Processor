`timescale 1ns / 1ps


module TB_Phase5;
    reg clk, reset;
    reg fetch_valid;
    reg [31:0] fetch_pc;
    wire predicted_taken;
    wire [31:0] predicted_target;
    wire btb_hit;

    reg actual_valid;
    reg actual_taken;
    reg [31:0] actual_pc;
    reg [31:0] actual_target;
    wire flush;
    wire [31:0] recover_pc;

    Top_Phase5 dut (
        .clk(clk), .reset(reset),
        .fetch_valid(fetch_valid),
        .fetch_pc(fetch_pc),
        .predicted_taken(predicted_taken),
        .predicted_target(predicted_target),
        .btb_hit(btb_hit),
        .actual_valid(actual_valid),
        .actual_taken(actual_taken),
        .actual_pc(actual_pc),
        .actual_target(actual_target),
        .flush(flush),
        .recover_pc(recover_pc)
    );

    always #5 clk = ~clk;
    
    initial begin

        clk = 0; reset = 1;
        fetch_valid = 0;
        actual_valid = 0;
        #20 reset = 0;

        // Test predictive pipeline
        fetch_valid = 1; fetch_pc = 32'h0000_0040;
        #10 actual_valid = 1; actual_pc = 32'h0000_0040; actual_taken = 1; actual_target = 32'h0000_0080;
        #10 actual_valid = 0;

        #20 fetch_valid = 1; fetch_pc = 32'h0000_0044;
        #10 actual_valid = 1; actual_pc = 32'h0000_0044; actual_taken = 0; actual_target = 0;
        #10 actual_valid = 0;

        // Misprediction
        #20 fetch_valid = 1; fetch_pc = 32'h0000_0048;
        // actual_wrong outcome
        #10 actual_valid = 1; actual_pc = 32'h0000_0048; actual_taken = 1; actual_target = 32'h0000_0050;
        #10 actual_valid = 0;

        #40 $finish;
    end
endmodule
