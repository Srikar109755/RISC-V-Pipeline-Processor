`timescale 1ns / 1ps

// Top-level CPU module integrates all the phases
module Top_OoO_CPU(
    input clk,
    input reset
);

    // Wires and Registers for Inter-Module Communications

    // Instruction Fetch Stage Signals
    wire [31:0] if_instruction;
    wire [31:0] if_pc;

    // Instruction Decode Stage Signals
    wire [4:0] id_rs1_addr;
    wire [4:0] id_rs2_addr;
    wire [4:0] id_rd_addr;
    wire [6:0] id_opcode_full; // Full 7-bit opcode
    wire [2:0] id_funct3;
    wire [6:0] id_funct7;
    wire [31:0] id_imm;

    // Register File Signals
    wire [31:0] rf_read_data1;
    wire [31:0] rf_read_data2;
    wire        rf_write_enable;
    wire [4:0]  rf_write_addr;
    wire [31:0] rf_write_data;
    wire [32*32-1:0] rf_debug_regfile_data; 

    // Rename Logic Signals
    wire [5:0] rn_src_phys_reg1;
    wire [5:0] rn_src_phys_reg2;
    wire [5:0] rn_dest_phys_reg;
    wire        rn_valid;

    // Physical Register File Signals
    wire [31:0] prf_read_data1;
    wire [31:0] prf_read_data2;
    wire        prf_write_enable;
    wire [5:0]  prf_write_phys_reg;
    wire [31:0] prf_write_data;

    // Free List Signals
    wire        fl_allocate_valid;
    wire [5:0]  fl_allocated_phys_reg;

    // Reservation Stations Signals
    wire        rs_issue_valid;
    wire [4:0]  rs_issue_opcode;     // This is a simple 5-bit opcode for ALU_Execution_Unit
    wire [5:0]  rs_issue_src1_prf;
    wire [5:0]  rs_issue_src2_prf;
    wire [5:0]  rs_issue_dest_prf;

    // Common Data Bus Signals
    wire        cdb_valid_from_brdcstr; // from CDB_Broadcaster
    wire [5:0]  cdb_tag_from_brdcstr;   // from CDB_Broadcaster (6-bit physical register tag)

    wire        cdb_valid_to_rs; // to RS, Issue Controller
    wire [31:0] cdb_tag_to_rs;   // to RS, Issue Controller (This is 32-bit, but should carry 6-bit tag)

    // ALU Execution Unit Signals
    wire [31:0] alu_result;
    wire        alu_done;

    // Memory Access Signals
    wire [31:0] mem_rdata;
    wire [31:0] mem_addr;
    wire        mem_we;

    // Load Store Queue Signals
    wire        lsq_load_ready;
    wire [31:0] lsq_load_data;

    // Branch Prediction Signals
    wire        bp_prediction;
    wire        btb_hit;
    wire [31:0] btb_target_pc;

    // Speculation Control Signals
    wire        spec_flush;
    wire [31:0] spec_recover_pc;

    // Exception Handler Signals
    wire        excp_recover;
    wire [3:0]  excp_recover_rob_ptr;
    wire [31:0] excp_trap_pc;

    // Precise Retirement Logic Signals
    wire        retire_enable;

    // Internal pipeline registers
    reg [31:0] pc_reg;
    reg [31:0] id_instruction_reg; // Instruction from IF to ID
    reg [4:0]  id_rd_addr_reg;     // Destination architectural register

    reg [4:0]  ren_opcode_reg;      // Opcode from rename to RS
    reg [5:0]  ren_src1_prf_reg;    // src1 physical reg from rename to RS
    reg [5:0]  ren_src2_prf_reg;    // src2 physical reg from rename to RS
    reg [5:0]  ren_dest_prf_reg;    // dest physical reg from rename to RS
    reg        ren_src1_ready_reg;  // src1 ready from PRF status 
    reg        ren_src2_ready_reg;  // src2 ready from PRF status
    reg        ren_valid_reg;       // valid signal from rename to RS

    reg [4:0]  issue_opcode_reg;    // opcode from RS issue to ALU
    reg [31:0] issue_src1_data_reg; // src1 data from PRF to ALU
    reg [31:0] issue_src2_data_reg; // src2 data from PRF to ALU
    reg [5:0]  issue_dest_prf_reg;  // dest physical reg from RS issue to ALU
    reg        issue_valid_reg;     // valid signal from RS issue to ALU

    reg [31:0] exec_result_reg;     // result from ALU to CDB Broadcaster
    reg [5:0]  exec_dest_prf_reg;   // dest physical reg from ALU to CDB Broadcaster
    reg        exec_done_reg;       // done signal from ALU to CDB Broadcaster


    // Instantiating Modules

    // Phase 1 Modules
    Instruction_Fetch IF_Unit (
        .clk(clk),
        .reset(reset), // Reset or pipeline flush
        .instruction(if_instruction),
        .pc(if_pc)
    );

    Instruction_decode ID_Unit (
        .instruction(id_instruction_reg), // Pipeline register for instruction
        .rs1(id_rs1_addr),
        .rs2(id_rs2_addr),
        .rd(id_rd_addr),
        .opcode(id_opcode_full),
        .funct3(id_funct3),
        .funct7(id_funct7),
        .imm(id_imm)
    );

    // Architectural Register File (Commit Stage)
    Register_File Arch_RF (
        .clk(clk),
        .we(rf_write_enable),
        .rs1(id_rs1_addr), // Used for reading in decode, but actual read is from PRF
        .rs2(id_rs2_addr), // Used for reading in decode, but actual read is from PRF
        .rd(rf_write_addr),
        .rd1(), // Not using for now
        .rd2(), // Not using for now
        .wd(rf_write_data),
        .debug_regfile_data(rf_debug_regfile_data) 
    );

    // Phase 2 Modules
    // Free_List and Rename_Map_Table are sub-modules of Rename_Logic
    Rename_Logic RN_Unit (
        .clk(clk),
        .reset(reset),
        .valid(if_pc > 0), // A simple valid signal for instruction coming into rename
        .src_arch_reg1(id_rs1_addr),
        .src_arch_reg2(id_rs2_addr),
        .dest_arch_reg(id_rd_addr),
        .src_phys_reg1(rn_src_phys_reg1),
        .src_phys_reg2(rn_src_phys_reg2),
        .dest_phys_reg(rn_dest_phys_reg),
        .rename_valid(rn_valid) // rename_valid from Free_List allocate_valid
    );

    Physical_Register_File PRF (
        .clk(clk),
        .reset(reset),
        .write_enable(prf_write_enable), // write enable from writeback
        .write_phys_reg(prf_write_phys_reg), // dest phys reg from writeback
        .write_data(prf_write_data),         // write data from writeback
        .read_phys_reg1(rs_issue_src1_prf),  // read for execution from RS
        .read_phys_reg2(rs_issue_src2_prf),  // read for execution from RS
        .read_data1(prf_read_data1),
        .read_data2(prf_read_data2)
    );

    // Phase 3 Modules
    // Using a simplified 5-bit opcode for ALU_Execution_Unit for ADD/SUB/MUL, etc.
    // Mapping full opcode to a simplified one for ALU.
    reg [4:0] alu_exec_opcode_simplified;             // Moved to reg as it's in an always block
    always @(*) begin
        case(id_opcode_full)
            7'b0010011: begin // I-Type (ADDI, SLTI, etc.)
                case (id_funct3)
                    3'b000: alu_exec_opcode_simplified = 5'b00001; // ADDI -> ADD
                    3'b010: alu_exec_opcode_simplified = 5'b00001; // SLTI -> ADD (Placeholder, needs proper SLT op)
                    // ... More I-type mappings if needed
                    default: alu_exec_opcode_simplified = 5'b00000; // Default/Invalid
                endcase
            end
            7'b0110011: begin // R-Type (ADD, SUB, etc.)
                case ({id_funct7, id_funct3})
                    10'b0000000000: alu_exec_opcode_simplified = 5'b00001; // ADD
                    10'b0100000000: alu_exec_opcode_simplified = 5'b00010; // SUB
                    // ... More R-type mappings if needed
                    default: alu_exec_opcode_simplified = 5'b00000;
                endcase
            end
            default: alu_exec_opcode_simplified = 5'b00000;
        endcase
        $display("Time: %0t | CPU: Decoded Opcode=%b, Funct3=%b, Funct7=%b -> ALU Opcode Simplified: %b",$time, id_opcode_full, id_funct3, id_funct7, alu_exec_opcode_simplified);
    end

    ALU_Execution_Unit ALU_Exec (
        .clk(clk),
        .reset(reset),
        .execute_valid(issue_valid_reg),
        .opcode(issue_opcode_reg), // Use issue_opcode_reg for consistency
        .src1_data(issue_src1_data_reg),
        .src2_data(issue_src2_data_reg),
        .result(alu_result),
        .done(alu_done)
    );

    Common_Data_Bus CDB_Bus (
        .clk(clk),
        .reset(reset),
        .broadcast_valid(cdb_valid_from_brdcstr),
        .broadcast_tag(cdb_tag_from_brdcstr), // 6-bit
        .cdb_valid(cdb_valid_to_rs),
        .cdb_tag(cdb_tag_to_rs) 
    );

    Reservation_Stations RS_Unit (
        .clk(clk),
        .reset(reset),
        .insert_valid(ren_valid_reg), // valid instruction from rename
        .opcode(ren_opcode_reg),      // opcode from rename
        .src1_prf(ren_src1_prf_reg),
        .src1_ready(ren_src1_ready_reg),
        .src2_prf(ren_src2_prf_reg),
        .src2_ready(ren_src2_ready_reg),
        .dest_prf(ren_dest_prf_reg),
        .cdb_valid(cdb_valid_to_rs),
        .cdb_tag(cdb_tag_to_rs[5:0]), // Use the 6-bit tag from the 32-bit CDB
        .issue_valid(rs_issue_valid),
        .issue_opcode(rs_issue_opcode),
        .issue_src1_prf(rs_issue_src1_prf),
        .issue_src2_prf(rs_issue_src2_prf),
        .issue_dest_prf(rs_issue_dest_prf)
    );

    // Phase 4 Modules
    Commit_Unit CU (
        .clk(clk),
        .reset(reset),
        .commit_valid(retire_enable), // From Precise Retirement Logic
        .commit_dest_arch(id_rd_addr_reg), // From ROB/Commit Stage
        .commit_value(exec_result_reg),     // From ROB/Commit Stage
        .arch_wr_addr(rf_write_addr),
        .arch_wr_data(rf_write_data),
        .arch_wr_enable(rf_write_enable)
    );

    // Recovery_Logic: Needs branch mispredict signal and correct PC from somewhere (e.g., branch unit)
    Recovery_Logic RL_Unit (
        .clk(clk),
        .reset(reset),
        .branch_mispredict(1'b0), // Dummy for now
        .valid_head_ptr(4'b0),     // Dummy
        .correct_ptr(4'b0),        // Dummy
        .recover(excp_recover),    // Connected to exception handler recover
        .recover_ptr(excp_recover_rob_ptr) // Connected to exception handler recover ROB ptr
    );

    // Phase 5 Modules
    BTB BTB_Unit (
        .clk(clk),
        .reset(reset),
        .lookup_valid(if_pc > 0), // If PC is valid, lookup BTB
        .lookup_pc(if_pc),
        .hit(btb_hit),
        .target_pc(btb_target_pc),
        .update_valid(1'b0), // Dummy for now
        .update_pc(32'b0),   // Dummy
        .update_target(32'b0) // Dummy
    );

    Branch_Predictor BP_Unit (
        .clk(clk),
        .reset(reset),
        .predict_valid(if_pc > 0), // If PC is valid, get prediction
        .pc_idx(if_pc[7:0]), // Using lower 8 bits of PC as index
        .prediction(bp_prediction),
        .update_valid(1'b0), // Dummy for now
        .update_idx(8'b0),   // Dummy
        .actual_taken(1'b0)  // Dummy
    );

    Speculation_Control SC_Unit (
        .clk(clk),
        .reset(reset),
        .predicted_taken(bp_prediction),
        .actual_valid(1'b0),  // Dummy
        .actual_taken(1'b0),  // Dummy
        .actual_target(32'b0),// Dummy
        .flush(spec_flush),
        .recover_pc(spec_recover_pc)
    );

    // Phase 6 Modules
    CDB_Broadcaster CDB_Brdc (
        .clk(clk),
        .reset(reset),
        .exec_done(exec_done_reg),
        .exec_dest_prf(exec_dest_prf_reg),
        .cdb_valid(cdb_valid_from_brdcstr),
        .cdb_tag(cdb_tag_from_brdcstr)
    );

    // Phase 7 Modules
    wire [31:0] calculated_mem_addr;
    Address_Calculator Addr_Calc (
        .base(prf_read_data1),   // Base address from PRF
        .offset(id_imm),         // Immediate offset from instruction
        .effective_address(calculated_mem_addr) // Output of address calculation
    );

    Load_Store_Queue #(
        .DEPTH(8),
        .PTR_WIDTH(3)
    ) LSQ_Unit (
        .clk(clk),
        .reset(reset),
        .ls_valid(1'b0), // Dummy 
        .is_store(1'b0), // Dummy
        .opcode(5'b0),   // Dummy
        .addr(32'b0),    // Dummy
        .store_data(32'b0), // Dummy
        .load_ready(lsq_load_ready),
        .load_data(lsq_load_data),
        .memory_data_in(mem_rdata)
    );

    // Main Data Memory
    Memory_Access_Controller Data_Mem (
        .clk(clk),
        .reset(reset),
        .mem_write(mem_we),
        .mem_read(~mem_we && lsq_load_ready), // Read when not writing and LSQ has a load ready
        .address(mem_addr),
        .write_data(lsq_load_data), // Actual data to write from pipeline
        .read_data(mem_rdata)
    );


    // Phase 8 Modules
    Exception_Handler EXC_Handler (
        .clk(clk),
        .reset(reset),
        .exception_occurred(1'b0), // Dummy (needs real exception signals)
        .exception_pc(if_pc),      
        .recover(excp_recover),
        .recover_rob_ptr(excp_recover_rob_ptr),
        .trap_pc(excp_trap_pc)
    );

    Precise_Retirement_Logic PR_Logic (
        .clk(clk),
        .reset(reset),
        .rob_commit_valid(alu_done),     // ALU done means ready to commit
        .rob_commit_arch(id_rd_addr_reg), // The architectural register being written
        .exception_detected(excp_recover), // If exception, disable retirement
        .retirement_enable(retire_enable)
    );

    Trap_Vector_Table TVT (
        .cause(4'b0001), // Illegal instruction
        .handler_address(excp_trap_pc) // Connect to Exception Handler's trap_pc
    );

    // Pipeline Registers and Control Logic

    // IF/ID Pipeline Register
    always @(posedge clk or posedge reset) begin
        if (reset || spec_flush || excp_recover) begin
            pc_reg <= 0;
            id_instruction_reg <= 0;
        end else begin
            // Simplified PC increment.
            // In a real system, PC would be updated by branch target, jump target, or next sequential PC.
            pc_reg <= if_pc; // IF_Unit already increments pc +4
            id_instruction_reg <= if_instruction;
        end
    end

    // ID/REN Pipeline Register
    always @(posedge clk or posedge reset) begin
        if (reset || spec_flush || excp_recover) begin
            id_rd_addr_reg <= 0;
            // Clear other rename inputs
            ren_opcode_reg <= 0;
            ren_src1_prf_reg <= 0;
            ren_src2_prf_reg <= 0;
            ren_dest_prf_reg <= 0;
            ren_src1_ready_reg <= 0;
            ren_src2_ready_reg <= 0;
            ren_valid_reg <= 0;
        end else begin

            id_rd_addr_reg <= id_rd_addr; // Store architectural RD for commit

            // For Rename Logic inputs:
            ren_opcode_reg <= id_opcode_full[4:0]; // Uses simplified opcode for RS
            ren_src1_prf_reg <= rn_src_phys_reg1; // from the Rename_Map_Table lookup
            ren_src2_prf_reg <= rn_src_phys_reg2; // From the Rename_Map_Table lookup
            ren_dest_prf_reg <= rn_dest_phys_reg; // New physical register for destination
            ren_valid_reg <= rn_valid;            // Valid from rename indicating successful allocation

            // Source Ready: Simplified for now. In a real design, this would check the Future File/PRF status.
            // For now, assuming if the register is not the destination of a pending instruction on CDB, it's ready.
            ren_src1_ready_reg <= 1'b1; // Dummy: In reality, check if src1_prf is ready in PRF
            ren_src2_ready_reg <= 1'b1; // Dummy: In reality, check if src2_prf is ready in PRF

        end
    end

    // RS Issue to Execution Pipeline Register
    // (This would typically be the issue queue/scheduling logic output)
    always @(posedge clk or posedge reset) begin
        if (reset || spec_flush || excp_recover) begin
            issue_valid_reg <= 0;
            issue_opcode_reg <= 0;
            issue_src1_data_reg <= 0;
            issue_src2_data_reg <= 0;
            issue_dest_prf_reg <= 0;
        end else begin
            issue_valid_reg <= rs_issue_valid;
            issue_opcode_reg <= rs_issue_opcode;
            issue_src1_data_reg <= prf_read_data1; // Read actual data from PRF
            issue_src2_data_reg <= prf_read_data2; // Read actual data from PRF
            issue_dest_prf_reg <= rs_issue_dest_prf;
        end
    end

    // Execution to Writeback/Commit Pipeline Register
    always @(posedge clk or posedge reset) begin
        if (reset || spec_flush || excp_recover) begin
            exec_result_reg <= 0;
            exec_dest_prf_reg <= 0;
            exec_done_reg <= 0;
        end else begin
            exec_result_reg <= alu_result;
            exec_dest_prf_reg <= issue_dest_prf_reg; // Pass destination physical register
            exec_done_reg <= alu_done;
        end
    end

    // Writeback Logic (PRF write)
    assign prf_write_enable = exec_done_reg; // Write to PRF when ALU is done
    assign prf_write_phys_reg = exec_dest_prf_reg;
    assign prf_write_data = exec_result_reg;

    // Commit Logic (Architectural Register File write and Free List update)
    assign rf_write_enable = retire_enable;
    // The architectural register to write to should come from the ROB when committing
    // For this simple example, we'll assume a direct mapping back from `id_rd_addr_reg` which is problematic in OOO.
    // In a real ROB, `rob_commit_arch` would carry this information from the ROB entry.
    assign rf_write_addr = id_rd_addr_reg; // Assumes instruction commits in order of ID
    assign rf_write_data = exec_result_reg; // Data comes directly from execution result

    // Free List Freeing (Actual implementation usually involves ROB informing Free List)
    // For demonstration, let's assume the *previous* physical register mapped to id_rd_addr_reg
    // needs to be freed when a new one is allocated. This requires tracking the old physical register.
    // This is not directly shown here and would involve the Reorder Buffer's "old_physical_reg" field.
    // For now, free_valid in Free_List is tied to 0.

    // Memory Access control for Data_Mem (LSQ interaction)
    // This logic needs to be more robust. It should be driven by LSQ's head entry.
    assign mem_we = 1'b0; // Dummy for now
    assign mem_addr = 32'b0; // Dummy for now

    // Connecting CDB_Bus output to Reservation_Stations inputs
    // CDB_Bus has cdb_tag (32-bit), but broadcast_tag (input) is 6-bit, a mismatch.
    // Assuming cdb_tag_to_rs carries the 6-bit physical register tag.
    // The `cdb_tag` in `Common_Data_Bus` should ideally be `[5:0]` to match `broadcast_tag`.
    // Fixing `Common_Data_Bus` module's output port width.
    assign cdb_tag_to_rs = {26'b0, cdb_tag_from_brdcstr}; // Padding 6-bit tag to 32-bit for `cdb_tag_to_rs`
endmodule
