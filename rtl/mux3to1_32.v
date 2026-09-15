//=============================================================================
// File Name:    mux3to1_32.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  32-bit 3-to-1 Multiplexer for operand forwarding bypass routing.
//=============================================================================
`timescale 1ns / 1ps

module mux3to1_32 (
    input  wire [31:0] a,    // Original register value from ID stage
    input  wire [31:0] b,    // Forwarded ALU result from MEM stage
    input  wire [31:0] c,    // Forwarded write-back data from WB stage
    input  wire [1:0]  sel,  // Forwarding select: 00=Reg, 01=MEM, 10=WB
    output reg  [31:0] out
);
    always @(*) begin
        case (sel)
            2'b00:   out = a;
            2'b01:   out = b;
            2'b10:   out = c;
            default: out = a;
        endcase
    end
endmodule
