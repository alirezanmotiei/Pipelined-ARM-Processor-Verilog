//=============================================================================
// File Name:    ex_stage.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  Execution stage: ALU, Val2 generator, branch adder, Status Register.
//=============================================================================
`timescale 1ns / 1ps

module ex_stage (
    input  wire        clk,
    input  wire        rst,
    input  wire [3:0]  exe_cmd,
    input  wire        mem_r_en,
    input  wire        mem_w_en,
    input  wire [31:0] pc,
    input  wire [31:0] val_rn,
    input  wire [31:0] val_rm,
    input  wire        imm,
    input  wire [11:0] shift_operand,
    input  wire [31:0] signed_imm_24,
    input  wire        s,
    input  wire [3:0]  sr,

    output wire [31:0] alu_result,
    output wire [31:0] branch_addr,
    output wire [3:0]  status_out
);
    wire is_mem_inst = mem_r_en | mem_w_en;
    wire [31:0] val2;
    wire n, z, c, v;

    val2_generator val2_gen (
        .val_rm(val_rm),
        .shift_operand(shift_operand),
        .imm(imm),
        .mem_inst(is_mem_inst),
        .val2(val2)
    );

    alu execution_alu (
        .exe_cmd(exe_cmd),
        .val1(val_rn),
        .val2(val2),
        .cin(sr[2]), // C flag
        .alu_res(alu_result),
        .c(c),
        .n(n),
        .z(z),
        .v(v)
    );

    adder branch_target_adder (
        .inA(pc),
        .inB(signed_imm_24),
        .out(branch_addr)
    );

    status_register sr_inst (
        .clk(clk),
        .rst(rst),
        .s_en(s),
        .status_in({z, c, n, v}),
        .status_out(status_out)
    );
endmodule
