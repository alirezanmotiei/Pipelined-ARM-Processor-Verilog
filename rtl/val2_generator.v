//=============================================================================
// File Name:    val2_generator.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  Generates ALU second operand (32-bit rotated immediate, immediate shift, register shift).
//=============================================================================
`timescale 1ns / 1ps

module val2_generator (
    input  wire [31:0] val_rm,
    input  wire [11:0] shift_operand,
    input  wire        imm,
    input  wire        mem_inst, // Asserted for LDR / STR
    output reg  [31:0] val2
);
    wire [63:0] temp_rotate = {24'b0, shift_operand[7:0], 24'b0, shift_operand[7:0]};
    wire [63:0] temp_rm     = {val_rm, val_rm};

    always @(*) begin
        if (mem_inst) begin
            // Memory offset: 12-bit immediate zero-extended
            val2 = {20'b0, shift_operand};
        end else if (imm) begin
            // 32-bit immediate: rotate 8-bit immediate right by 2 * rotate_imm
            val2 = temp_rotate[31 + (shift_operand[11:8] << 1) -: 32];
        end else begin
            // Register shifted operand
            case (shift_operand[6:5])
                2'b00: val2 = val_rm << shift_operand[11:7];               // LSL
                2'b01: val2 = val_rm >> shift_operand[11:7];               // LSR
                2'b10: val2 = $signed(val_rm) >>> shift_operand[11:7];      // ASR
                2'b11: val2 = temp_rm[31 + shift_operand[11:7] -: 32];     // ROR
                default: val2 = val_rm;
            endcase
        end
    end
endmodule
