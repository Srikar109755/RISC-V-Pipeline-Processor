`timescale 1ns / 1ps


module Instruction_decode( instruction,
                           rs1,
                           rs2,
                           rd,
                           opcode,
                           funct3,
                           funct7,
                           imm
                        );
    input [31:0] instruction;
    output [4:0] rs1;                                           // Source register 1
    output [4:0] rs2;                                           // Source regsister 2
    output [4:0] rd;                                            // Destination register
    output [6:0] opcode;                                        // opcode
    output [2:0] funct3;
    output [6:0] funct7;
    output [31:0] imm;                                          // Immediate value
    
    
    assign opcode = instruction [6:0];
    assign rd     = instruction [11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];
    
    assign imm = {{20{instruction[31]}}, instruction[31:20]};   // sign-extended for I-type
endmodule
