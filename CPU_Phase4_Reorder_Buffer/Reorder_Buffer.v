`timescale 1ns / 1ps


module Reorder_Buffer( clk,
                       reset,
                       
                       alloc_valid,
                       alloc_dest_arch,
                       alloc_dest_phys,
                       alloc_accepted,
                       
                       cdb_valid,
                       cdb_tag,
                       cdb_result,
                       
                       commit_valid,
                       commit_dest_arch,
                       commit_dest_phys,
                       commit_value,
                       
                       free_phys_valid,
                       free_phys,
                       
                       recover,
                       recover_ptr
                    );
    input clk;
    input reset;
    
    input alloc_valid;
    input [4:0] alloc_dest_arch;
    input [5:0] alloc_dest_phys;
    output reg alloc_accepted;
    
    input cdb_valid;
    input [5:0] cdb_tag;
    input [31:0] cdb_result;
    
    output reg commit_valid;
    output reg [4:0] commit_dest_arch;
    output reg [5:0] commit_dest_phys;
    output reg [31:0] commit_value;
    
    output reg free_phys_valid;
    output reg [5:0] free_phys;
    
    parameter DEPTH = 4, PTR_WIDTH = 4;
    
    input recover;
    input [PTR_WIDTH-1 : 0] recover_ptr;
    
    reg valid [DEPTH-1 :0];
    reg ready [DEPTH-1 :0];
    reg [4:0] dest_arch [DEPTH-1 :0];
    reg [5:0] dest_phys [DEPTH-1 :0];
    reg [31:0] value [DEPTH-1 :0];
    
    reg [PTR_WIDTH-1 : 0] head;
    reg [PTR_WIDTH-1 : 0] tail;
    
    reg full;
    reg empty;
    
    integer i;
    
    always@(posedge clk or posedge reset) begin
        
        if (reset) begin
            head <= 0;
            tail <= 0;
            full <= 0;
            empty <= 1;
            
            alloc_accepted <= 0;
            commit_valid <= 0;
            free_phys_valid <= 0;
            
            for(i = 0; i < DEPTH; i = i+1) begin
                valid[i] <= 0;
                ready[i] <= 0;
            end
        end
        
        else begin
            alloc_accepted <= 0;
            free_phys_valid <= 0;
            
            if(recover) begin
                head <= recover_ptr;
                i = recover_ptr;
                
                while (i != tail) begin
                    valid[i] <= 0;
                    i = (i + 1) % DEPTH;
                end
                
                tail <= recover_ptr;
                full <= 0;
                empty <= 1;
            end
            
            else begin
                
                if (alloc_valid && !full) begin
                    valid[tail] <= 1;
                    ready[tail] <= 0;
                    dest_arch[tail] <= alloc_dest_arch;
                    dest_phys[tail] <= alloc_dest_phys;
                    
                    tail <= tail + 1;
                    empty <= 0;
                    alloc_accepted <= 1;
                    
                    if ((tail + 1) == head)
                        full <= 1; 
                end
                
                if(cdb_valid) begin
                    for (i = 0; i < DEPTH; i = i+1) begin
                        if (valid[i] && !ready[i] && cdb_tag == dest_phys[i]) begin
                            ready[i] <= 1;
                            value[i] <= cdb_result;
                        end
                    end
                end
                
                commit_valid <= 0;
                if (!empty && valid[head] && ready[head]) begin
                    commit_valid <= 1;
                    commit_dest_arch <= dest_arch[head];
                    commit_dest_phys <= dest_phys[head];
                    commit_value <= value[head];
                    
                    free_phys_valid <= 1;
                    free_phys <= dest_phys[head];
                    
                    if (head == tail)
                        empty <= 1;
                end
            end
        end
    end
endmodule 