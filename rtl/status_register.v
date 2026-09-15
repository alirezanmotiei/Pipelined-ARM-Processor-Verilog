//=============================================================================
// File Name:    status_register.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  4-bit Status Register storing architectural flags (N, Z, C, V).
//=============================================================================
`timescale 1ns / 1ps

module status_register (
    input  wire       clk,
    input  wire       rst,
    input  wire       s_en,
    input  wire [3:0] status_in,   // [Z, C, N, V]
    output reg  [3:0] status_out
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            status_out <= 4'd0;
        else if (s_en)
            status_out <= status_in;
    end
endmodule
