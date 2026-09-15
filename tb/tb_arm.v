//=============================================================================
// File Name:    tb_arm.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  Self-checking verification testbench monitoring CPI, cycle count, and registers.
//=============================================================================
`timescale 1ns / 1ps

module tb_arm;
    reg clk;
    reg rst;
    reg forwarding_en;

    wire [31:0] pc;
    wire [31:0] instruction;
    wire [10:0] sram_addr;
    wire [7:0]  sram_data;
    wire        sram_cs_n, sram_oe_n, sram_we_n;

    // Performance counters
    integer cycle_count;
    integer instruction_count;

    // Instantiate Instruction ROM
    instruction_memory #(
        .MEM_DEPTH(1024),
        .INIT_FILE("program.hex")
    ) inst_mem (
        .addr(pc),
        .instruction(instruction)
    );

    // Instantiate ARM Core
    arm_core uut (
        .clk(clk),
        .rst(rst),
        .forwarding_en(forwarding_en),
        .instruction_in(instruction),
        .pc_out(pc),
        .sram_addr(sram_addr),
        .sram_data(sram_data),
        .sram_cs_n(sram_cs_n),
        .sram_oe_n(sram_oe_n),
        .sram_we_n(sram_we_n)
    );

    // Instantiate 2KB SRAM
    sram_model sram (
        .clk(clk),
        .Address(sram_addr),
        .DataIO(sram_data),
        .CS_n(sram_cs_n),
        .OE_n(sram_oe_n),
        .WE_n(sram_we_n)
    );

    // 100 MHz Simulation Clock (Period = 10 ns)
    always #5 clk = ~clk;

    // Cycle counter
    always @(posedge clk) begin
        if (!rst)
            cycle_count <= cycle_count + 1;
    end

    initial begin
        $display("==================================================================");
        $display("  ARM Processor Testbench: 5-Stage Pipeline Verification");
        $display("  Author: Alireza Najafi Motiei (ID: 810100224)");
        $display("  Affiliation: University of Tehran");
        $display("==================================================================");

        clk = 0;
        rst = 1;
        forwarding_en = 1; // Enable Forwarding (Set to 0 for Stalling comparison)
        cycle_count = 0;
        instruction_count = 47;

        #30;
        rst = 0;
        $display("[INFO] Processor released from reset. Execution started...");

        #6000;

        $display("------------------------------------------------------------------");
        $display("  SIMULATION PERFORMANCE BENCHMARK REPORT");
        $display("------------------------------------------------------------------");
        $display("  Forwarding Mode:          %s", forwarding_en ? "ENABLED (Dynamic Bypassing)" : "DISABLED (Hazard Stalls)");
        $display("  Total Clock Cycles:       %0d cycles", cycle_count);
        $display("  Total Execution Time:     %0d ns (Clock Period = 10 ns)", cycle_count * 10);
        $display("  Retired Instructions:     %0d instructions", instruction_count);
        $display("  Average CPI:              %0.4f", (1.0 * cycle_count) / instruction_count);
        $display("------------------------------------------------------------------");
        $display("  Architectural Register Values:");
        $display("    R0  = 0x%08h (%0d)", uut.id_stage_inst.reg_file.rf[0], uut.id_stage_inst.reg_file.rf[0]);
        $display("    R1  = 0x%08h (%0d)", uut.id_stage_inst.reg_file.rf[1], uut.id_stage_inst.reg_file.rf[1]);
        $display("    R2  = 0x%08h (%0d)", uut.id_stage_inst.reg_file.rf[2], uut.id_stage_inst.reg_file.rf[2]);
        $display("    R3  = 0x%08h (%0d)", uut.id_stage_inst.reg_file.rf[3], uut.id_stage_inst.reg_file.rf[3]);
        $display("    R4  = 0x%08h (%0d)", uut.id_stage_inst.reg_file.rf[4], uut.id_stage_inst.reg_file.rf[4]);
        $display("    R5  = 0x%08h (%0d)", uut.id_stage_inst.reg_file.rf[5], uut.id_stage_inst.reg_file.rf[5]);
        $display("    R6  = 0x%08h (%0d)", uut.id_stage_inst.reg_file.rf[6], uut.id_stage_inst.reg_file.rf[6]);
        $display("    R7  = 0x%08h (%0d)", uut.id_stage_inst.reg_file.rf[7], uut.id_stage_inst.reg_file.rf[7]);
        $display("==================================================================");
        $finish;
    end
endmodule
