`timescale 1ns / 1ps


module Top_Phase1( clk,
            reset
    );
    input clk;
    input reset;
    
    wire [31:0] instruction;
    wire [31:0] pc;
    wire [6:0] opcode;
    wire [6:0] funct7;
    wire [2:0] funct3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [31:0] rd1, rd2, imm, alu_result;
    
    
    // Instruction Fetech
    Instruction_Fetch IF( .clk(clk),
                       .reset(reset),
                       .instruction(instruction),
                       .pc(pc)
                        );
                        
                        
    // Instruction Decode
    Instruction_decode ID( .instruction(instruction),
                        .rs1(rs1),
                        .rs2(rs2),
                        .rd(rd),
                        .opcode(opcode),
                        .funct3(funct3),
                        .funct7(funct7),
                        .imm(imm)
                        );
                        

    // Register File
    Register_File RF( .clk(clk),
                   .we(1'b1),                                           // always Write eenable is 1 for simple pipeline
                   .rs1(rs1),
                   .rs2(rs2),
                   .rd(rd),
                   .rd1(rd1),
                   .rd2(rd2),
                   .wd(alu_result)
                    );


    // AlU Execution Unit
    Execution_Unit_ALU ALU( .op1(rd1),
                        .op2((opcode == 7'b0010011) ? imm : rd2),       // Select immediate for ADDI
                        .opcode(opcode),
                        .funct3(funct3),
                        .funct7(funct7),
                        .result(alu_result)
                         );
                         
endmodule
