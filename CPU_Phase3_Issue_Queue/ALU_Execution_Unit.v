`timescale 1ns / 1ps


module ALU_Execution_Unit( clk,
                           reset,
                           execute_valid,
                           opcode,
                           src1_data,
                           src2_data,
                           result,
                           done
                        );
    input clk;
    input reset;
    input execute_valid;
    input [4:0] opcode;
    input [31:0] src1_data;
    input [31:0] src2_data;
    output reg [31:0] result;
    output reg done;
    
    always@(posedge clk or posedge reset) begin
        
        if (reset) begin
            result <= 0;
            done <= 0;
        end
        
        else if (execute_valid) begin
            case(opcode)
                5'b00001 : result <= src1_data + src2_data;                     // ADD
                5'b00010 : result <= src1_data - src2_data;                     // SUB
                5'b00011 : result <= src1_data * src2_data;                     // MUL
                default : result <= 0;
            endcase
        end else begin
            done <= 0;
        end
    end
endmodule
