//=============================================================================
// File Name:    adder.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  32-bit arithmetic adder for PC increment and branch target calculation.
//=============================================================================
`timescale 1ns / 1ps

module adder (
    input  wire [31:0] inA,
    input  wire [31:0] inB,
    output wire [31:0] out
);
    assign out = inA + inB;
endmodule
