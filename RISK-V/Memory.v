`timescale 1ns / 1ps


module Memory( clk,
               mem_we,
               addr,
               wdata,
               rdata
    );
    
    input clk;
    input mem_we;
    input [31:0] addr;
    input [31:0] wdata;
    output [31:0] rdata;
    
    reg [31:0] mem [0:255];
    
    assign rdata = mem[addr[9:2]];
    
    always@(posedge clk) begin
    
        if (mem_we) begin
            mem[addr[9:2]] = wdata;
        end
    end
endmodule
