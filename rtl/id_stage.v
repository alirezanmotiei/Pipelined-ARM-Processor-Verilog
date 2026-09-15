//=============================================================================
// File Name:    id_stage.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  Instruction Decode stage: Controller, Register File, Condition Evaluator.
//=============================================================================
`timescale 1ns / 1ps

module id_stage (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] instruction,
    input  wire [31:0] result_wb,
    input  wire        write_back_en,
    input  wire [3:0]  dest_wb,
    input  wire        hazard,
    input  wire [3:0]  sr,

    output wire        wb_en,
    output wire        mem_r_en,
    output wire        mem_w_en,
    output wire        b,
    output wire        s,
    output wire [3:0]  exe_cmd,
    output wire [31:0] val_rn,
    output wire [31:0] val_rm,
    output wire        imm,
    output wire [11:0] shift_operand,
    output wire [23:0] signed_imm_24,
    output wire [3:0]  dest,
    output wire [3:0]  src1,
    output wire [3:0]  src2,
    output wire        two_src
);
    wire cond_met;
    wire sel_bubble_mux;
    wire [3:0] src2_mux_out;
    wire [8:0] ct_signals_out;
    wire [8:0] bubble_mux_out;
    wire ct_wb_en, ct_mem_r_en, ct_mem_w_en, ct_b, ct_s;
    wire [3:0] ct_exe_cmd;

    assign ct_signals_out = {ct_wb_en, ct_mem_r_en, ct_mem_w_en, ct_b, ct_s, ct_exe_cmd};

    // Determine two-source requirement: register operand (I=0) or store instruction (STR)
    assign two_src = (~instruction[25]) | ct_mem_w_en;

    // Condition check
    condition_check cond_checker (
        .cond(instruction[31:28]),
        .status(sr),
        .cond_met(cond_met)
    );

    // Bubble injection multiplexer selector
    assign sel_bubble_mux = (~cond_met) | hazard;

    // For STR, source 2 is Rd (instruction[15:12]); for DP, source 2 is Rm (instruction[3:0])
    mux2to1_4 src2_selector (
        .inA(instruction[3:0]),
        .inB(instruction[15:12]),
        .sel(ct_mem_w_en),
        .out(src2_mux_out)
    );

    // Bubble multiplexer: injects zero control signals on condition failure or hazard stall
    mux2to1_9 control_bubble_mux (
        .inA(ct_signals_out),
        .inB(9'd0),
        .sel(sel_bubble_mux),
        .out(bubble_mux_out)
    );

    // Register File instantiation
    register_file reg_file (
        .clk(clk),
        .rst(rst),
        .src1(instruction[19:16]),
        .src2(src2_mux_out),
        .dest_wb(dest_wb),
        .result_wb(result_wb),
        .write_back_en(write_back_en),
        .reg1(val_rn),
        .reg2(val_rm)
    );

    // Controller
    controller main_ctrl (
        .cond(instruction[31:28]),
        .mode(instruction[27:26]),
        .opcode(instruction[24:21]),
        .s_in(instruction[20]),
        .wb_en(ct_wb_en),
        .mem_r_en(ct_mem_r_en),
        .mem_w_en(ct_mem_w_en),
        .exe_cmd(ct_exe_cmd),
        .b(ct_b),
        .s_out(ct_s)
    );

    // Outputs from bubble multiplexer
    assign wb_en         = bubble_mux_out[8];
    assign mem_r_en      = bubble_mux_out[7];
    assign mem_w_en      = bubble_mux_out[6];
    assign b             = bubble_mux_out[5];
    assign s             = bubble_mux_out[4];
    assign exe_cmd       = bubble_mux_out[3:0];

    assign signed_imm_24 = instruction[23:0];
    assign shift_operand = instruction[11:0];
    assign imm           = instruction[25];
    assign dest          = instruction[15:12];
    assign src1          = instruction[19:16];
    assign src2          = src2_mux_out;
endmodule
