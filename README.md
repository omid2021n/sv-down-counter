# sv-down-counter

A parameterised down-counter written in SystemVerilog. It supports loading a value, decrementing on demand, optional auto-reload, and two status flags (`done_o` and `almost_done_o`).

## Features

- Configurable counter width (`Width`)
- Two modes, chosen by the `AutoReload` parameter:
  - **AutoReload = 0:** load a value with `load_i`, count down with `dec_i`, stop at 0
  - **AutoReload = 1:** when the counter is 0 and `dec_i` is high, it reloads `load_val_i`
- Registered `done_o` and `almost_done_o` flags that update on the same clock edge as `cnt_o`
- Synchronous, active-high reset

## Parameters

| Parameter    | Default | Description                                         |
|--------------|---------|-----------------------------------------------------|
| `Width`      | 8       | Width of the counter and of `load_val_i`            |
| `AutoReload` | 1       | 1 = reload from `load_val_i` at zero, 0 = stop at 0 |

## Ports

| Port            | Direction | Width   | Description                                       |
|-----------------|-----------|---------|---------------------------------------------------|
| `clk_i`         | input     | 1       | Clock                                             |
| `rst_i`         | input     | 1       | Synchronous reset, active high                    |
| `load_val_i`    | input     | `Width` | Value to load or reload                           |
| `load_i`        | input     | 1       | Load `load_val_i` (only used when AutoReload = 0) |
| `dec_i`         | input     | 1       | Decrement the counter by 1                        |
| `cnt_o`         | output    | `Width` | Current counter value                             |
| `almost_done_o` | output    | 1       | High when the counter is 1 or 0                   |
| `done_o`        | output    | 1       | High when the counter is 0                        |

## Behaviour

**AutoReload = 0** (first matching row wins)

| `load_i` | `dec_i` | Counter  | Next value   |
|----------|---------|----------|--------------|
| 1        | x       | any      | `load_val_i` |
| 0        | 1       | > 0      | count − 1    |
| 0        | 1       | 0        | 0 (stops)    |
| 0        | 0       | any      | no change    |

**AutoReload = 1** (`load_i` is ignored)

| `dec_i` | Counter | Next value   |
|---------|---------|--------------|
| 1       | > 0     | count − 1    |
| 1       | 0       | `load_val_i` |
| 0       | any     | no change    |

After reset: `cnt_o = 0`, `done_o = 1`, `almost_done_o = 1`.

## Verification

The testbench `ip_cnt_down_tb.sv` runs both modes side by side (two DUT instances, AutoReload = 0 and 1) with a 25 MHz clock.

SystemVerilog Assertions (SVA) check that, in both modes:

- `done_o` is high only when `cnt_o == 0`
- `almost_done_o` is high only when `cnt_o <= 1`

The testbench counts assertion failures and prints `TEST PASSED` or `TEST FAILED` at the end. It also writes a waveform file (`ip_cnt_down_tb.vcd`).

## How to run (Questa / ModelSim)

```sh
vlog -sv ip_cnt_down.sv ip_cnt_down_tb.sv
vsim -c ip_cnt_down_tb -do "run -all; quit"
```

## Files

| File               | Description              |
|--------------------|--------------------------|
| `ip_cnt_down.sv`    | RTL design              |
| `ip_cnt_down_tb.sv` | Testbench with SVA checks |

## To do

- [ ] Add a reference model and an assertion that checks the value of `cnt_o`
- [ ] Add a constrained-random test for `load_i`, `dec_i` and `load_val_i`
- [ ] Test reset during counting, load values of 0 and 1, and other `Width` values
- [ ] Add functional coverage
