//=============================================================================
// File Name:    hazard_unit.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  RAW Data Hazard Detection and Load-Use Pipeline Stall Unit.
//=============================================================================
`timescale 1ns / 1ps

module hazard_unit (
    input  wire [3:0] src1,
    input  wire [3:0] src2,
    input  wire       two_src,
    input  wire       exe_wb_en,
    input  wire [3:0] exe_dest,
    input  wire       mem_wb_en,
    input  wire [3:0] mem_dest,
    input  wire       exe_mem_r_en,
    input  wire       forwarding_en,
    output reg        hazard_detected
);
    always @(*) begin
        hazard_detected = 1'b0;

        if (forwarding_en) begin
            // Forwarding enabled: Only Load-Use hazard requires stalling
            if (exe_mem_r_en && exe_wb_en) begin
                if (src1 == exe_dest)
                    hazard_detected = 1'b1;
                if (two_src && (src2 == exe_dest))
                    hazard_detected = 1'b1;
            end
        end else begin
            // Forwarding disabled: Stall on any RAW hazard with EXE or MEM stages
            if (exe_wb_en && (src1 == exe_dest || (two_src && src2 == exe_dest)))
                hazard_detected = 1'b1;
            if (mem_wb_en && (src1 == mem_dest || (two_src && src2 == mem_dest)))
                hazard_detected = 1'b1;
        end
    end
endmodule
