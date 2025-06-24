`timescale 1ns / 1ps


module Reservation_Stations( clk,
                             reset,
                             
                             insert_valid,
                             opcode,
                             src1_prf,
                             src1_ready,
                             src2_prf,
                             src2_ready,
                             dest_prf,
                             
                             cdb_valid,
                             cdb_tag,
                             
                             issue_valid,
                             issue_opcode,
                             issue_src1_prf,
                             issue_src2_prf,
                             issue_dest_prf
                            );
    input clk;
    input reset;
    
    // Insert new instructions in RS
    input insert_valid;
    input [4:0] opcode;
    input [5:0] src1_prf;
    input src1_ready;
    input [5:0] src2_prf;
    input src2_ready;
    input [5:0] dest_prf;
    
    // CDB calls
    input cdb_valid;
    input [5:0] cdb_tag;
    
    // Issue Interface
    output reg issue_valid;
    output reg [4:0] issue_opcode;
    output reg [5:0] issue_src1_prf;
    output reg [5:0] issue_src2_prf;
    output reg [5:0] issue_dest_prf;
    
    parameter RS_SIZE = 8;
    
    reg valid [0:RS_SIZE-1];
    reg [4:0] op [0:RS_SIZE-1];
    reg [5:0] src1 [0:RS_SIZE-1];
    reg src1_rdy [0:RS_SIZE-1];
    reg [5:0] src2 [0:RS_SIZE-1];
    reg src2_rdy [0:RS_SIZE-1];
    reg [5:0] dest [0:RS_SIZE-1];
    
    integer i;
    reg inserted;
    reg cleared;
    
    always@(posedge clk or posedge reset) begin
        
        if (reset) begin
            for(i = 0; i < RS_SIZE; i = i+1) begin
                valid[i] <= 0;
            end
        end
        
        else if (insert_valid) begin
            inserted = 0;
            for(i = 0; i< RS_SIZE; i = i+1) begin
                if(!valid[i] && !inserted) begin
                    valid[i] <= 1;
                    op[i] <= opcode;
                    src1[i] <= src1_prf;
                    src1_rdy[i] <= src1_ready;
                    src2[i] <= src2_prf;
                    src2_rdy[i] <= src2_ready;
                    dest[i] <= dest_prf;
                    inserted = 1;                                             // Inserting only in one free slot
                end
            end
        end
    end
    
    
    // CDB
    always@(posedge clk) begin
        if (cdb_valid) begin
            for(i = 0; i < RS_SIZE; i = i+1) begin
                if (!src1_rdy[i] && src1[i] == cdb_tag)
                    src1_rdy[i] <= 1;
                if (!src2_rdy[i] && src2[i] == cdb_tag)
                    src2_rdy[i] <= 1;
            end
        end
    end
    
    
    // ISSUE LOGIC
    always@(*) begin
        issue_valid = 0;
        issue_opcode = 0;
        issue_src1_prf = 0;
        issue_src2_prf = 0;
        issue_dest_prf = 0;

        for (i = 0; i < RS_SIZE; i = i + 1) begin
            if (valid[i] && src1_rdy[i] && src2_rdy[i]) begin
                issue_valid = 1;
                issue_opcode = op[i];
                issue_src1_prf = src1[i];
                issue_src2_prf = src2[i];
                issue_dest_prf = dest[i];
            end
        end
    end
    
    
    // Clearing issued entry
    always@(posedge clk) begin
        if  (issue_valid) begin
            cleared = 0;
            for (i = 0; i < RS_SIZE; i = i+1) begin
                if (valid[i] && src1_rdy[i] && src2_rdy[i] && !cleared) begin
                    valid[i] <= 0;
                    cleared = 1;
                end
            end
        end
    end
endmodule
