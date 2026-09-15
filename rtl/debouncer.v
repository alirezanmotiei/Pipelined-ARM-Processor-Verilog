//=============================================================================
// File Name:    debouncer.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  Digital pushbutton debouncer filter for reliable FPGA clocking and reset.
//=============================================================================
`timescale 1ns / 1ps

module debouncer #(
    parameter CLK_CYCLES = 65536
)(
    input  wire clk,
    input  wire signal_in,
    output reg  signal_out
);
    reg [$clog2(CLK_CYCLES)-1:0] counter = 0;
    reg signal_sync = 0;

    always @(posedge clk) begin
        if (signal_in != signal_sync) begin
            signal_sync <= signal_in;
            counter     <= 0;
        end else if (counter < CLK_CYCLES - 1) begin
            counter <= counter + 1'b1;
        end else begin
            signal_out <= signal_sync;
        end
    end
endmodule
