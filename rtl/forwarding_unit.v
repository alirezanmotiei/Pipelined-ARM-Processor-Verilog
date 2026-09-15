//=============================================================================
// File Name:    forwarding_unit.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  Dynamic Operand Forwarding Unit resolving RAW dependencies from MEM and WB stages.
//=============================================================================
`timescale 1ns / 1ps

module forwarding_unit (
    input  wire       forwarding_en,
    input  wire [3:0] src1,
    input  wire [3:0] src2,
    input  wire       wb_en_mem,
    input  wire [3:0] dest_mem,
    input  wire       wb_en_wb,
    input  wire [3:0] dest_wb,
    output reg  [1:0] sel_src1,
    output reg  [1:0] sel_src2
);
    always @(*) begin
        sel_src1 = 2'b00;
        sel_src2 = 2'b00;

        if (forwarding_en) begin
            // Forwarding priority: MEM stage takes precedence over WB stage (more recent)
            if (wb_en_mem && (dest_mem == src1))
                sel_src1 = 2'b01; // Forward from MEM stage
            else if (wb_en_wb && (dest_wb == src1))
                sel_src1 = 2'b10; // Forward from WB stage

            if (wb_en_mem && (dest_mem == src2))
                sel_src2 = 2'b01; // Forward from MEM stage
            else if (wb_en_wb && (dest_wb == src2))
                sel_src2 = 2'b10; // Forward from WB stage
        end
    end
endmodule
