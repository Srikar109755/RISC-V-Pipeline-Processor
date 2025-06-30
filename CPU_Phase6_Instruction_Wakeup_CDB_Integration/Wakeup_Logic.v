`timescale 1ns / 1ps


module Wakeup_Logic(
    input clk,
    input reset,
    
    input cdb_valid,
    input [5:0] cdb_tag,
    
    input [5:0] rs_src1_prf,
    input [5:0] rs_src2_prf,
    input rs_src1_ready,
    input rs_src2_ready,
    
    output reg src1_ready_out,
    output reg src2_ready_out
    );
    
    always@(posedge clk or posedge reset) begin
        
        if (reset) begin
            src1_ready_out <= 0;
            src2_ready_out <= 0;
        end
        else begin
            if (!rs_src1_ready && rs_src1_prf == cdb_tag)
                src1_ready_out <= 1;
                
            if (!rs_src2_ready && rs_src2_prf == cdb_tag)
                src2_ready_out <= 1;
        end
    end
endmodule
