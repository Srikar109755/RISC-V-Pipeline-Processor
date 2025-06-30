`timescale 1ns / 1ps


module Load_Store_Queue #(
    parameter DEPTH = 8,                                // Memory Depth
    parameter PTR_WIDTH = 3                             // Counter Width (Head Tail)
    )(
        input clk,
        input reset,
        
        input ls_valid,
        input is_store,
        input [4:0] opcode,
        input [31:0] addr,
        input [31:0] store_data,
        
        output reg load_ready,
        output reg [31:0] load_data,
        
        input [31:0] memory_data_in
    );
    
    reg valid [0:DEPTH-1];
    reg store [0:DEPTH-1];
    reg [4:0] op [0:DEPTH-1];
    reg [31:0] addr_q [0:DEPTH-1];
    reg [31:0] data_q [0:DEPTH-1];
    
    reg [PTR_WIDTH-1 : 0] head, tail;
    
    integer i;
    
    always@(posedge clk or posedge reset) begin
        
        if (reset) begin
            head <= 0;
            tail <= 0;
            load_ready <= 0;
            load_data <= 0;
            
            for (i = 0; i < DEPTH; i = i + 1)
                valid[i] <= 0;
        end
        else begin
            load_ready <= 0;
            
            // Load Store into the memory
            if (ls_valid) begin
                valid[tail] <= 1;
                store[tail] <= is_store;
                op[tail] <= opcode;
                addr_q[tail] <= addr;
                data_q[tail] <= store_data;
                tail <= (tail + 1) % DEPTH;
            end
            
            
            // Handling Load (Read from memory)
            if (valid[head] && !store[head]) begin
                load_ready <= 1;
                load_data <= memory_data_in;
                valid[head] <= 0;
                head <= (head + 1) % DEPTH;
            end
            
            // Handling Store (Write memory)
            if (valid[head] && store[head]) begin
                valid[head] <= 0;
                head <= (head + 1) % DEPTH;
            end
        end
    end
endmodule
