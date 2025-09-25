# FlexiMAC: Multi-Precision SIMD MAC with CORDIC Activation Engine

## Overview
This repository contains the RTL implementation of a **Multi-precision FP8/FP4 DNN Accelerator unit**, **BF16/FP8/FP4 MAC unit**, and an **Activation function engine**.  
The design is intended for neural network acceleration, supporting multiple floating-point formats and nonlinear activation functions at the hardware level.

---
<img width="557" height="412" alt="image" src="https://github.com/user-attachments/assets/6c8f6c43-4b2f-4fbf-909b-849e90d23621" />

## Repository Structure
### Accelerator/

- **Overview/**
  - Custom **DNN accelerator** built on a 32×32 **systolic array**.
  - Processes **32×32×3 images** with a **convolutional layer** (5×5 kernel, stride 1).
  - Equipped with **pipelined SIMD MAC units** supporting multi-precision formats.
  - Includes **built-in ReLU activation** for efficient inference.

- **MAC Unit/**
  - Implements a **SIMD Multiply-Accumulate (MAC)** unit.
  - Equipped with **input memory** and **weight memory**, each storing **64 bytes**.
  - Fully **AXI-enabled**: a processor transfers data to memories via **full-duplex AXI**.
  - Supports three precision formats using a **2-bit select line**:
    - `00` → **bfloat16 (bf16)**
    - `01` → **float8 (fp8)**
    - `10` → **float4 (fp4)**

- **Activation Unit/**
  - **Built-in ReLU activation** directly inside the systolic array pipeline.
  - Separate **CORDIC-based activation module** implemented (not yet integrated) for:
    - **tanh**
    - **sigmoid**
    - **softmax**

- **Pipeline/**
  - Each MAC unit is **pipelined** for higher throughput.
  - Exploits **parallelism with SIMD** instructions.
  - Designed for **low-latency, high-throughput** computation.

- **Future Enhancements/**
  - AXI - Interfacing for RISC Processor.
  - Integration of the **CORDIC-based activation unit** into the main pipeline.
  - Optimizing **dataflow scheduling** for reduced memory bandwidth usage.
  - Exploring support for **additional precision formats** and quantization.  
### MAC/
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

### ActivationEngine/
  - Implements a CORDIC (**COordinate Rotation DIgital Computer**) based activation function engine.
  - Uses a **lookup table (LUT) approach** for efficient computation.
  - Supports the following activation functions (in **bf16 precision**):
    - Hyperbolic tangent (**tanh**)
    - Sigmoid
    - Softmax

### PhysicalDesign/
  - Contains RTL-to-GDSII flow result images of MAC unit, flow is performed using Cadence tools.
    <img width="609" height="611" alt="image" src="https://github.com/user-attachments/assets/eab3538b-bf5f-4548-a1da-03fba5ab7055" />

---

## Key Features
- Multi-precision support (**bf16, fp8, fp4**) for flexible performance vs accuracy tradeoffs.  
- 32×32 **systolic array** with SIMD MACs optimized for parallel compute.  
- **AXI interface** for easy processor/SoC integration.  
- CORDIC-based nonlinear activation unit (tanh, sigmoid, softmax) under development.  

---

## Applications
- Deep learning inference accelerators  
- Custom DNN/ML hardware designs  
- Low-precision AI/ML experimentation  
- RTL-based accelerator research  

---

## Future Scope
- Complete integration of **CORDIC-based activation unit** into the accelerator pipeline.  
- Extend activation support (e.g., ReLU, GELU).  
- Add **INT8 quantization** in MAC units.  
- Optimization for higher throughput and lower memory bandwidth usage.  
- This project is **currently under development**.

---

