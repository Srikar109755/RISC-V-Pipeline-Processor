# 🚀 CPU Rename Backend Design (Multi-Phase Project)

Welcome to my full Verilog-based CPU backend project. This repository tracks my progressive design of a superscalar out-of-order CPU backend, starting from a simple pipeline and progressively adding more advanced features.

---

## 📑 Table of Contents

- [Project Overview](#project-overview)
- [Phase 1: Baseline Pipeline](#phase-1-baseline-pipeline)
- [Phase 2: Rename Logic & Free List](#phase-2-rename-logic--free-list)
- [Phase 3: Reservation Stations, Execution Unit, and CDB](#phase-3-reservation-stations-execution-unit-and-cdb)
- [Phase 4: Reorder Buffer (ROB) and Commit](#phase-4-reorder-buffer-rob-and-commit)
- [Phase 5: Branch Prediction and Speculative Control](#phase-5-branch-prediction-and-speculative-control)
- [Phase 6: Instruction Wakeup + CDB Integration](#phase-6-instruction-wakeup--cdb-integration)
- [Future Phases (Planned)](#future-phases-planned)
- [Tools Used](#tools-used)
- [License](#license)

---

## 🚀 Project Overview

This project simulates the backend pipeline stages of a CPU using Verilog HDL, starting from a basic 5-stage pipeline and incrementally adding:

- Register renaming
- Physical register file
- Free list management
- Reservation stations
- Common Data Bus (CDB)
- Reorder buffer with precise commit and recovery
- Branch prediction and speculative control
- Out-of-order execution model
- Issue queue and recovery mechanisms (future phases)

Each phase is stored in its own directory inside this repository.

---

## Phase 1: Baseline Pipeline

### ✅ Description

In Phase 1, I implemented a simple in-order 5-stage RISC-V pipeline consisting of:

- Instruction Fetch (IF)
- Instruction Decode (ID)
- Register File (Architectural)
- ALU Execution (EX)
- Memory Access (MEM)
- Write Back (WB)

This pipeline uses direct architectural registers without any renaming.

### ✅ Module Structure

- `Instruction_Fetch.v`
- `Instruction_Decode.v`
- `Register_File.v`
- `Execution_Unit_ALU.v`
- `Memory.v`
- `Top_Phase1.v` (top module)
- `Testbench_Phase1.v`

### ✅ Testcases

- Simulated multiple simple RISC-V instructions with different source and destination registers.

[🔗 Go to Phase 1 Code Folder](https://github.com/Srikar109755/RISC-V-Pipeline-Processor/tree/main/CPU_Phase1_Baseline_Pipeline)

---

## Phase 2: Rename Logic & Free List

### ✅ Description

In Phase 2, I introduced Register Renaming support, including:

- Rename Map Table (Architectural → Physical register mapping)
- Free List (Dynamic physical register allocation)
- Physical Register File (Actual register data storage)
- Rename Logic (Full integration of renaming system)

This phase forms the core of out-of-order backend rename stage.

### ✅ Module Structure

- `Rename_Map_Table.v`
- `Free_List.v`
- `Physical_Register_File.v`
- `Rename_Logic.v`
- `Top_Phase2.v` (top integration)
- `Testbench_Phase2.v`

### ✅ Key Features

- 64-entry physical register file
- Rename table with 32 architectural registers
- Proper handling of x0 (architectural register 0 never gets renamed)
- Free list allocation with availability check
- Fully functional testbench simulating multiple renaming scenarios

[🔗 Go to Phase 2 Code Folder](https://github.com/Srikar109755/RISC-V-Pipeline-Processor/tree/main/CPU_Phase2_Register_Renaming)

---

## Phase 3: Reservation Stations, Execution Unit, and CDB

### ✅ Description

In Phase 3, I built a simplified Out-of-Order issue and execution model, introducing:

- **Reservation Stations (RS)** — dynamically buffer ready & waiting instructions.
- **Common Data Bus (CDB)** — broadcasts execution results to wake up dependent instructions.
- **ALU Execution Unit** — executes simple ALU operations (ADD, SUB, MUL).
- **Dependency tracking** — instructions with unavailable operands wait inside RS until their dependencies are resolved via CDB.

### ✅ Module Structure

- `Reservation_Stations.v` — implements the reservation station logic.
- `Common_Data_Bus.v` — CDB for broadcasting results to wake-up RS entries.
- `ALU_Execution_Unit.v` — ALU that performs arithmetic operations.
- `Top_Phase3.v` — complete top-level integration.
- `Testbench_Phase3.v` — full testbench with multiple dependent instructions.

### ✅ Key Features

- Fully functional RS wake-up logic driven by the CDB.
- Source operand ready bits handled accurately.
- Simple simulation of dynamic instruction insertion and dependent instruction execution.
- Models the essential micro-architecture concept of broadcast-based dependency resolution.

[🔗 Go to Phase 3 Code Folder](https://github.com/Srikar109755/RISC-V-Pipeline-Processor/tree/main/CPU_Phase3_Issue_Queue)

---

## Phase 4: Reorder Buffer (ROB) and Commit

### ✅ Description

In Phase 4, I implemented a **Reorder Buffer (ROB)** to support **in-order retirement** of instructions that execute out-of-order. This enables correct architectural state updates, branch recovery, and precise exception handling.

Key modules introduced:

- **Reorder_Buffer** — holds instruction metadata until results are ready and committed in-order.
- **Commit_Unit** — writes final results to the architectural register file once instructions reach the ROB head and are marked ready.
- **Recovery_Logic** — detects branch misprediction, issues flush, and resets ROB state based on `recover_ptr`.

### ✅ Module Structure

- `Reorder_Buffer.v` — manages ROB entries, commit order, and flush-on-mispredict
- `Commit_Unit.v` — performs architectural register writes for committed instructions
- `Recovery_Logic.v` — generates recovery signals and `recover_ptr` on branch misprediction
- `Top_Phase4.v` — integrates ROB, commit, and recovery
- `Testbench_Phase4.v` — includes multiple allocation, execution, and recovery scenarios

### ✅ Key Features

- Full circular buffer management using `head`, `tail`, `valid`, `ready`, and `empty/full` flags
- CDB-based result collection and readiness update
- In-order commit enforcement and physical register release signaling
- Flush logic for misprediction recovery with pointer rollback
- Comprehensive simulation validating proper commit and flush behavior

[🔗 Go to Phase 4 Code Folder](https://github.com/Srikar109755/RISC-V-Pipeline-Processor/tree/main/CPU_Phase4_Reorder_Buffer)

---

## Phase 5: Branch Prediction and Speculative Control

### ✅ Description

In Phase 5, I added **branch prediction and speculative control logic** to allow the pipeline to guess branch directions early and recover from incorrect predictions. This improves instruction fetch throughput and prepares the design for out-of-order execution.

### ✅ Key Components

- `Branch_Predictor.v`: Implements a 2-bit saturating counter predictor indexed by bits of the PC.
- `BTB.v`: A Branch Target Buffer (BTB) that caches previously seen branch targets.
- `Speculation_Control.v`: Handles detection of mispredictions and issues `flush` and `recover_pc` signals.
- `Top_Phase5.v`: Connects predictor, BTB, and speculative recovery into a unified prediction system.
- `TB_Phase5.v`: Stimulates prediction, resolution, and recovery scenarios.

### ✅ Key Features

- Accurate taken/not-taken prediction based on local branch history.
- Tag-based BTB lookup with prediction validation.
- Full pipeline flush and PC redirection on misprediction.
- Simulates prediction updates and target caching dynamically during execution.

[🔗 Go to Phase 5 Code Folder](https://github.com/Srikar109755/RISC-V-Pipeline-Processor/tree/main/CPU_Phase5_Branch_Prediction)

---

## Phase 6: Instruction Wakeup + CDB Integration

### ✅ Description

In Phase 6, I integrated **Wakeup Logic** and **Common Data Bus (CDB)** broadcasting to enable dynamic tracking of operand readiness. Instructions waiting for operands now become issue-ready the moment their corresponding tags are broadcast on the CDB by execution units.

This phase models the core of Tomasulo-style scheduling, where instructions wake up dynamically based on execution progress.

### ✅ Module Structure

- `Wakeup_Logic.v` — Compares operand tags with CDB broadcast and updates ready status.
- `CDB_Broadcaster.v` — Signals destination physical register tags to wake up dependent instructions.
- `Issue_Controller.v` — Checks readiness of operands using `Wakeup_Logic` and issues instructions when ready.
- `Top_Phase6.v` — Top-level module wiring together CDB, wakeup, and issue logic.
- `Testbench_Phase6.v` — Simulates operand readiness transitions via CDB and validates instruction wakeup.

### ✅ Key Features

- Source readiness dynamically determined by tag comparison with CDB.
- Instructions issue only when both operands are ready.
- Simulates broadcast from execution units and observes downstream instruction activation.
- Realistic representation of out-of-order execution behavior.

[🔗 Go to Phase 6 Code Folder](https://github.com/Srikar109755/RISC-V-Pipeline-Processor/tree/main/CPU_Phase6_Instruction_Wakeup_CDB_Integration)

---

## Future Phases (Planned)

| Phase    | Description                              | Status     |
|----------|------------------------------------------|------------|
| Phase 7  | Full Issue Queue + Multi-Issue Backend   | 🔜 Planned |
| Phase 8  | Memory Disambiguation and Load-Store Queue | 🔜 Planned |
| Phase 9  | Register Reclamation and Checkpointing   | 🔜 Planned |

---

## Tools Used

- Language: Verilog HDL
- Simulation: ModelSim / Vivado / Icarus Verilog
- Version Control: Git / GitHub

---

## License

This project is open-source for educational and personal learning purposes.
