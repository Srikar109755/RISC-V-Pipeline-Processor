# 🚀 Superscalar Out-of-Order CPU Backend Design

Welcome to a Verilog-based CPU backend design project. This implementation builds a Out-of-Order RISC-V processor pipeline, integrating components such as instruction fetch, decode, register renaming, dynamic scheduling, branch prediction, memory access, and exception handling.

---

## 📁 Table of Contents

* [Project Structure](#project-structure)
* [Phase 1: Baseline Pipeline](#phase-1-baseline-pipeline)
* [Phase 2: Rename Logic & Free List](#phase-2-rename-logic--free-list)
* [Phase 3: Reservation Stations, Execution Unit, and CDB](#phase-3-reservation-stations-execution-unit-and-cdb)
* [Phase 4: Reorder Buffer (ROB) and Commit](#phase-4-reorder-buffer-rob-and-commit)
* [Phase 5: Branch Prediction and Speculative Control](#phase-5-branch-prediction-and-speculative-control)
* [Phase 6: Instruction Wakeup + CDB Integration](#phase-6-instruction-wakeup--cdb-integration)
* [Phase 7: Load-Store Queue and Memory Access](#phase-7-load-store-queue-and-memory-access)
* [Phase 8: Exception Handling and Precise State Recovery](#phase-8-exception-handling-and-precise-state-recovery)
* [Tools Used](#tools-used)
* [License](#license)

---

## 🗂 Project Structure

```bash
CPU_Backend_Project/
│
├── CPU_Phase1_Baseline_Pipeline/
│   ├── Instruction_Fetch.v
│   ├── Instruction_Decode.v
│   ├── Register_File.v
│   ├── ALU_Execution_Unit.v
│   ├── Memory.v
│   ├── Top_Phase1.v
│   └── Testbench_Phase1.v
│
├── CPU_Phase2_Register_Renaming/
│   ├── Rename_Map_Table.v
│   ├── Free_List.v
│   ├── Physical_Register_File.v
│   ├── Rename_Logic.v
│   ├── Top_Phase2.v
│   └── Testbench_Phase2.v
│
├── CPU_Phase3_Issue_Queue/
│   ├── Reservation_Stations.v
│   ├── Common_Data_Bus.v
│   ├── ALU_Execution_Unit.v
│   ├── Top_Phase3.v
│   └── Testbench_Phase3.v
│
├── CPU_Phase4_Reorder_Buffer/
│   ├── Reorder_Buffer.v
│   ├── Commit_Unit.v
│   ├── Recovery_Logic.v
│   ├── Top_Phase4.v
│   └── Testbench_Phase4.v
│
├── CPU_Phase5_Branch_Prediction/
│   ├── Branch_Predictor.v
│   ├── BTB.v
│   ├── Speculation_Control.v
│   ├── Top_Phase5.v
│   └── Testbench_Phase5.v
│
├── CPU_Phase6_Instruction_Wakeup_CDB_Integration/
│   ├── Wakeup_Logic.v
│   ├── CDB_Broadcaster.v
│   ├── Issue_Controller.v
│   ├── Top_Phase6.v
│   └── Testbench_Phase6.v
│
├── CPU_Phase7_Load_Store_Queue/
│   ├── Address_Calculator.v
│   ├── Load_Store_Queue.v
│   ├── Memory_Access_Controller.v
│   ├── Top_Phase7.v
│   └── Testbench_Phase7.v
│
├── CPU_Phase8_Exception_Handling/
│   ├── Exception_Handler.v
│   ├── Trap_Vector_Table.v
│   ├── Precise_Retirement_Logic.v
│   ├── Top_Phase8.v
│   └── Testbench_Phase8.v
│
├── Final_CPU_Top_Level/
    ├── Top_OoO_CPU.v
    └── TB_OoO_CPU.v
```

---

## Phase 1: Baseline Pipeline

### ✅ Description

In Phase 1, I implemented a simple in-order 5-stage RISC-V pipeline consisting of:

* Instruction Fetch (IF)
* Instruction Decode (ID)
* Register File (Architectural)
* ALU Execution (EX)
* Memory Access (MEM)
* Write Back (WB)

This pipeline uses direct architectural registers without any renaming.

### ✅ Module Structure

* `Instruction_Fetch.v`
* `Instruction_Decode.v`
* `Register_File.v`
* `Execution_Unit_ALU.v`
* `Memory.v`
* `Top_Phase1.v`
* `Testbench_Phase1.v`

### ✅ Testcases

* Simulated multiple simple RISC-V instructions with different source and destination registers.

[🔗 Go to Phase 1 Code Folder](https://github.com/Srikar109755/RISC-V-Pipeline-Processor/tree/main/CPU_Phase1_Baseline_Pipeline)

---

## Phase 2: Rename Logic & Free List

### ✅ Description

In Phase 2, I introduced Register Renaming support, including:

* Rename Map Table (Architectural → Physical register mapping)
* Free List (Dynamic physical register allocation)
* Physical Register File (Actual register data storage)
* Rename Logic (Full integration of renaming system)

### ✅ Module Structure

* `Rename_Map_Table.v`
* `Free_List.v`
* `Physical_Register_File.v`
* `Rename_Logic.v`
* `Top_Phase2.v`
* `Testbench_Phase2.v`

### ✅ Key Features

* 64-entry physical register file
* Rename table with 32 architectural registers
* Proper handling of x0 (architectural register 0 never gets renamed)
* Free list allocation with availability check
* Fully functional testbench simulating multiple renaming scenarios

[🔗 Go to Phase 2 Code Folder](https://github.com/Srikar109755/RISC-V-Pipeline-Processor/tree/main/CPU_Phase2_Register_Renaming)

---

## Phase 3: Reservation Stations, Execution Unit, and CDB

### ✅ Description

In Phase 3, I built a simplified Out-of-Order issue and execution model, introducing:

* **Reservation Stations (RS)** — dynamically buffer ready & waiting instructions.
* **Common Data Bus (CDB)** — broadcasts execution results to wake up dependent instructions.
* **ALU Execution Unit** — executes simple ALU operations (ADD, SUB, MUL).
* **Dependency tracking** — instructions with unavailable operands wait inside RS until their dependencies are resolved via CDB.

### ✅ Module Structure

* `Reservation_Stations.v`
* `Common_Data_Bus.v`
* `ALU_Execution_Unit.v`
* `Top_Phase3.v`
* `Testbench_Phase3.v`

### ✅ Key Features

* Fully functional RS wake-up logic driven by the CDB.
* Source operand ready bits handled accurately.
* Simple simulation of dynamic instruction insertion and dependent instruction execution.
* Models the essential micro-architecture concept of broadcast-based dependency resolution.

[🔗 Go to Phase 3 Code Folder](https://github.com/Srikar109755/RISC-V-Pipeline-Processor/tree/main/CPU_Phase3_Issue_Queue)

---

## Phase 4: Reorder Buffer (ROB) and Commit

### ✅ Description

In Phase 4, I implemented a **Reorder Buffer (ROB)** to support **in-order retirement** of instructions that execute out-of-order. This enables correct architectural state updates, branch recovery, and precise exception handling.

### ✅ Module Structure

* `Reorder_Buffer.v`
* `Commit_Unit.v`
* `Recovery_Logic.v`
* `Top_Phase4.v`
* `Testbench_Phase4.v`

### ✅ Key Features

* Full circular buffer management using `head`, `tail`, `valid`, `ready`, and `empty/full` flags
* CDB-based result collection and readiness update
* In-order commit enforcement and physical register release signaling
* Flush logic for misprediction recovery with pointer rollback
* Comprehensive simulation validating proper commit and flush behavior

[🔗 Go to Phase 4 Code Folder](https://github.com/Srikar109755/RISC-V-Pipeline-Processor/tree/main/CPU_Phase4_Reorder_Buffer)

---

## Phase 5: Branch Prediction and Speculative Control

### ✅ Description

In Phase 5, I added **branch prediction and speculative control logic** to allow the pipeline to guess branch directions early and recover from incorrect predictions. This improves instruction fetch throughput and prepares the design for out-of-order execution.

### ✅ Module Structure

* `Branch_Predictor.v`
* `BTB.v`
* `Speculation_Control.v`
* `Top_Phase5.v`
* `TB_Phase5.v`

### ✅ Key Features

* Accurate taken/not-taken prediction based on local branch history.
* Tag-based BTB lookup with prediction validation.
* Full pipeline flush and PC redirection on misprediction.
* Simulates prediction updates and target caching dynamically during execution.

[🔗 Go to Phase 5 Code Folder](https://github.com/Srikar109755/RISC-V-Pipeline-Processor/tree/main/CPU_Phase5_Branch_Prediction)

---

## Phase 6: Instruction Wakeup + CDB Integration

### ✅ Description

In Phase 6, I integrated **Wakeup Logic** and **Common Data Bus (CDB)** broadcasting to enable dynamic tracking of operand readiness. Instructions waiting for operands now become issue-ready the moment their corresponding tags are broadcast on the CDB by execution units.

### ✅ Module Structure

* `Wakeup_Logic.v`
* `CDB_Broadcaster.v`
* `Issue_Controller.v`
* `Top_Phase6.v`
* `Testbench_Phase6.v`

### ✅ Key Features

* Source readiness dynamically determined by tag comparison with CDB.
* Instructions issue only when both operands are ready.
* Simulates broadcast from execution units and observes downstream instruction activation.
* Realistic representation of out-of-order execution behavior.

[🔗 Go to Phase 6 Code Folder](https://github.com/Srikar109755/RISC-V-Pipeline-Processor/tree/main/CPU_Phase6_Instruction_Wakeup_CDB_Integration)

---

## Phase 7: Load-Store Queue and Memory Access

### ✅ Description

In Phase 7, I implemented a **Load-Store Queue (LSQ)** and integrated it with an **Address Calculator** and **Memory Access Controller**. This simulates realistic out-of-order memory access with effective address generation, buffering of memory instructions, and proper handling of read/write operations.

### ✅ Module Structure

* `Address_Calculator.v`
* `Load_Store_Queue.v`
* `Memory_Access_Controller.v`
* `Top_Phase7.v`
* `Testbench_Phase7.v`

### ✅ Key Features

* Queue-based buffering of memory instructions.
* Simulates correct load and store operation sequences.
* Supports instruction commit behavior for stores and immediate access for loads.
* Memory access abstraction through a centralized controller.
* Address calculation logic using base + offset format.

[🔗 Go to Phase 7 Code Folder](https://github.com/Srikar109755/RISC-V-Pipeline-Processor/tree/main/CPU_Phase7_Load_Store_Queue)

---

## Phase 8: Exception Handling and Precise State Recovery

### ✅ Description

In Phase 8, I implemented **exception handling and precise retirement control** to support recovery from invalid instructions or hardware faults. This ensures that the CPU can safely roll back to a known good state and handle traps correctly.

### ✅ Module Structure

* `Exception_Handler.v` – Detects exceptions and signals rollback and trap address  
* `Trap_Vector_Table.v` – Maps exception causes to handler addresses  
* `Precise_Retirement_Logic.v` – Ensures correct retirement behavior under exception  
* `Top_Phase8.v` – Integrates exception control and retirement logic  
* `Testbench_Phase8.v` – Verifies behavior through commit and exception scenarios  

### ✅ Key Features

* Generates trap PC and recover pointer upon exception detection  
* Halts retirement logic during exceptional conditions  
* Supports fixed trap address (or extendable to vector-based handling)  
* Modular design to plug into existing ROB and Commit infrastructure  
* Fully simulated with commit-before-exception and trap-redirection scenario  

[🔗 Go to Phase 8 Code Folder](https://github.com/Srikar109755/RISC-V-Pipeline-Processor/tree/main/CPU_Phase8_Exception_Handling)

---

## Tools Used

* Language: Verilog HDL  
* Simulation: ModelSim / Vivado / Icarus Verilog  
* Version Control: Git / GitHub  

---

## License

This project is open-source for educational and personal learning purposes.
