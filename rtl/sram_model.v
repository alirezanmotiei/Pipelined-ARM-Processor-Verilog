//=============================================================================
// File Name:    sram_model.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  Behavioral 2048 x 8-bit SRAM with synchronous 1-cycle read latency.
//=============================================================================
`timescale 1ns / 1ps

module sram_model (
    input  wire        clk,
    input  wire [10:0] Address,
    inout  wire [7:0]  DataIO,
    input  wire        CS_n,
    input  wire        OE_n,
    input  wire        WE_n
);
    reg [7:0] memory [0:2047];
    reg [7:0] read_buffer;
    integer i;

    initial begin
        for (i = 0; i < 2048; i = i + 1)
            memory[i] = 8'd0;
    end

    // Synchronous write and read
    always @(posedge clk) begin
        if (!CS_n) begin
            if (!WE_n)
                memory[Address] <= DataIO;
            read_buffer <= memory[Address];
        end
    end

    assign DataIO = (!CS_n && !OE_n && WE_n) ? read_buffer : 8'bz;
endmodule
