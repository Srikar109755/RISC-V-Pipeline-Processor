`timescale 1ns / 1ps


module Trap_Vector_Table(
    input [3:0] cause,
    output reg [31:0] handler_address
    );
    
    always@(*) begin
        case(cause)
            4'b0000 : handler_address = 32'h00000080;                           // Instruction address misaligned
            4'b0001 : handler_address = 32'h00000084;                           // Illegal instruction
            4'b0010 : handler_address = 32'h00000088;                           // Breakpoint
            4'b0011 : handler_address = 32'h0000008C;                           // Load address misaligned
            default : handler_address = 32'h00000090;                           // Default trap
        endcase
    end
endmodule
