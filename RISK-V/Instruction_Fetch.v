`timescale 1ns / 1ps


module Instruction_Fetch( clk,
                          reset,
                          instruction,
                          pc
                        );
    input clk;
    input reset;
    output [31:0] instruction;
    output [31:0] pc;
    
    reg [31:0] instruction;
    reg [31:0] pc;
    
    reg [31:0] instr_mem [0:255];
    
    initial begin
        $readmemh("program.hex",instr_mem);                             // Loading instructions from the file   
    end
    
    always@(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
            instruction <= 0;
        end
        else begin
            instruction <= instr_mem[pc[9:2]];                          // word aligned
            pc <= pc +4;                                                // Incrementing by 4 because 32/8 = 4 bytes it is a byte address
        end
    end
    
endmodule
