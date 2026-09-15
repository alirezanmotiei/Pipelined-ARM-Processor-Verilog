//=============================================================================
// File Name:    mem_wb_reg.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  MEM/WB Pipeline Register holding ALU results and memory read values for write-back.
//=============================================================================
`timescale 1ns / 1ps

module mem_wb_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire        freeze,
    input  wire        wb_en_in,
    input  wire        mem_r_en_in,
    input  wire [31:0] alu_result_in,
    input  wire [31:0] mem_read_val_in,
    input  wire [3:0]  dest_in,

    output reg         wb_en_out,
    output reg         mem_r_en_out,
    output reg  [31:0] alu_result_out,
    output reg  [31:0] mem_read_val_out,
    output reg  [3:0]  dest_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wb_en_out        <= 1'b0;
            mem_r_en_out     <= 1'b0;
            alu_result_out   <= 32'd0;
            mem_read_val_out <= 32'd0;
            dest_out         <= 4'd0;
        end else if (!freeze) begin
            wb_en_out        <= wb_en_in;
            mem_r_en_out     <= mem_r_en_in;
            alu_result_out   <= alu_result_in;
            mem_read_val_out <= mem_read_val_in;
            dest_out         <= dest_in;
        end
    end
endmodule
