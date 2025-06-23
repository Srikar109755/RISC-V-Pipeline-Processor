`timescale 1ns / 1ps


module Physical_Register_File( clk,
                               reset,
                               write_enable,
                               write_phys_reg,
                               write_data,
                               read_phys_reg1,
                               read_phys_reg2,
                               read_data1,
                               read_data2
    );
    input clk;
    input reset;
    
    // Write Interface
    input write_enable;
    input [5:0] write_phys_reg;
    input [31:0] write_data;
    
    // Read Interface
    input [5:0] read_phys_reg1;
    input [5:0] read_phys_reg2;
    output reg [31:0] read_data1;
    output reg [31:0] read_data2;
    
    reg [31:0] phys_regs [0:63];
    
    integer i;
    
    always@(posedge clk or negedge reset) begin
        
        if (reset) begin
            for(i = 0; i <= 63; i = i+1) begin
                phys_regs[i] <= 0;
            end
        end
        else if(write_enable) begin
            phys_regs[write_phys_reg] <= write_data;
        end
    end
    
    always@(*) begin
        read_data1 <= phys_regs[read_phys_reg1];
        read_data2 <= phys_regs[read_phys_reg2];
    end
    
endmodule
