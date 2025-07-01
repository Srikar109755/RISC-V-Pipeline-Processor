`timescale 1ns / 1ps


module Top_Phase8(
    input clk,
    input reset,
    
    input exception_occurred,
    input [3:0] exception_pc,
    
    input rob_commit_valid,
    input [3:0] rob_commit_arch
    );
    
    wire recover;
    wire [3:0] recover_ptr;
    wire  [31:0] trap_pc;
    wire retirement_enable;
    
    Exception_Handler handler (
        .clk(clk),
        .reset(reset),
        .exception_occurred(exception_occurred),
        .exception_pc(exception_pc),
        .recover(recover),
        .recover_rob_ptr(recover_ptr),
        .trap_pc(trap_pc)
    );
    
    
    Precise_Retirement_Logic precise (
        .clk(clk),
        .reset(reset),
        .rob_commit_valid(rob_commit_valid),
        .rob_commit_arch(rob_commit_arch),
        .exception_detected(exception_occurred),
        .retirement_enable(retirement_enable)
    );
    
    
    // Trap_Vector_Table is instantiated where decoding of cause is needed
endmodule
