`timescale 1ns / 1ps


module Issue_Controller(
    input clk,
    input reset,
    
    input [4:0] opcode,
    input [5:0] src1_prf,
    input src1_ready,
    input [5:0] src2_prf,
    input src2_ready,
    input [5:0] dest_prf,
    
    input cdb_valid,
    input [5:0] cdb_tag,
    
    output reg issue_valid,
    output reg [4:0] issue_opcode,
    output reg [5:0] issue_src1_prf,
    output reg [5:0] issue_src2_prf,
    output reg [5:0] issue_dest_prf
    );
    
    wire src1_ready_out;
    wire src2_ready_out;
    
    
    // Wake up Logic
    Wakeup_Logic wakeup (
        .clk(clk),
        .reset(reset),
        .cdb_valid(cdb_valid),
        .cdb_tag(cdb_tag),
        .rs_src1_prf(src1_prf),
        .rs_src2_prf(src2_prf),
        .rs_src1_ready(src1_ready),
        .rs_src2_ready(src2_ready),
        .src1_ready_out(src1_ready_out),
        .src2_ready_out(src2_ready_out)
    );
    
    
    always@(*) begin
        if (src1_ready_out && src2_ready_out) begin
            issue_valid <= 1;
            issue_opcode <= opcode;
            issue_src1_prf <= src1_prf;
            issue_src2_prf <= src2_prf;
            issue_dest_prf <= dest_prf;
        end
        else begin
            issue_valid <= 0;
            issue_opcode <= 0;
            issue_src1_prf <= 0;
            issue_src2_prf <= 0;
            issue_dest_prf <= 0;
        end
    end
endmodule
