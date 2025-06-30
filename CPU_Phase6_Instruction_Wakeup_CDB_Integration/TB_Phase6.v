`timescale 1ns / 1ps


module TB_Phase6;

    reg clk, reset;
    reg exec_done;
    reg [5:0] exec_dest_prf;

    reg [4:0] opcode;
    reg [5:0] src1_prf, src2_prf, dest_prf;
    reg src1_ready, src2_ready;

    wire issue_valid;

    Top_Phase6 uut (
        .clk(clk),
        .reset(reset),
        .exec_done(exec_done),
        .exec_dest_prf(exec_dest_prf),
        .opcode(opcode),
        .src1_prf(src1_prf),
        .src2_prf(src2_prf),
        .src1_ready(src1_ready),
        .src2_ready(src2_ready),
        .dest_prf(dest_prf),
        .issue_valid(issue_valid)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        exec_done = 0;
        exec_dest_prf = 0;

        opcode = 5'b00001;
        src1_prf = 6'd10;
        src2_prf = 6'd20;
        dest_prf = 6'd30;
        src1_ready = 0;
        src2_ready = 0;

        #10 reset = 0;

        // First, no operand is ready
        #10;

        // Broadcast that src1 is now ready via CDB
        exec_done = 1;
        exec_dest_prf = 6'd10;
        #10 exec_done = 0;

        // Broadcast that src2 is now ready
        exec_done = 1;
        exec_dest_prf = 6'd20;
        #10 exec_done = 0;

        // Issue should now be valid
        #20;

        $finish;
    end

endmodule
