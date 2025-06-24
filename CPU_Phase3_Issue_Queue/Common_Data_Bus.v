`timescale 1ns / 1ps


module Common_Data_Bus( clk,
                        reset,
                        broadcast_valid,
                        broadcast_tag,
                        cdb_valid,
                        cdb_tag
    );
    input clk;
    input reset;
    input broadcast_valid;
    input [5:0] broadcast_tag;
    
    output reg cdb_valid;
    output reg [31:0] cdb_tag;
    
    always@(posedge clk or posedge reset) begin
        
        if (reset) begin
            cdb_valid <= 0;
            cdb_tag <= 0;
        end
        
        else begin
            cdb_valid <= broadcast_valid;
            cdb_tag <= broadcast_tag;
        end
    end
endmodule
