# 🧠 MIPS CPU Project

A combined overview of my **Single-Cycle MIPS** and **Pipelined MIPS** processor implementations, including architecture, datapath, control logic, and hazard handling.

---

## 🚀 Project Overview

This repository contains two CPU designs implementing the MIPS instruction set:

1. **Single-Cycle MIPS Processor**
2. **Five-Stage Pipelined MIPS Processor**

Both versions follow the classic MIPS architecture with the standard stages:

* **IF** – Instruction Fetch
* **ID** – Instruction Decode & Register Read
* **EX** – Execute / ALU
* **MEM** – Memory Access
* **WB** – Write Back

The processors run the same instruction set and share similar datapath components, but differ in execution timing, performance, and complexity.

---

# 1. 🟦 Single-Cycle MIPS

### ✔ Summary

The **single-cycle CPU** executes every instruction in **one long clock cycle**.
All stages (IF → ID → EX → MEM → WB) happen sequentially within the same cycle.

### 🔧 Architecture

* Instruction Memory
* Register File
* ALU
* Data Memory
* Control Unit
* Sign Extender
* PC & PC Increment Logic
* Multiple multiplexers connecting datapath components

### 🟢 Advantages

* Simple to understand
* No hazards (only one instruction active)
* Easy to debug and simulate

### 🔴 Limitations

* **Very long clock cycle** (determined by slowest instruction)
* Inefficient hardware usage
* Not scalable for real performance

---

# 2. 🟩 Pipelined MIPS (5-Stage Pipeline)

### ✔ Summary

The pipelined CPU breaks instruction execution into five stages and processes multiple instructions simultaneously.

Once the pipeline is filled, it completes **one instruction per clock cycle**.

### 🔧 Architecture Extensions

* Pipeline registers:

  * **IF/ID**, **ID/EX**, **EX/MEM**, **MEM/WB**
* Forwarding Unit
* Hazard Detection Unit
* Stall Logic
* Branch/Jump Flush Logic

### 🟢 Advantages

* Much higher throughput
* Shorter clock cycle
* Realistic CPU design

### 🔴 Challenges

* Data hazards
* Control hazards
* Additional hardware complexity

---

# 3. 📊 Performance Comparison

| Feature           | Single-Cycle | Pipelined                 |
| ----------------- | ------------ | ------------------------- |
| CPI               | 1            | ≈ 1                       |
| Clock Speed       | Slow         | Fast                      |
| Throughput        | Low          | High                      |
| Hazards           | None         | Yes (resolved with logic) |
| Design Complexity | Low          | High                      |

---

# 4. ⚙️ Hazards (Pipeline Only)

### 🔸 Data Hazards

Handled using:

* Forwarding
* Stalls (for LW-use cases)

### 🔸 Control Hazards

Handled using:

* Branch flush
* Possible early branch resolution

### 🔸 Structural Hazards

Avoided using **separate instruction and data memories**.

---

# 5. 🧩 Shared Components in Both Versions

* ALU
* Register File
* Sign Extender
* Instruction Memory
* Data Memory
* PC logic
* Control Unit (extended in pipelined version)

Both CPUs run the same MIPS instructions — they only differ in timing and datapath organization.

---

# 6. 🧪 Testbenches

Both designs include testbenches for:

* ALU
* Register File
* Control Unit
* Full CPU execution
* Pipeline hazard cases (forwarding, stalls, branches)

---

# 7. 🧑‍💻 Author

I am a computer engineering student interested in low-level hardware design, CPU architecture, and FPGA systems.
This project helped me understand the transition from a simple single-cycle architecture to a fully pipelined CPU with hazard handling and realistic performance considerations.


