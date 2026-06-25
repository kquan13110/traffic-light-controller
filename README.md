# Traffic Light Controller

## Project Overview

This project implements a parameterized Verilog RTL traffic light controller for a two-direction intersection. The design combines a Moore FSM, a BCD down-counter, a 24-hour BCD clock, automatic rush-hour mode selection, manual blink/hold overrides, and four seven-segment display outputs for countdown visualization.

The project is organized as a clean GitHub portfolio repository for Digital IC / RTL design review.

## Key Features

- Two-lane traffic light sequence: Lane 1 green/yellow while Lane 2 red, then Lane 2 green/yellow while Lane 1 red.
- Parameterized normal, rush-hour, and yellow durations.
- Automatic rush-hour detection using a BCD 24-hour clock.
- Manual yellow-blink override for caution mode.
- Manual hold override to pause the current green phase.
- BCD countdown and seven-segment display decoder.
- Self-contained Verilog testbench for functional simulation.

## FSM / State Description

The traffic light FSM is implemented in `rtl/fsm.v` as a four-state Moore machine:

| State | Lane 1 | Lane 2 | Next transition |
| --- | --- | --- | --- |
| `S0_G1_R2` | Green | Red | Move to `S1_Y1_R2` when `timeout_yellow` is asserted. |
| `S1_Y1_R2` | Yellow | Red | Move to `S2_R1_G2` when `timeout_total` is asserted. |
| `S2_R1_G2` | Red | Green | Move to `S3_R1_Y2` when `timeout_yellow` is asserted. |
| `S3_R1_Y2` | Red | Yellow | Move to `S0_G1_R2` when `timeout_total` is asserted. |

Manual modes override the automatic normal/rush timing mode. Blink mode pauses the counter and toggles both yellow lights using the divided clock. Hold mode pauses the counter and keeps the current green phase.

## Timing Behavior

The top-level parameters define the phase timing:

| Parameter | Default | Description |
| --- | ---: | --- |
| `P_TIME_NORM` | `8'h30` | Full phase duration in normal mode, encoded as BCD. |
| `P_TIME_RUSH` | `8'h60` | Full phase duration in rush-hour mode, encoded as BCD. |
| `P_TIME_YEL` | `8'h05` | Yellow interval threshold, encoded as BCD. |
| `P_CLK_DIV` | `25000000` | Input clock divider value used to generate `clk1`. |

The down-counter reloads the selected full phase duration at zero. `timeout_yellow` asserts when the counter reaches `P_TIME_YEL`, and `timeout_total` asserts when the counter reaches zero.

Rush-hour mode is selected automatically during:

- 07:00:00 to 09:00:00
- 17:00:00 to 19:00:00

## Input / Output Signals

Top-level module: `top` in `rtl/top.v`.

| Signal | Direction | Width | Description |
| --- | --- | ---: | --- |
| `clk0` | Input | 1 | Base clock input. |
| `Reset` | Input | 1 | Active-high asynchronous reset. |
| `btn_up` | Input | 1 | Active-low time-adjust increment button. |
| `btn_down` | Input | 1 | Active-low time-adjust decrement button. |
| `mode_time` | Input | 3 | Selects seconds/minutes/hours adjustment mode. |
| `sw_blink` | Input | 1 | Manual blink override. |
| `sw_hold` | Input | 1 | Manual hold override. |
| `HEX0`-`HEX3` | Output | 7 each | Seven-segment countdown display outputs. |
| `LR1`, `LY1`, `LG1` | Output | 1 each | Lane 1 red/yellow/green lights. |
| `LR2`, `LY2`, `LG2` | Output | 1 each | Lane 2 red/yellow/green lights. |
| `o_gio` | Output | 8 | BCD hour output. |
| `o_phut` | Output | 8 | BCD minute output. |
| `o_giay` | Output | 8 | BCD second output. |

## Verification Strategy

The testbench `tb/tb_top.v` accelerates the clock divider and checks the main operating modes:

- Automatic normal-mode behavior around 07:00:00.
- Automatic rush-hour behavior around 17:00:00.
- Exit behavior near the evening rush-hour boundary.
- Manual blink override.
- Manual hold override and counter pause.
- Manual priority check where hold has priority over blink.

The testbench uses hierarchical `force/release` on the internal clock registers to jump to selected time values and reduce simulation runtime.

## Folder Structure

```text
.
├── docs/
│   └── fsm.md
├── rtl/
│   ├── bcd_arithmetic.v
│   ├── clock24h.v
│   ├── dem_giay.v
│   ├── dem_gio.v
│   ├── dem_phut.v
│   ├── divide_freq.v
│   ├── downcounter.v
│   ├── fsm.v
│   ├── led7seg.v
│   ├── mode_select.v
│   └── top.v
├── sim/
│   └── run_icarus.sh
└── tb/
    └── tb_top.v
```

## Tools Used

- Verilog RTL
- Icarus Verilog for compile/simulation
- Verilator for RTL lint, when available
- Questa/ModelSim compatible source and testbench style

## How to Run Simulation

Run the Icarus Verilog simulation from the repository root:

```bash
chmod +x sim/run_icarus.sh
./sim/run_icarus.sh
```

The script compiles all RTL files and the testbench into `sim_build/tb_top.vvp`, then runs it with `vvp`.

Optional Verilator lint:

```bash
verilator --lint-only rtl/*.v
```

## Results

The included testbench prints progress messages for each scenario and reports a `PASS` message for the manual priority check when hold mode remains active while blink is also asserted. Waveform files are intentionally not committed; generated simulation outputs are ignored by `.gitignore`.
