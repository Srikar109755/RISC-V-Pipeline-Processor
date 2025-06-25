`timescale 1ns / 1ps


module TB_Phase4;
    reg clk, reset;
    reg alloc_valid;
    reg [4:0] alloc_dest_arch;
    reg [5:0] alloc_dest_phys;
    wire alloc_done;
    reg cdb_valid;
    reg [5:0] cdb_tag;
    reg [31:0] cdb_value;
    reg branch_mispredict;
    reg [3:0] correct_ptr;
    wire [4:0] arch_wr_addr;
    wire [31:0] arch_wr_data;
    wire arch_wr_enable;


    Top_Phase4 dut (
        .clk(clk), .reset(reset),
        .alloc_valid(alloc_valid),
        .alloc_dest_arch(alloc_dest_arch),
        .alloc_dest_phys(alloc_dest_phys),
        .cdb_valid(cdb_valid),
        .cdb_tag(cdb_tag),
        .cdb_value(cdb_value),
        .branch_mispredict(branch_mispredict),
        .correct_head_ptr(correct_ptr),
        .arch_wr_addr(arch_wr_addr),
        .arch_wr_data(arch_wr_data),
        .arch_wr_enable(arch_wr_enable)
    );


    always #5 clk = ~clk;
    
    initial begin
        clk = 0; reset = 1;
        alloc_valid = 0; cdb_valid = 0; branch_mispredict = 0;
        #20 reset = 0;

        // Allocating 3 instructions
        #10 alloc_valid = 1; alloc_dest_arch = 5'd1; alloc_dest_phys = 6'd10;
        #10 alloc_valid = 0;
        #10 alloc_valid = 1; alloc_dest_arch = 5'd2; alloc_dest_phys = 6'd11;
        #10 alloc_valid = 0;
        #10 alloc_valid = 1; alloc_dest_arch = 5'd3; alloc_dest_phys = 6'd12;
        #10 alloc_valid = 0;


        // Send completion for entry 0 (tag=10)
        #20 cdb_valid = 1; cdb_tag = 6'd10; cdb_value = 123;
        #10 cdb_valid = 0;
        
        // Expect commit of first entry
        #20 cdb_valid = 1; cdb_tag = 6'd11; cdb_value = 456;
        #10 cdb_valid = 0;
        
        // Allocating 4th instruction
        #10 alloc_valid = 1; alloc_dest_arch = 5'd4; alloc_dest_phys = 6'd13;
        #10 alloc_valid = 0;
        
        // Misprediction
        #20 branch_mispredict = 1; correct_ptr = 4'd1;
        #10 branch_mispredict = 0;

        // Completion for entry tag=12
        #20 cdb_valid = 1; cdb_tag = 6'd12; cdb_value = 789;
        #10 cdb_valid = 0;

        #100 $finish;
    end
endmodule
