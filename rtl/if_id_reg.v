//=============================================================================
// File Name:    if_id_reg.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  IF/ID Pipeline Register with freeze stall and branch flush support.
//=============================================================================
`timescale 1ns / 1ps

module if_id_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire        freeze,
    input  wire        flush,
    input  wire [31:0] pc_in,
    input  wire [31:0] instruction_in,
    output reg  [31:0] pc_out,
    output reg  [31:0] instruction_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out          <= 32'd0;
            instruction_out <= 32'd0;
        end else if (freeze) begin
            pc_out          <= pc_out;
            instruction_out <= instruction_out;
        end else if (flush) begin
            pc_out          <= 32'd0;
            instruction_out <= 32'd0;
        end else begin
            pc_out          <= pc_in;
            instruction_out <= instruction_in;
        end
    end
endmodule
