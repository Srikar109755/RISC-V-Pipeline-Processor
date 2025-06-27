`timescale 1ns / 1ps


module Branch_Predictor( clk,
                         reset,
                         predict_valid,
                         pc_idx,
                         prediction,
                         update_valid,
                         update_idx,
                         actual_taken
                        );
    parameter ADDR_WIDTH = 8, COUNTER_BITS = 2;                                     // bits for indexing predictor
    
    input clk;
    input reset;
    
    input predict_valid;
    input [ADDR_WIDTH-1:0] pc_idx;                                                  // branch PC index into predictor
    output reg prediction;                                                          // 0 = not-taken, 1 = taken

    
    input update_valid;
    input [ADDR_WIDTH-1 : 0] update_idx;
    input actual_taken;                                                             // actual outcome
    
    localparam COUNTER_MAX = (1 << COUNTER_BITS) - 1;
    reg [COUNTER_BITS-1 : 0] counters [(1 << ADDR_WIDTH)-1 : 0];
    
    integer i;
    
    always@(posedge clk or posedge reset) begin
        
        if (reset) begin
            for (i = 0; i < (1 << ADDR_WIDTH); i = i+1) begin
                counters[i] <= 2'b01;                                               // Initializing to weakly not-taken
            end
        end
        
        else begin
            if (predict_valid) begin
                prediction <= counters [pc_idx] [COUNTER_BITS-1];
            end
            
            if(update_valid) begin
                if (actual_taken) begin
                    if (counters [update_idx != COUNTER_MAX])
                        counters [update_idx] <= counters [update_idx] + 1;
                end
                else begin
                    if (counters[update_idx] != 0)
                        counters [update_idx] <= counters[update_idx] - 1;
                end
            end
        end
    end
endmodule
