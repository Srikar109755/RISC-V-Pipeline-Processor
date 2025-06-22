`timescale 1ns / 1ps


module Testbench;
    reg clk;
    reg reset;
    
    Top dut( .clk(clk),
             .reset(reset)
           );
           
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        $display("...Starting Simulation...");
        reset = 1;
        #10 reset = 0;
        #200 $finish;
    end
endmodule
