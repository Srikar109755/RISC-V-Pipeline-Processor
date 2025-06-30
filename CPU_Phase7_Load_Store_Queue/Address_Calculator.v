`timescale 1ns / 1ps


module Address_Calculator(
    input [31:0] base,
    input [31:0] offset,
    input [31:0] effective_address
    );
    
    assign effective_address = base + offset;
endmodule
