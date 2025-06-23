`timescale 1ns / 1ps


module Execution_Unit_ALU( op1,
                           op2,
                           opcode,
                           funct3,
                           funct7,
                           result
                         );
    input [31:0] op1;
    input [31:0] op2;
    input [6:0] opcode;
    input [2:0] funct3;
    input [6:0] funct7;
    output reg [31:0] result;
    
    always@(*) begin
        case(opcode)
            
            // I-Type instructions | opcode 0010011
            7'b0010011: begin 
                case (funct3)
                    3'b000: result = op1 + op2;                                                     // ADDI - 	Add Immediate
                    3'b010: result = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0;                 // SLTI - Set Less Than Immediate (signed)
                    3'b011: result = (op1 < op2) ? 32'b1 : 32'b0;                                   // SLTIU - 	Set Less Than Immediate Unsigned
                    3'b100: result = op1 ^ op2;                                                     // XORI - 
                    3'b110: result = op1 | op2;                                                     // ORI
                    3'b111: result = op1 & op2;                                                     // ANDI
                    3'b001: result = op1 << op2[4:0];                                               // SLLI (shift left logical immediate)
                    3'b101: begin
                                if (funct7 == 7'b0000000)
                                    result = op1 >> op2[4:0];                                       // SRLI (logical shift right)
                                else if (funct7 == 7'b0100000)
                                    result = $signed(op1) >>> op2[4:0];                             // SRAI (arithmetic shift right)
                                else
                                    result = 32'b0;                                                 // invalid shift funct7
                            end
                    default: result = 32'b0;                                                        // unknown funct3
                endcase
            end
            
            
            // R-Type instructions | 0110011
            7'b0110011 : begin
                case ({funct7, funct3})
                    10'b0000000000: result = op1 + op2;                                             // ADD
                    10'b0100000000: result = op1 - op2;                                             // SUB
                    10'b0000000111: result = op1 & op2;                                             // AND
                    10'b0000000110: result = op1 | op2;                                             // OR
                    10'b0000000100: result = op1 ^ op2;                                             // XOR
                    10'b0000000001: result = op1 << op2[4:0];                                       // SLL - Shift Left Logical
                    10'b0000000101: result = op1 >> op2[4:0];                                       // SRL - Shift Right Logical
                    10'b0100000101: result = $signed(op1) >>> op2[4:0];                             // SRA - Shift Right Arithmetic
                    10'b0000000010: result = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0;         // SLT - Set Less Than (signed)
                    10'b0000000011: result = (op1 < op2) ? 32'b1 : 32'b0;                           // SLTU - Set Less Than Unsigned
                    default: result = 32'b0;                                                        // unknown funct combination
                endcase
            end
            
            default : result = 32'b0;
            
        endcase
    end     
endmodule
