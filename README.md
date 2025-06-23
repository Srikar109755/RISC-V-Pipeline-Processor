# 🚀 CPU Rename Backend Design (Multi-Phase Project)

Welcome to my full Verilog-based CPU backend project. This repository tracks my progressive design of a superscalar out-of-order CPU backend, starting from a simple pipeline and progressively adding more advanced features.

---

## 📑 Table of Contents

- [🚀 Project Overview](#project-overview)
- [⚙️ Phase 1: Baseline Pipeline](#phase-1-baseline-pipeline)
- [⚙️ Phase 2: Rename Logic & Free List](#phase-2-rename-logic--free-list)
- [🔮 Future Phases (Planned)](#future-phases-planned)
- [🛠 Tools Used](#tools-used)
- [📄 License](#license)

---

## 🚀 Project Overview

This project simulates the backend pipeline stages of a CPU using Verilog HDL, starting from a basic 5-stage pipeline and incrementally adding:

- Register renaming
- Physical register file
- Free list management
- Reorder buffer (future phase)
- Issue queue (future phase)
- Out-of-order execution model (future phase)

Each phase is stored in its own directory inside this repository.

---

## ⚙️ Phase 1: Baseline Pipeline

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

## ⚙️ Phase 2: Rename Logic & Free List

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

## 🔮 Future Phases (Planned)

| Phase | Description | Status |
|-------|-------------|--------|
| Phase 3 | Reorder Buffer | 🔜 Planned |
| Phase 4 | Issue Queue / Reservation Stations | 🔜 Planned |
| Phase 5 | Full Superscalar Out-of-Order CPU | 🔜 Planned |

---

## 🛠 Tools Used

- Language: Verilog HDL
- Simulation: ModelSim / Vivado / Icarus Verilog
- Version Control: Git / GitHub

---

## 📄 License

This project is open-source for educational and personal learning purposes.

---

