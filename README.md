# FlexiMAC: Multi-Precision SIMD MAC with CORDIC Activation Engine

## Overview
This repository contains the RTL implementation of a **multi-precision SIMD MAC unit** and an **activation function engine**.  
The design is intended for neural network acceleration, supporting multiple floating-point formats and nonlinear activation functions at the hardware level.

---
<img width="671" height="501" alt="unit" src="https://github.com/user-attachments/assets/ad09b3c8-22f3-40e5-ab7b-0fa6296912d6" />

## Repository Structure
- **MAC/**
  - Implements a SIMD (Single Instruction, Multiple Data) Multiply-Accumulate unit.
  - Equipped with **input memory** and **weight memory**, each capable of storing **64 bytes**.
  - Fully **AXI-enabled**: a processor transfers data to the input and weight memories via **full-duplex AXI**.
  - Supports three precision formats using a 2-bit select line:
    - `00` → **bfloat16 (bf16)**
    - `01` → **float8 (fp8)**
    - `10` → **float4 (fp4)**  
**MAC Unit Netlist:**
<img width="1639" height="568" alt="image" src="https://github.com/user-attachments/assets/8cf3e9a1-36b2-4114-8a2a-e622dfcd8e3f" />
Have added the pdf of netlist in the project file  

- **ActivationEngine/**
  - Implements a CORDIC (**COordinate Rotation DIgital Computer**) based activation function engine.
  - Uses a **lookup table (LUT) approach** for efficient computation.
  - Supports the following activation functions (in **bf16 precision**):
    - Hyperbolic tangent (**tanh**)
    - Sigmoid
    - Softmax

- **PhysicalDesign/**
  - Contains RTL-to-GDSII flow result images, flow is performed using Cadence tools.
    <img width="609" height="611" alt="image" src="https://github.com/user-attachments/assets/eab3538b-bf5f-4548-a1da-03fba5ab7055" />

---

## Key Features
- Multi-precision support (**bf16, fp8, fp4**) for flexibility in performance vs accuracy tradeoffs.
- SIMD MAC architecture optimized for parallel compute workloads.
- AXI interface for easy integration with processors and SoC platforms.
- CORDIC-based nonlinear activation functions for deep learning applications.

---

## Applications
- Deep learning inference accelerators  
- Custom DNN/ML hardware designs  
- Low-precision AI/ML experimentation  
- RTL-based accelerator research  

---

## Future Scope
- Extend activation unit for additional functions (e.g., ReLU, GELU).  
- Add support for INT8 quantization in the MAC unit.  
- Integrate into a larger DNN accelerator pipeline.  

---

