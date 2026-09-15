//=============================================================================
// File Name:    pc.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  32-bit Program Counter register with synchronous freeze and asynchronous reset.
//=============================================================================
`timescale 1ns / 1ps

module pc (
    input  wire        clk,
    input  wire        rst,
    input  wire        freeze,
    input  wire [31:0] pc_in,
    output reg  [31:0] pc_out
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc_out <= 32'd0;
        else if (!freeze)
            pc_out <= pc_in;
    end
endmodule
