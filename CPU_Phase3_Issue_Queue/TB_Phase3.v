`timescale 1ns / 1ps


module TB_Phase3();
    reg clk;
    reg reset;

    // Interface signals
    reg insert_valid;
    reg [4:0] opcode;
    reg [5:0] src1_prf;
    reg [5:0] src2_prf;
    reg src1_ready;
    reg src2_ready;
    reg [5:0] dest_prf;


    // Dummy physical register file read data
    wire [31:0] src1_data;
    wire [31:0] src2_data;


    Top_Phase3 dut (
        .clk(clk),
        .reset(reset),
        .insert_valid(insert_valid),
        .opcode(opcode),
        .src1_prf(src1_prf),
        .src1_ready(src1_ready),
        .src2_prf(src2_prf),
        .src2_ready(src2_ready),
        .dest_prf(dest_prf),
        .src1_data(src1_data),
        .src2_data(src2_data)
    );

    // Create dummy data for physical register file reads
    assign src1_data = 32'd10;
    assign src2_data = 32'd20;

    // Clock Generation
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        insert_valid = 0;
        #20 reset = 0;

        // Insert Instruction 1: ADD src1=10, src2=20
        #10;
        insert_valid = 1;
        opcode = 5'b00001;     // ADD
        src1_prf = 6'd1;
        src2_prf = 6'd2;
        src1_ready = 1;
        src2_ready = 1;
        dest_prf = 6'd10;

        #10;
        insert_valid = 0;

        // Insert Instruction 2: MUL src1=10, src2=20
        #20;
        insert_valid = 1;
        opcode = 5'b00011;     // MUL
        src1_prf = 6'd3;
        src2_prf = 6'd4;
        src1_ready = 1;
        src2_ready = 1;
        dest_prf = 6'd11;

        #10 insert_valid = 0;

        // Insert Instruction 3 with dependencies (not ready initially)
        #20;
        insert_valid = 1;
        opcode = 5'b00010;     // SUB
        src1_prf = 6'd10;      // waiting for previous ADD result
        src2_prf = 6'd20;
        src1_ready = 0;
        src2_ready = 1;
        dest_prf = 6'd12;

        #10 insert_valid = 0;

        #100;
        $display("Simulation finished");
        $finish;
    end
endmodule
