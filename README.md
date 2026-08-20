# MIPS

A 32-bit MIPS processor in Verilog, built as a classic five-stage pipeline with full forwarding and hazard detection.

## Hazard handling

| Hazard | Resolution | Cost |
| --- | --- | --- |
| ALU result feeding a later ALU input | Forwarded from `EX/MEM` or `MEM/WB` | free |
| Writeback feeding decode | Write-first register file | free |
| Load feeding the next instruction | Stall the front of the pipeline | 1 cycle |
| Taken branch | Resolved in `EX`, flush `IF/ID` and `ID/EX` | 2 cycles |
| Jump | Resolved in `ID`, flush `IF/ID` | 1 cycle |

## Instruction set

R-type `add` `sub` `and` `or` `xor` `nor` `slt` `sll` `srl` &nbsp;·&nbsp; `lw` `sw` &nbsp;·&nbsp; `beq` `bne` &nbsp;·&nbsp; `addi` `xori` &nbsp;·&nbsp; `j`

## Layout

| Path | Contents |
| --- | --- |
| `rtl/core/` | `MIPS_Top.v`, the pipelined top level |
| `rtl/control/` | main control and ALU control decoders |
| `rtl/datapath/` | ALU, register file, multiplexer, immediate extenders |
| `rtl/memory/` | instruction and data memory |
| `rtl/pipeline/` | stage registers, forwarding unit, hazard unit |
| `tb/` | one testbench per non-trivial module, plus `program.hex` |

## Simulation

```bash
iverilog -o mips_sim -s tb_MIPS_Top $(find rtl -name '*.v') tb/tb_MIPS_Top.v
vvp mips_sim
```

Run from the repository root so the testbench can find `tb/program.hex`. Swap `tb_MIPS_Top` for any other bench in `tb/` to exercise a single module.
