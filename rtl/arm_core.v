//=============================================================================
// File Name:    arm_core.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  Top-level 5-Stage Pipelined ARM Core integrating Forwarding, Hazard, and SRAM.
//=============================================================================
`timescale 1ns / 1ps

module arm_core (
    input  wire        clk,
    input  wire        rst,
    input  wire        forwarding_en,
    input  wire [31:0] instruction_in,
    output wire [31:0] pc_out,

    // SRAM Bus Interface
    output wire [10:0] sram_addr,
    inout  wire [7:0]  sram_data,
    output wire        sram_cs_n,
    output wire        sram_oe_n,
    output wire        sram_we_n
);
    // Pipeline control wires
    wire branch_taken;
    wire [31:0] branch_addr_exe;
    wire [31:0] pc_current_if;
    wire [31:0] pc_plus_1_if;
    wire [31:0] pc_id;
    wire [31:0] instruction_id;

    wire hazard_stall;
    wire sram_ready;
    wire system_freeze = hazard_stall | (~sram_ready);
    wire freeze_all_stages = ~sram_ready;

    assign pc_out = pc_current_if;

    //-------------------------------------------------------------------------
    // 1. Instruction Fetch (IF) Stage
    //-------------------------------------------------------------------------
    if_stage if_stage_inst (
        .clk(clk),
        .rst(rst),
        .freeze(system_freeze),
        .branch_taken(branch_taken),
        .branch_addr(branch_addr_exe),
        .pc_current(pc_current_if),
        .pc_plus_1(pc_plus_1_if)
    );

    if_id_reg if_id_reg_inst (
        .clk(clk),
        .rst(rst),
        .freeze(system_freeze),
        .flush(branch_taken),
        .pc_in(pc_plus_1_if),
        .instruction_in(instruction_in),
        .pc_out(pc_id),
        .instruction_out(instruction_id)
    );

    //-------------------------------------------------------------------------
    // 2. Instruction Decode (ID) Stage
    //-------------------------------------------------------------------------
    wire wb_en_id, mem_r_en_id, mem_w_en_id, b_id, s_id, imm_id, two_src_id;
    wire [3:0] exe_cmd_id, dest_id, src1_id, src2_id;
    wire [31:0] val_rn_id, val_rm_id;
    wire [11:0] shift_operand_id;
    wire [23:0] signed_imm_24_id;
    wire [3:0] status_flags_exe;

    wire [31:0] wb_result_mux;
    wire wb_en_mem_wb;
    wire [3:0] dest_mem_wb;

    id_stage id_stage_inst (
        .clk(clk),
        .rst(rst),
        .instruction(instruction_id),
        .result_wb(wb_result_mux),
        .write_back_en(wb_en_mem_wb),
        .dest_wb(dest_mem_wb),
        .hazard(system_freeze),
        .sr(status_flags_exe),
        .wb_en(wb_en_id),
        .mem_r_en(mem_r_en_id),
        .mem_w_en(mem_w_en_id),
        .b(b_id),
        .s(s_id),
        .exe_cmd(exe_cmd_id),
        .val_rn(val_rn_id),
        .val_rm(val_rm_id),
        .imm(imm_id),
        .shift_operand(shift_operand_id),
        .signed_imm_24(signed_imm_24_id),
        .dest(dest_id),
        .src1(src1_id),
        .src2(src2_id),
        .two_src(two_src_id)
    );

    // ID/EX Pipeline Register
    wire wb_en_ex, mem_r_en_ex, mem_w_en_ex, b_ex, s_ex, imm_ex;
    wire [3:0] exe_cmd_ex, dest_ex, sr_ex, src1_ex, src2_ex;
    wire [31:0] pc_ex, val_rn_ex, val_rm_ex, signed_imm_24_ex;
    wire [11:0] shift_operand_ex;

    assign branch_taken = b_ex;

    id_ex_reg id_ex_reg_inst (
        .clk(clk),
        .rst(rst),
        .freeze(freeze_all_stages),
        .flush(branch_taken),
        .wb_en_in(wb_en_id),
        .mem_r_en_in(mem_r_en_id),
        .mem_w_en_in(mem_w_en_id),
        .b_in(b_id),
        .s_in(s_id),
        .imm_in(imm_id),
        .exe_cmd_in(exe_cmd_id),
        .pc_in(pc_id),
        .val_rn_in(val_rn_id),
        .val_rm_in(val_rm_id),
        .shift_operand_in(shift_operand_id),
        .signed_imm_24_in(signed_imm_24_id),
        .dest_in(dest_id),
        .sr_in(status_flags_exe),
        .src1_in(src1_id),
        .src2_in(src2_id),
        .wb_en_out(wb_en_ex),
        .mem_r_en_out(mem_r_en_ex),
        .mem_w_en_out(mem_w_en_ex),
        .b_out(b_ex),
        .s_out(s_ex),
        .imm_out(imm_ex),
        .exe_cmd_out(exe_cmd_ex),
        .pc_out(pc_ex),
        .val_rn_out(val_rn_ex),
        .val_rm_out(val_rm_ex),
        .shift_operand_out(shift_operand_ex),
        .signed_imm_24_out(signed_imm_24_ex),
        .dest_out(dest_ex),
        .sr_out(sr_ex),
        .src1_out(src1_ex),
        .src2_out(src2_ex)
    );

    //-------------------------------------------------------------------------
    // 3. Execution (EX) Stage & Forwarding Multiplexers
    //-------------------------------------------------------------------------
    wire [1:0] sel_fwd_src1, sel_fwd_src2;
    wire [31:0] alu_result_mem;
    wire [31:0] val1_fwd, val2_fwd;
    wire [31:0] alu_result_ex;

    mux3to1_32 fwd_mux1 (
        .a(val_rn_ex),
        .b(alu_result_mem),
        .c(wb_result_mux),
        .sel(sel_fwd_src1),
        .out(val1_fwd)
    );

    mux3to1_32 fwd_mux2 (
        .a(val_rm_ex),
        .b(alu_result_mem),
        .c(wb_result_mux),
        .sel(sel_fwd_src2),
        .out(val2_fwd)
    );

    ex_stage ex_stage_inst (
        .clk(clk),
        .rst(rst),
        .exe_cmd(exe_cmd_ex),
        .mem_r_en(mem_r_en_ex),
        .mem_w_en(mem_w_en_ex),
        .pc(pc_ex),
        .val_rn(val1_fwd),
        .val_rm(val2_fwd),
        .imm(imm_ex),
        .shift_operand(shift_operand_ex),
        .signed_imm_24(signed_imm_24_ex),
        .s(s_ex),
        .sr(sr_ex),
        .alu_result(alu_result_ex),
        .branch_addr(branch_addr_exe),
        .status_out(status_flags_exe)
    );

    // EX/MEM Pipeline Register
    wire wb_en_mem, mem_r_en_mem, mem_w_en_mem;
    wire [3:0] dest_mem, sr_val_mem;
    wire [31:0] val_rm_mem;

    ex_mem_reg ex_mem_reg_inst (
        .clk(clk),
        .rst(rst),
        .freeze(freeze_all_stages),
        .wb_en_in(wb_en_ex),
        .mem_r_en_in(mem_r_en_ex),
        .mem_w_en_in(mem_w_en_ex),
        .alu_result_in(alu_result_ex),
        .sr_val_in(sr_ex),
        .dest_in(dest_ex),
        .val_rm_in(val2_fwd),
        .wb_en_out(wb_en_mem),
        .mem_r_en_out(mem_r_en_mem),
        .mem_w_en_out(mem_w_en_mem),
        .alu_result_out(alu_result_mem),
        .sr_val_out(sr_val_mem),
        .dest_out(dest_mem),
        .val_rm_out(val_rm_mem)
    );

    //-------------------------------------------------------------------------
    // 4. Memory (MEM) Stage & SRAM Controller
    //-------------------------------------------------------------------------
    wire [31:0] sram_rdata_mem;

    sram_controller sram_ctrl (
        .clk(clk),
        .rst(rst),
        .cpu_addr(alu_result_mem),
        .cpu_wdata(val_rm_mem),
        .cpu_mem_read(mem_r_en_mem),
        .cpu_mem_write(mem_w_en_mem),
        .cpu_rdata(sram_rdata_mem),
        .cpu_ready(sram_ready),
        .sram_addr(sram_addr),
        .sram_data(sram_data),
        .sram_cs_n(sram_cs_n),
        .sram_oe_n(sram_oe_n),
        .sram_we_n(sram_we_n)
    );

    // MEM/WB Pipeline Register
    wire mem_r_en_wb;
    wire [31:0] alu_result_wb, mem_read_val_wb;

    mem_wb_reg mem_wb_reg_inst (
        .clk(clk),
        .rst(rst),
        .freeze(freeze_all_stages),
        .wb_en_in(wb_en_mem),
        .mem_r_en_in(mem_r_en_mem),
        .alu_result_in(alu_result_mem),
        .mem_read_val_in(sram_rdata_mem),
        .dest_in(dest_mem),
        .wb_en_out(wb_en_mem_wb),
        .mem_r_en_out(mem_r_en_wb),
        .alu_result_out(alu_result_wb),
        .mem_read_val_out(mem_read_val_wb),
        .dest_out(dest_mem_wb)
    );

    //-------------------------------------------------------------------------
    // 5. Write-Back (WB) Stage
    //-------------------------------------------------------------------------
    mux2to1 #(32) wb_mux (
        .inA(alu_result_wb),
        .inB(mem_read_val_wb),
        .sel(mem_r_en_wb),
        .out(wb_result_mux)
    );

    //-------------------------------------------------------------------------
    // 6. Hazard Detection & Forwarding Units
    //-------------------------------------------------------------------------
    hazard_unit hazard_unit_inst (
        .src1(instruction_id[19:16]),
        .src2(src2_id),
        .two_src(two_src_id),
        .exe_wb_en(wb_en_ex),
        .exe_dest(dest_ex),
        .mem_wb_en(wb_en_mem),
        .mem_dest(dest_mem),
        .exe_mem_r_en(mem_r_en_ex),
        .forwarding_en(forwarding_en),
        .hazard_detected(hazard_stall)
    );

    forwarding_unit forwarding_unit_inst (
        .forwarding_en(forwarding_en),
        .src1(src1_ex),
        .src2(src2_ex),
        .wb_en_mem(wb_en_mem),
        .dest_mem(dest_mem),
        .wb_en_wb(wb_en_mem_wb),
        .dest_wb(dest_mem_wb),
        .sel_src1(sel_fwd_src1),
        .sel_src2(sel_fwd_src2)
    );
endmodule
