# 🚀 CPU Rename Backend Design (Multi-Phase Project)

Welcome to my full Verilog-based CPU backend project. This repository tracks my progressive design of a superscalar out-of-order CPU backend, starting from a simple pipeline and progressively adding more advanced features.

---

## 📑 Table of Contents

- [Project Overview](#project-overview)
- [Phase 1: Baseline Pipeline](#phase-1-baseline-pipeline)
- [Phase 2: Rename Logic & Free List](#phase-2-rename-logic--free-list)
- [Phase 3: Reservation Stations, Execution Unit, and CDB](#phase-3-reservation-stations-execution-unit-and-cdb)
- [Phase 4: Reorder Buffer (ROB) and Commit](#phase-4-reorder-buffer-rob-and-commit)
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
- `ALU.v`
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

## Future Phases (Planned)

| Phase    | Description                              | Status     |
|----------|------------------------------------------|------------|
| Phase 5  | Full Issue Queue + Multi-Issue Backend   | 🔜 Planned |
| Phase 6  | Superscalar Out-of-Order CPU             | 🔜 Planned |
| Phase 7  | Branch Predictor + BTB                   | 🔜 Planned |

---

## Tools Used

- Language: Verilog HDL
- Simulation: ModelSim / Vivado / Icarus Verilog
- Version Control: Git / GitHub

---

## License

This project is open-source for educational and personal learning purposes.
