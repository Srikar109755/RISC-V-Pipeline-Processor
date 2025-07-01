`timescale 1ns / 1ps

module TB_Phase8();
    reg clk = 0;
    reg reset;
    reg exception_occurred;
    reg [31:0] exception_pc;
    reg rob_commit_valid;
    reg [4:0] rob_commit_arch;

    Top_Phase8 uut (
        .clk(clk),
        .reset(reset),
        .exception_occurred(exception_occurred),
        .exception_pc(exception_pc),
        .rob_commit_valid(rob_commit_valid),
        .rob_commit_arch(rob_commit_arch)
    );

    always #5 clk = ~clk;

    initial begin
        $display("Starting Phase 8 Test...");
        reset = 1; exception_occurred = 0; exception_pc = 0; rob_commit_valid = 0; rob_commit_arch = 5'd0;
        #10 reset = 0;

        // Simulate a commit
        rob_commit_valid = 1;
        rob_commit_arch = 5'd5;
        #10 rob_commit_valid = 0;

        // Simulate exception
        exception_occurred = 1;
        exception_pc = 32'h000000A0;
        #10 exception_occurred = 0;

        #20 $finish;
    end
endmodule
