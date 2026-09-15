//=============================================================================
// File Name:    mux2to1_4.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  4-bit 2-to-1 Multiplexer for register address selection.
//=============================================================================
`timescale 1ns / 1ps

module mux2to1_4 (
    input  wire [3:0] inA,
    input  wire [3:0] inB,
    input  wire       sel,
    output wire [3:0] out
);
    assign out = sel ? inB : inA;
endmodule
