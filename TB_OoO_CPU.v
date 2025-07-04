`timescale 1ns / 1ps

module TB_OoO_CPU;

    // Clock and Reset Signals
    reg clk;
    reg reset;

    // Instantiating the Top_OoO_CPU
    Top_OoO_CPU dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock Generation
    always begin
        #5 clk = ~clk; // 10ns period, 100 MHz clock
    end

    // Test Sequence
    initial begin
        // Initialize Signals
        clk = 0;
        reset = 1;

        // Apply Reset
        #10;
        reset = 0;

        // Wait for a few cycles to allow the CPU to fetch and execute
        #100; // Run for 100ns

        // Check some internal signals (for debugging)
        $display("------------------------------------");
        $display("Simulation End");
        $display("Final PC: %h", dut.if_pc);
        $display("Instruction Fetched: %h", dut.if_instruction);
        $display("Decoded RD (Arch): %d", dut.id_rd_addr);
        $display("Decoded RS1 (Arch): %d", dut.id_rs1_addr);
        $display("Decoded RS2 (Arch): %d", dut.id_rs2_addr);
        $display("Decoded Imm: %h", dut.id_imm);
        $display("Allocated Physical Reg (Dest): %d", dut.rn_dest_phys_reg);
        $display("RS Issue Opcode: %b", dut.rs_issue_opcode);
        $display("RS Issue Dest PRF: %d", dut.rs_issue_dest_prf);
        $display("ALU Result: %h", dut.alu_result);
        $display("PRF Write Data: %h", dut.prf_write_data);
        $display("PRF Write Phys Reg: %d", dut.prf_write_phys_reg);
        $display("Architectural RF Write Enable: %b", dut.rf_write_enable);
        $display("Architectural RF Write Addr: %d", dut.rf_write_addr);
        $display("Architectural RF Write Data: %h", dut.rf_write_data);
        $display("CDB Valid: %b, CDB Tag: %d", dut.cdb_valid_to_rs, dut.cdb_tag_to_rs[5:0]);

        // Accessing individual registers from the flattened debug output
        $display("Architectural Register x1 (from debug): %h", dut.rf_debug_regfile_data[1*32 +: 32]);
        $display("Architectural Register x2 (from debug): %h", dut.rf_debug_regfile_data[2*32 +: 32]);
        $display("Architectural Register x3 (from debug): %h", dut.rf_debug_regfile_data[3*32 +: 32]);
        $display("------------------------------------");


        $finish; // End simulation
    end

    // Monitor key signals
    initial begin
        $monitor("Time: %0t | PC: %h, Instr: %h | Renamed Dest PRF: %d | Exec Result: %h | CDB Valid/Tag: %b/%d | Commit Addr/Data: %d/%h | Arch_x1: %h",
                 $time,
                 dut.if_pc,
                 dut.if_instruction,
                 dut.rn_dest_phys_reg,
                 dut.alu_result,
                 dut.cdb_valid_to_rs,
                 dut.cdb_tag_to_rs[5:0], // Monitoring the 6-bit tag
                 dut.rf_write_addr,
                 dut.rf_write_data,
                 dut.rf_debug_regfile_data[1*32 +: 32] // Monitor x1
                );
    end

endmodule
