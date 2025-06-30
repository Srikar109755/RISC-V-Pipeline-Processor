`timescale 1ns / 1ps


module TB_Phase7();

    reg clk = 0;
    reg reset;
    reg ls_valid;
    reg is_store;
    reg [4:0] opcode;
    reg [31:0] base;
    reg [31:0] offset;
    reg [31:0] store_data;

    Top_Phase7 top7 (
        .clk(clk),
        .reset(reset),
        .ls_valid(ls_valid),
        .is_store(is_store),
        .opcode(opcode),
        .base(base),
        .offset(offset),
        .store_data(store_data)
    );

    always #5 clk = ~clk;

    initial begin
        $display("Running LSQ Test...");
        reset = 1; ls_valid = 0; is_store = 0;
        #10 reset = 0;

        // Store value 42 at address base=100, offset=4
        base = 100; offset = 4; store_data = 42;
        is_store = 1; ls_valid = 1; opcode = 5'b00001;
        #10 ls_valid = 0;

        // Load from same address
        #20 is_store = 0; ls_valid = 1;
        #10 ls_valid = 0;

        #50 $finish;
    end
endmodule
