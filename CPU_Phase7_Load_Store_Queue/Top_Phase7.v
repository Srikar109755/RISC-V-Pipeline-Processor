`timescale 1ns / 1ps


module Top_Phase7(
    input clk,
    input reset,
    
    input ls_valid,
    input is_store,
    input [4:0] opcode,
    input [31:0] base,
    input [31:0] offset,
    input [31:0] store_data
    );
    
    wire [31:0] addr;
    wire [31:0] load_data;
    wire load_ready;
    
    
    // Calculating the address (Base Offset)
    Address_Calculator addr_calc (
        .base(base),
        .offset(offset),
        .effective_address(addr)
    );
    
    
    // Load Store Queue
    Load_Store_Queue lsq (
        .clk(clk),
        .reset(reset),
        .ls_valid(ls_valid),
        .is_store(is_store),
        .opcode(opcode),
        .addr(addr),
        .store_data(store_data),
        .load_ready(load_ready),
        .load_data(load_data),
        .memory_data_in(mem_out)
    );
    
    
    wire mem_read = (ls_valid && !is_store);
    wire mem_write = (ls_valid && is_store);
    wire [31:0] mem_out;
    
    
    // Memory Access
    Memory_Access_Controller mac (
        .clk(clk),
        .reset(reset),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(addr),
        .write_data(store_data),
        .read_data(mem_out)
    );
endmodule
