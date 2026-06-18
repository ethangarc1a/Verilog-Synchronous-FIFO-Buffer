# Synchronous FIFO Buffer in Verilog

## Overview

This project implements a parameterized synchronous FIFO buffer in Verilog HDL. The FIFO stores data in first-in, first-out order and includes read/write pointer control, occupancy tracking, full and empty status flags, overflow detection, underflow detection, and pointer wraparound behavior.

This project was created to practice RTL design, simulation, and waveform-based verification for VLSI, FPGA, and digital design applications.

## Features

* 8-bit data width
* 16-entry FIFO depth
* Single-clock synchronous design
* Register-array storage
* Read and write pointer control
* Occupancy counter
* Full and empty status flags
* Overflow and underflow detection
* Pointer wraparound support
* Verilog testbench verification
* GTKWave waveform analysis

## File Structure

```text
main.v                         RTL implementation of the synchronous FIFO
tb_main.v                      Verilog testbench used for simulation and verification
Sync_FIFO_Buffer Screenshots/  Terminal and GTKWave verification screenshots
README.md                      Project documentation
```

## Design Description

The FIFO uses a register-array memory to store incoming data. A write pointer tracks the next location where data should be written, while a read pointer tracks the oldest stored value to be read out.

The `count` register tracks how many values are currently stored in the FIFO. When `count` reaches 16, the `full` flag is asserted. When `count` reaches 0, the `empty` flag is asserted.

Invalid operations are also detected:

* `overflow` asserts when a write is attempted while the FIFO is full
* `underflow` asserts when a read is attempted while the FIFO is empty

## How to Run

```bash
mkdir -p waveforms
iverilog -o fifo_sim main.v tb_main.v
vvp fifo_sim
gtkwave waveforms/sync_fifo.vcd
```

## Verification Results

### Terminal Output

![Terminal Output](Sync_FIFO_Buffer%20Screenshots/terminal_pass.png)

This verifies that the design compiled successfully, the simulation ran, and all FIFO testbench checks passed.

### Reset Behavior

![Reset Behavior](Sync_FIFO_Buffer%20Screenshots/reset_behavior.png)

This verifies that reset initializes the FIFO into a clean starting state. After reset, the FIFO count is cleared, `empty` is asserted, and `full` remains deasserted.

### FIFO Order Verification

![FIFO Order](Sync_FIFO_Buffer%20Screenshots/fifo_order.png)

This verifies first-in, first-out behavior. The waveform shows values being written into the FIFO and later read back in the same order.

### Full Flag and Overflow Verification

![Full and Overflow](Sync_FIFO_Buffer%20Screenshots/full_overflow.png)

This verifies that the FIFO reaches its maximum depth of 16 entries, asserts the `full` flag, and detects an invalid write attempt using the `overflow` flag.

## Testbench Coverage

The Verilog testbench verifies:

* Reset behavior
* FIFO write and read ordering
* Full flag assertion
* Empty flag assertion
* Overflow detection
* Underflow detection
* Pointer wraparound behavior

## Tools Used

* Verilog HDL
* Icarus Verilog
* GTKWave
* Git/GitHub

## Key Concepts Demonstrated

* RTL design
* Synchronous sequential logic
* FIFO memory behavior
* Read/write pointer management
* Occupancy counting
* Full and empty flag generation
* Overflow and underflow handling
* Testbench development
* Waveform-based verification
