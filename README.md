Register File with Performance Metrics and Testbench

Overview

This project implements a parameterizable Register File system in Verilog, equipped with modules for data storage, control logic, and multiplexing. It also includes performance metrics calculations (gate count and delay estimation) and a comprehensive testbench for validation.

Features

D Flip-Flop: A fundamental building block for the registers.

Multi-Bit Register: Stores multi-bit data with write-enable and asynchronous reset capabilities.

Multiplexers:

Mux2to1: A basic 2-to-1 multiplexer.

MuxNto1: Hierarchical N-to-1 multiplexer for efficient data selection.

Control Logic: Synchronizes load operations with clock and enable signals.

Register File:

Parameterized for bit-width (N) and the number of registers (M).

Supports write and read operations with addressable registers.

Performance Metrics:

Estimates gate count and critical path delays.

Testbench:

Validates functionality through multiple test cases.

Includes clock generation and signal initialization.

Module Descriptions

1. DFlipFlop

Implements a single-bit D flip-flop with asynchronous reset.

Captures data on the rising edge of the clock.

2. MultiBitRegister

Parameterized register for storing N-bit data.

Supports asynchronous reset and write-enable functionality.

3. Mux2to1

A simple 2-to-1 multiplexer.

Outputs either input a or b based on the sel signal.

4. MuxNto1

A hierarchical N-to-1 multiplexer.

Uses smaller multiplexers to construct larger ones.

Efficiently selects one of N inputs based on the sel signal.

5. ControlLogic

Generates control signals for loading data.

Synchronizes operations with clock and enable signals.

6. RegisterFile

A parameterized register file supporting:

Addressable write and read operations.

M registers, each N bits wide.

Includes hierarchical multiplexing for read operations.

7. MetricsCalculator

Calculates resource utilization and performance metrics:

Total gates in flip-flops, registers, and multiplexers.

Write and read delays.

Overall critical path delay.

8. Testbench

Simulates the Register File operations.

Verifies functionality through test cases:

Writes data to registers.

Reads data back and checks for correctness.

Ensures isolation between registers.

Generates a clock signal and handles signal initialization.

Usage

Simulation

Use a Verilog simulator (e.g., ModelSim, Vivado) to simulate the code.

Run the testbench (Testbench module) to validate the functionality.

Observe the simulation outputs for correctness.

Parameters

N: Bit-width of each register (default: 8 bits).

M: Number of registers in the Register File (default: 4).

Expected Outputs

The simulation outputs for the test cases include:

Written data matches the read data for the specified addresses.

Registers maintain isolation, ensuring no unintended data overwrites.

Performance Metrics

Gate Count:

Flip-Flops: N x M

Registers: Flip-Flops x Gates per Flip-Flop

Multiplexers: N x M x Gates per bit

Delays:

Write Delay: Delay of a single D Flip-Flop.

Read Delay: Delay of an N-to-1 multiplexer.

Total Critical Path Delay: Sum of write and read delays.

Example Simulation Output

Metrics Report:
Resource Utilization:
  Total Flip-Flops: 32
  Total Gates in Registers: 192
  Total Gates in Multiplexers: 64
  Total Gates in Control Logic: 10
  Total Gates in Register File: 266

Delay Estimation:
  Write Delay (D Flip-Flop): 5 units
  Read Delay (Multiplexer): 12 units
  Total Critical Path Delay: 17 units

Test Case 1: Write to Register 0 and read it back
Expected: 00000101, Read: 00000101

Test Case 2: Write to Register 1 and read it back
Expected: 00001010, Read: 00001010

Test Case 3: Ensure Register 0 is unaffected
Expected: 00000101, Read: 00000101

Test Case 4: Write to Register 2 and verify isolation
Expected: 11110000, Read: 11110000

Test Case 5: Verify Register 1 is unaffected
Expected: 00001010, Read: 00001010

References

Digital Design and Computer Architecture by David Harris and Sarah Harris.

Verilog HDL documentation.


