//=============================================================================
// File Name:    mux2to1.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  Parameterized 2-to-1 Multiplexer (default 32-bit width).
//=============================================================================
`timescale 1ns / 1ps

module mux2to1 #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] inA,
    input  wire [WIDTH-1:0] inB,
    input  wire             sel,
    output wire [WIDTH-1:0] out
);
    assign out = sel ? inB : inA;
endmodule
