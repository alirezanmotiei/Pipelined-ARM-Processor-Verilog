//=============================================================================
// File Name:    id_ex_reg.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  ID/EX Pipeline Register with freeze, flush, and operand forwarding tracking.
//=============================================================================
`timescale 1ns / 1ps

module id_ex_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire        freeze,
    input  wire        flush,
    input  wire        wb_en_in,
    input  wire        mem_r_en_in,
    input  wire        mem_w_en_in,
    input  wire        b_in,
    input  wire        s_in,
    input  wire        imm_in,
    input  wire [3:0]  exe_cmd_in,
    input  wire [31:0] pc_in,
    input  wire [31:0] val_rn_in,
    input  wire [31:0] val_rm_in,
    input  wire [11:0] shift_operand_in,
    input  wire [23:0] signed_imm_24_in,
    input  wire [3:0]  dest_in,
    input  wire [3:0]  sr_in,
    input  wire [3:0]  src1_in,
    input  wire [3:0]  src2_in,

    output reg         wb_en_out,
    output reg         mem_r_en_out,
    output reg         mem_w_en_out,
    output reg         b_out,
    output reg         s_out,
    output reg         imm_out,
    output reg  [3:0]  exe_cmd_out,
    output reg  [31:0] pc_out,
    output reg  [31:0] val_rn_out,
    output reg  [31:0] val_rm_out,
    output reg  [11:0] shift_operand_out,
    output reg  [31:0] signed_imm_24_out,
    output reg  [3:0]  dest_out,
    output reg  [3:0]  sr_out,
    output reg  [3:0]  src1_out,
    output reg  [3:0]  src2_out
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            wb_en_out          <= 1'b0;
            mem_r_en_out       <= 1'b0;
            mem_w_en_out       <= 1'b0;
            b_out              <= 1'b0;
            s_out              <= 1'b0;
            imm_out            <= 1'b0;
            exe_cmd_out        <= 4'd0;
            dest_out           <= 4'd0;
            shift_operand_out  <= 12'd0;
            signed_imm_24_out  <= 32'd0;
            pc_out             <= 32'd0;
            val_rn_out         <= 32'd0;
            val_rm_out         <= 32'd0;
            sr_out             <= 4'd0;
            src1_out           <= 4'd0;
            src2_out           <= 4'd0;
        end else if (!freeze) begin
            wb_en_out          <= wb_en_in;
            mem_r_en_out       <= mem_r_en_in;
            mem_w_en_out       <= mem_w_en_in;
            b_out              <= b_in;
            s_out              <= s_in;
            imm_out            <= imm_in;
            exe_cmd_out        <= exe_cmd_in;
            dest_out           <= dest_in;
            shift_operand_out  <= shift_operand_in;
            signed_imm_24_out  <= {{8{signed_imm_24_in[23]}}, signed_imm_24_in};
            pc_out             <= pc_in;
            val_rn_out         <= val_rn_in;
            val_rm_out         <= val_rm_in;
            sr_out             <= sr_in;
            src1_out           <= src1_in;
            src2_out           <= src2_in;
        end
    end
endmodule
