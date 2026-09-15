//=============================================================================
// File Name:    mux2to1_9.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  9-bit 2-to-1 Multiplexer for pipeline control signal bubble injection.
//=============================================================================
`timescale 1ns / 1ps

module mux2to1_9 (
    input  wire [8:0] inA,
    input  wire [8:0] inB,
    input  wire       sel,
    output wire [8:0] out
);
    assign out = sel ? inB : inA;
endmodule
