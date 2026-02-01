# Asynchronous FIFO (Dual Clock FIFO) – Verilog RTL

## 📌 Overview
This project implements a parameterizable **Asynchronous FIFO** in Verilog that safely transfers data between two independent clock domains using Gray code pointers and double-flop synchronizers.

It supports:
- Independent write clock and read clock
- Safe Clock Domain Crossing (CDC)
- Full/Empty flag generation
- Configurable width and depth

This design is suitable for:
- UART buffering
- CDC bridges
- Producer/Consumer systems
- High-speed digital SoC blocks

---

## ⚙️ Features

✔ Dual clock (asynchronous) operation  
✔ Parameterized width and depth  
✔ Gray-coded read/write pointers  
✔ 2-FF pointer synchronizers (CDC safe)  
✔ Full and Empty detection  
✔ Supports simultaneous read & write  
✔ Asynchronous reset support  
✔ Verified using behavioral simulation  

---

## 🏗️ Architecture

### FIFO structure
- Memory array
- Binary pointers for addressing
- Gray pointers for CDC transfer
- Double flip-flop synchronizers
- Flag logic

### Clock Domains
- Write Domain → `w_clk`
- Read Domain → `r_clk`

### CDC Technique
- Binary → Gray conversion
- Gray pointer synchronization across domains
- Gray comparison for full/empty

---

## 📂 Files
https://github.com/tanujpatnaik/asynchronous-fifo/blob/main/async_fifo.v
