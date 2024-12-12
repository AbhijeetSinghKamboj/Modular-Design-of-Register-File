module DFlipFlop (
    input wire D,        // Data input
    input wire clk,      // Clock signal
    input wire reset,    // Asynchronous reset
    output reg Q         // Output
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            Q <= 1'b0;   // Clear output on reset
        else
            Q <= D;      // Capture data on clock rising edge
    end
endmodule

module MultiBitRegister #(parameter N = 8) (
    input wire [N-1:0] D,           // Data input
    input wire clk,                // Clock signal
    input wire reset,              // Asynchronous reset
    input wire write_enable,       // Write enable signal
    output reg [N-1:0] Q           // Output
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            Q <= 0;                // Clear register on reset
        else if (write_enable)
            Q <= D;                // Write data on write enable
    end
endmodule

module Mux2to1 (
    input wire a,              // First input
    input wire b,              // Second input
    input wire sel,            // Select signal
    output wire out            // Output
);
    assign out = sel ? b : a;
endmodule

module MuxNto1 #(parameter N = 4) (
    input wire [N-1:0] in,           // N inputs
    input wire [$clog2(N)-1:0] sel,  // Select signal, log2(N) bits
    output wire out                  // Output
);

    generate
        if (N == 2) begin
            Mux2to1 mux (
                .a(in[0]),
                .b(in[1]),
                .sel(sel[0]),
                .out(out)
            );
        end else begin
            wire upper_out, lower_out;

            // Lower half multiplexer
            MuxNto1 #(N/2) lower_mux (
                .in(in[N/2-1:0]),
                .sel(sel[$clog2(N)-2:0]),
                .out(lower_out)
            );

            // Upper half multiplexer
            MuxNto1 #(N/2) upper_mux (
                .in(in[N-1:N/2]),
                .sel(sel[$clog2(N)-2:0]),
                .out(upper_out)
            );

            // Final 2:1 mux
            Mux2to1 final_mux (
                .a(lower_out),
                .b(upper_out),
                .sel(sel[$clog2(N)-1]),
                .out(out)
            );
        end
    endgenerate
endmodule

module ControlLogic(
    input wire clk,                // Clock signal
    input wire enable,             // Enable signal for synchronization
    input wire load,               // Parallel load control
    output reg load_data           // Load operation active
);
    always @(posedge clk) begin
        if (enable) begin
            load_data <= load;     // Reflect load signal when enabled
        end else begin
            load_data <= 0;        // Default to no load
        end
    end
endmodule

// RegisterFile Module
module RegisterFile #(parameter N = 8, M = 4) (
    input wire clk,                     // Clock signal
    input wire reset,                   // Asynchronous reset
    input wire [N-1:0] write_data,      // Data to write to a register
    input wire [$clog2(M)-1:0] write_addr, // Address of the register to write
    input wire [$clog2(M)-1:0] read_addr,  // Address of the register to read
    input wire write_enable,            // Write enable signal
    output wire [N-1:0] read_data       // Data read from the selected register
);

    // Array of registers
    wire [N-1:0] register_outputs [0:M-1]; // Outputs of each register
    wire [M-1:0] write_enables;           // Write enable signals for each register

    // Generate write enable signals for each register
    genvar i;
    generate
        for (i = 0; i < M; i = i + 1) begin : generate_registers
            assign write_enables[i] = write_enable && (write_addr == i);

            // Instantiate individual registers
            MultiBitRegister #(N) reg_inst (
                .D(write_data),
                .clk(clk),
                .reset(reset),
                .write_enable(write_enables[i]),
                .Q(register_outputs[i])
            );
        end
    endgenerate

    // Read data from the selected register
    assign read_data = register_outputs[read_addr];
endmodule

