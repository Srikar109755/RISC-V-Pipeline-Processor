`timescale 1ns / 1ps


module Recovery_Logic( clk,
                       reset,
                       branch_mispredict,
                       valid_head_ptr,
                       correct_ptr,
                       
                       recover,
                       recover_ptr
                    );
                    
    parameter PTR_WIDTH = 4;
    input clk;
    input reset;
    input branch_mispredict;
    input [PTR_WIDTH-1 : 0] valid_head_ptr;
    input [PTR_WIDTH-1 : 0] correct_ptr;
    
    output reg recover;
    output reg [PTR_WIDTH-1 : 0] recover_ptr;
    
    always@(posedge clk or posedge reset) begin
        
        if (reset) begin
            recover <= 0;
        end
        
        else if (branch_mispredict) begin 
            recover_ptr <= correct_ptr;
            recover <= 1;
        end
        
        else begin
            recover <= 1;
        end
    end
endmodule
