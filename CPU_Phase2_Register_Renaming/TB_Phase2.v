`timescale 1ns / 1ps    


module TB_Phase2();
    reg clk;
    reg reset;
    reg valid;
    reg [4:0] src_arch_reg1;
    reg [4:0] src_arch_reg2;
    reg [4:0] dest_arch_reg;
    
    
    Top_Phase2 dut (
        .clk(clk),
        .reset(reset),
        .valid(valid),
        .src_arch_reg1(src_arch_reg1),
        .src_arch_reg2(src_arch_reg2),
        .dest_arch_reg(dest_arch_reg)
    );
    
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        reset = 1;
        valid = 0;
        #10 reset = 0;
        
        // First instruction: ADDI x5, x0, 5
        #10 valid = 1;
            src_arch_reg1 = 5'd0;
            src_arch_reg2 = 5'd0;
            dest_arch_reg = 5'd5;
            
        #10 valid = 0;
        
        // Second instruction: ADDI x5, x5, 10
        #20 valid = 1;
            src_arch_reg1 = 5'd5;
            src_arch_reg2 = 5'd0;
            dest_arch_reg = 5'd5;

        #10 valid = 0;

        // Third instruction: ADD x6, x5, x1
        #20 valid = 1;
            src_arch_reg1 = 5'd5;
            src_arch_reg2 = 5'd1;
            dest_arch_reg = 5'd6;

        #10 valid = 0;
        
        #50 $finish;
    end
    
endmodule
