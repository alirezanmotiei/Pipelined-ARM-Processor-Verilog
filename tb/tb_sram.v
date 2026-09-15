//=============================================================================
// File Name:    tb_sram.v
// Design:       SRAM Controller Standalone FSM Verification
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
//=============================================================================
`timescale 1ns / 1ps

module tb_sram;
    reg clk;
    reg rst;
    reg [31:0] cpu_addr;
    reg [31:0] cpu_wdata;
    reg cpu_mem_read;
    reg cpu_mem_write;

    wire [31:0] cpu_rdata;
    wire cpu_ready;
    wire [10:0] sram_addr;
    wire [7:0]  sram_data;
    wire sram_cs_n, sram_oe_n, sram_we_n;

    sram_controller ctrl (
        .clk(clk),
        .rst(rst),
        .cpu_addr(cpu_addr),
        .cpu_wdata(cpu_wdata),
        .cpu_mem_read(cpu_mem_read),
        .cpu_mem_write(cpu_mem_write),
        .cpu_rdata(cpu_rdata),
        .cpu_ready(cpu_ready),
        .sram_addr(sram_addr),
        .sram_data(sram_data),
        .sram_cs_n(sram_cs_n),
        .sram_oe_n(sram_oe_n),
        .sram_we_n(sram_we_n)
    );

    sram_model memory (
        .clk(clk),
        .Address(sram_addr),
        .DataIO(sram_data),
        .CS_n(sram_cs_n),
        .OE_n(sram_oe_n),
        .WE_n(sram_we_n)
    );

    always #5 clk = ~clk;

    initial begin
        $display("==================================================================");
        $display("  SRAM Controller 32-bit Multi-Cycle Read/Write Verification");
        $display("==================================================================");

        clk = 0;
        rst = 1;
        cpu_addr = 32'd0;
        cpu_wdata = 32'd0;
        cpu_mem_read = 0;
        cpu_mem_write = 0;

        #20;
        rst = 0;
        #10;

        // Write 0x12345678 to address 0x00000004
        $display("[TIME: %0t] Initiating 32-bit Store (STR) of 0x12345678 to Address 4...", $time);
        @(negedge clk);
        cpu_addr = 32'h00000004;
        cpu_wdata = 32'h12345678;
        cpu_mem_write = 1;

        @(negedge clk);
        cpu_mem_write = 0; // pulse single-cycle trigger

        wait(cpu_ready == 1);
        $display("[TIME: %0t] Store complete. cpu_ready returned HIGH.", $time);

        #30;

        // Read back from address 0x00000004
        $display("[TIME: %0t] Initiating 32-bit Load (LDR) from Address 4...", $time);
        @(negedge clk);
        cpu_addr = 32'h00000004;
        cpu_mem_read = 1;

        @(negedge clk);
        cpu_mem_read = 0;

        wait(cpu_ready == 1);
        $display("[TIME: %0t] Load complete. Read Data = 0x%08h (Expected: 0x12345678)", $time, cpu_rdata);

        #20;
        $display("==================================================================");
        $finish;
    end
endmodule
