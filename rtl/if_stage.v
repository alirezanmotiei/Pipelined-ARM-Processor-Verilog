//=============================================================================
// File Name:    if_stage.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  Instruction Fetch stage: PC generation, branch multiplexing, and PC+1 adder.
//=============================================================================
`timescale 1ns / 1ps

module if_stage (
    input  wire        clk,
    input  wire        rst,
    input  wire        freeze,
    input  wire        branch_taken,
    input  wire [31:0] branch_addr,
    output wire [31:0] pc_current,
    output wire [31:0] pc_plus_1
);
    wire [31:0] next_pc;

    adder pc_adder (
        .inA(pc_current),
        .inB(32'd1),
        .out(pc_plus_1)
    );

    mux2to1 #(32) pc_mux (
        .inA(pc_plus_1),
        .inB(branch_addr),
        .sel(branch_taken),
        .out(next_pc)
    );

    pc pc_register (
        .clk(clk),
        .rst(rst),
        .freeze(freeze),
        .pc_in(next_pc),
        .pc_out(pc_current)
    );
endmodule
