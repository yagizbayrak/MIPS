# MIPS

A 32-bit MIPS architecture implemented in FPGA-oriented Verilog.

## Overview

This repository contains the main building blocks of a simple MIPS-style processor design, including an ALU, control unit, instruction memory, data memory, multiplexers, and immediate-extension modules. The repository description identifies the project as a "32-Bit MIPS Architecture in FPGA Verilog." citeturn310663view0turn182595view0turn182595view1turn182595view2

## Features

- 32-bit ALU with arithmetic, logic, shift, rotate, and comparison operations. 
- Control unit support for common instructions such as R-type, `lw`, `sw`, `bne`, `xori`, and `j`. 
- Separate instruction memory and data memory modules for processor simulation. 
- Immediate extension helpers for sign extension and zero extension. 
- Multiplexer and shift helper modules used in datapath wiring. 

## Repository structure

- `ALU.v` - arithmetic and logic unit plus a testbench.
- `control.v` - main control signal generator.
- `data_mem.v` - synchronous data memory.
- `ins_mem.v` - synchronous instruction memory.
- `mux.v` - 32-bit 2-to-1 multiplexer.
- `sign_extend.v` - sign extension for 16-bit immediates.
- `zero_extend.v` - zero extension for 16-bit immediates.
- `shift_left_two.v` - left-shift helper for branch/jump addressing.

## Getting started

### Simulation

The project is written in Verilog, so you can simulate it with tools such as Icarus Verilog, ModelSim, or Vivado Simulator.

Example using Icarus Verilog:

```bash
iverilog -o mips_sim *.v
vvp mips_sim
```

If your top-level module is different, replace `*.v` with the specific source files you want to compile.

## Notes

- The repository currently appears to focus on core datapath modules rather than a polished full-system wrapper.
- `ALU.v` includes a built-in testbench, so it can be used as a quick starting point for simulation.

## License

Add a license file if you want to define how others can use or reuse this code.
