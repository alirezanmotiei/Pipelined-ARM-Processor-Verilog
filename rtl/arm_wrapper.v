//=============================================================================
// File Name:    arm_wrapper.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  Top-level wrapper module for synthesis on Xilinx Zynq-7000 FPGA board.
//=============================================================================
`timescale 1ns / 1ps

module arm_wrapper (
    input wire clk,
    input wire key_reset
);
    wire debounced_key;
    wire rst;
    wire forwarding_enable = 1'b1;

    debouncer #(65536) rst_debouncer (
        .clk(clk),
        .signal_in(key_reset),
        .signal_out(debounced_key)
    );

    assign rst = ~debounced_key;

    // Embedded Instruction Memory & SRAM
    wire [31:0] instruction;
    wire [31:0] pc;
    wire [10:0] sram_addr;
    wire [7:0]  sram_data;
    wire        sram_cs_n, sram_oe_n, sram_we_n;

    arm_core core_inst (
        .clk(clk),
        .rst(rst),
        .forwarding_en(forwarding_enable),
        .instruction_in(instruction),
        .pc_out(pc),
        .sram_addr(sram_addr),
        .sram_data(sram_data),
        .sram_cs_n(sram_cs_n),
        .sram_oe_n(sram_oe_n),
        .sram_we_n(sram_we_n)
    );

    sram_model sram_chip (
        .clk(clk),
        .Address(sram_addr),
        .DataIO(sram_data),
        .CS_n(sram_cs_n),
        .OE_n(sram_oe_n),
        .WE_n(sram_we_n)
    );
endmodule
