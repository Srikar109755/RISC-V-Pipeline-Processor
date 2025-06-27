`timescale 1ns / 1ps


module Register_File( clk,
                      we,
                      rs1,
                      rs2,
                      rd,
                      rd1,
                      rd2,
                      wd
                    );
    input clk;
    input we;                                                               // WRITE ENABLE
    input [4:0] rs1;
    input [4:0] rs2;
    input [4:0] rd;
    input [31:0] wd;                                                        // WRITE DATA
    output [31:0] rd1;
    output [31:0] rd2;
    
    reg [31:0] regfile [0:31];
    
    
    // Read Ports
    assign rd1 = (rs1 == 0) ? 0 : regfile[rs1];
    assign rd2 = (rs2 == 0) ? 0 : regfile[rs2];
    
    
    // Write ports
    always@(posedge clk) begin
    
        if (rd !== 0 && we) begin
            regfile[rd] <= wd;
        end
    end
endmodule
