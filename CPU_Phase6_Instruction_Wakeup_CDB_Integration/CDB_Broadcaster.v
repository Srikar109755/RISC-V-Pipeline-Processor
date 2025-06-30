`timescale 1ns / 1ps


module CDB_Broadcaster(
    input clk,
    input reset,
    
    input exec_done,
    input [5:0] exec_dest_prf,
    
    output reg cdb_valid,
    output reg [5:0] cdb_tag
    );
    
    always@(posedge clk or posedge reset) begin
        if (reset) begin
            cdb_valid <= 0;
            cdb_tag <= 0;
        end
        else begin
            cdb_valid <= exec_done;
            cdb_tag <= exec_dest_prf;
        end
    end
endmodule
