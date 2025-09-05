# Physical Design Flow (RTL-to-GDSII)

## Overview
This folder contains the results of the **RTL-to-GDSII flow** for the FlexiMAC project.  
The flow was implemented using **Cadence digital design tools** targeting the **SCL 180nm CMOS technology node**.  

The steps include synthesis, floorplanning, placement, clock tree synthesis, routing, and final GDSII generation.  
Representative images for floorplanning, placement/density, and the final GDSII layout are provided in this folder.

---

## Tools Used
- **Genus Synthesis Solution**  
  - RTL-to-gate-level netlist synthesis  
  - Technology mapping using SCL 180nm standard cell library  

- **Innovus Implementation System**  
  - Floorplanning and power planning  
  - Placement and density optimization  
  - Clock Tree Synthesis (CTS)  
  - Routing (global and detailed)  
  - Final GDSII generation  

- **Virtuoso (for verification/visualization)**  
  - Layout verification (DRC/LVS checks)  
  - Viewing and analyzing the final GDSII  

---

## Flow Summary
1. **RTL Synthesis (Genus)**  
   - Input: Verilog RTL (MAC + Activation Engine)  
   - Output: Gate-level netlist mapped to SCL 180nm cells  

2. **Floorplanning (Innovus)**  
   - Defined core and IO area  
   - Power/ground rails planned  

3. **Placement (Innovus)**  
   - Standard cells placed to optimize area and wirelength  
   - Density analysis performed  

4. **Clock Tree Synthesis (Innovus)**  
   - Balanced clock distribution network generated  
   - Skew and latency minimized  

5. **Routing (Innovus)**  
   - Global + detailed routing completed  
   - Congestion analysis performed  

6. **GDSII Generation (Innovus)**  
   - Final physical layout generated  
   - Exported for verification and tape-out readiness  

---