// Performance metrics
module MetricsCalculator;
    parameter N = 8;  // Bit width of each register
    parameter M = 4;  // Number of registers in the Register File

    // Constants for gate count estimation
    localparam DFF_GATES = 6;            // Gates per D Flip-Flop
    localparam MUX2TO1_GATES = 2;        // Gates per bit in a 2-to-1 multiplexer
    localparam CONTROL_LOGIC_GATES = 10; // Approximate gates for control logic

    // Constants for delay estimation
    localparam NOT_DELAY = 1;            // Delay for NOT gate
    localparam AND_DELAY = 2;            // Delay for AND gate
    localparam OR_DELAY = 2;             // Delay for OR gate
    localparam DFF_DELAY = 5;            // Delay for a D Flip-Flop
    localparam MUX_LEVEL_DELAY = 6;      // Delay per level in an N-to-1 multiplexer

    // Gate count variables
    integer total_dffs, register_gates, mux_gates, control_gates, total_gates;

    // Delay variables
    integer write_delay, read_delay, total_delay;

    initial begin
        // **Gate Count Calculation**

        // Flip-Flops: N bits per register × M registers
        total_dffs = N * M;

        // Registers: Flip-Flop gates
        register_gates = total_dffs * DFF_GATES;

        // Multiplexers: Each bit requires log2(M) levels of multiplexers
        mux_gates = N * (M * MUX2TO1_GATES);

        // Control logic gates
        control_gates = CONTROL_LOGIC_GATES;

        // Total gate count
        total_gates = register_gates + mux_gates + control_gates;

        $display("\nMetrics Report:");
        $display("Resource Utilization:");
        $display("  Total Flip-Flops: %d", total_dffs);
        $display("  Total Gates in Registers: %d", register_gates);
        $display("  Total Gates in Multiplexers: %d", mux_gates);
        $display("  Total Gates in Control Logic: %d", control_gates);
        $display("  Total Gates in Register File: %d", total_gates);

        // **Delay Estimation**

        // Write delay: Critical path for a single D Flip-Flop
        write_delay = DFF_DELAY;

        // Read delay: Critical path for a multiplexer with log2(M) levels
        read_delay = MUX_LEVEL_DELAY * $clog2(M);

        // Total critical path delay
        total_delay = write_delay + read_delay;

        $display("\nDelay Estimation:");
        $display("  Write Delay (D Flip-Flop): %d units", write_delay);
        $display("  Read Delay (Multiplexer): %d units", read_delay);
        $display("  Total Critical Path Delay: %d units", total_delay);
    end
endmodule


// Testbench Module
module Testbench;
    parameter N = 8;
    parameter M = 4;

    reg clk;
    reg reset;
    reg [N-1:0] write_data;
    reg [$clog2(M)-1:0] write_addr;
    reg [$clog2(M)-1:0] read_addr;
    reg write_enable;
    wire [N-1:0] read_data;

    // Instantiate the RegisterFile module
    RegisterFile #(N, M) rf (
        .clk(clk),
        .reset(reset),
        .write_data(write_data),
        .write_addr(write_addr),
        .read_addr(read_addr),
        .write_enable(write_enable),
        .read_data(read_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units clock period
    end

    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        write_enable = 0;
        write_data = 0;
        write_addr = 0;
        read_addr = 0;

        // Hold reset for 10 time units
        #10 reset = 0; // Release reset

        // Test Case 1: Write to Register 0 and read it back
        $display("\nTest Case 1: Write to Register 0 and read it back");
        write_enable = 1;
        write_addr = 2'b00;
        write_data = 8'b00000101; // Write 5 to Register 0
        #10;
        write_enable = 0;
        read_addr = 2'b00; // Read from Register 0
        #10 $display("Expected: 00000101, Read: %b", read_data);

        // Test Case 2: Write to Register 1 and read it back
        $display("\nTest Case 2: Write to Register 1 and read it back");
        write_enable = 1;
        write_addr = 2'b01;
        write_data = 8'b00001010; // Write 10 to Register 1
        #10;
        write_enable = 0;
        read_addr = 2'b01; // Read from Register 1
        #10 $display("Expected: 00001010, Read: %b", read_data);

        // Test Case 3: Ensure Register 0 is unaffected
        $display("\nTest Case 3: Ensure Register 0 is unaffected");
        read_addr = 2'b00; // Read from Register 0
        #10 $display("Expected: 00000101, Read: %b", read_data);

        // Test Case 4: Write to Register 2 and verify isolation
        $display("\nTest Case 4: Write to Register 2 and verify isolation");
        write_enable = 1;
        write_addr = 2'b10;
        write_data = 8'b11110000; // Write 240 to Register 2
        #10;
        write_enable = 0;
        read_addr = 2'b10; // Read from Register 2
        #10 $display("Expected: 11110000, Read: %b", read_data);

        // Test Case 5: Verify Register 1 is unaffected
        $display("\nTest Case 5: Verify Register 1 is unaffected");
        read_addr = 2'b01; // Read from Register 1
        #10 $display("Expected: 00001010, Read: %b", read_data);

        // End simulation
        $finish;
    end
endmodule
