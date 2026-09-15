//=============================================================================
// File Name:    tb_controller.v
// Design:       Standalone Control Unit Verification
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
//=============================================================================
`timescale 1ns / 1ps

module tb_controller;
    reg  [3:0] cond;
    reg  [1:0] mode;
    reg  [3:0] opcode;
    reg        s_in;

    wire       wb_en;
    wire       mem_r_en;
    wire       mem_w_en;
    wire [3:0] exe_cmd;
    wire       b;
    wire       s_out;

    controller uut (
        .cond(cond),
        .mode(mode),
        .opcode(opcode),
        .s_in(s_in),
        .wb_en(wb_en),
        .mem_r_en(mem_r_en),
        .mem_w_en(mem_w_en),
        .exe_cmd(exe_cmd),
        .b(b),
        .s_out(s_out)
    );

    initial begin
        $display("==================================================================");
        $display("  ARM Controller Unit Testbench Verification");
        $display("==================================================================");

        // Test MOV R0, #20 (mode=00, opcode=1101)
        mode = 2'b00; opcode = 4'b1101; s_in = 0; cond = 4'b1110;
        #10;
        $display("MOV:  wb_en=%b, mem_r=%b, mem_w=%b, exe_cmd=%b (Expected: 1, 0, 0, 0001)", wb_en, mem_r_en, mem_w_en, exe_cmd);

        // Test ADD R1, R2, R3 (mode=00, opcode=0100)
        mode = 2'b00; opcode = 4'b0100; s_in = 0; cond = 4'b1110;
        #10;
        $display("ADD:  wb_en=%b, mem_r=%b, mem_w=%b, exe_cmd=%b (Expected: 1, 0, 0, 0010)", wb_en, mem_r_en, mem_w_en, exe_cmd);

        // Test SUB R1, R2, R3 (mode=00, opcode=0010)
        mode = 2'b00; opcode = 4'b0010; s_in = 0; cond = 4'b1110;
        #10;
        $display("SUB:  wb_en=%b, mem_r=%b, mem_w=%b, exe_cmd=%b (Expected: 1, 0, 0, 0100)", wb_en, mem_r_en, mem_w_en, exe_cmd);

        // Test CMP R1, R2 (mode=00, opcode=1010, s_in=1) -> No WB, flags updated
        mode = 2'b00; opcode = 4'b1010; s_in = 1; cond = 4'b1110;
        #10;
        $display("CMP:  wb_en=%b, s_out=%b, exe_cmd=%b (Expected: 0, 1, 0100)", wb_en, s_out, exe_cmd);

        // Test LDR R1, [R2] (mode=01, opcode=0100, s_in=1)
        mode = 2'b01; opcode = 4'b0100; s_in = 1; cond = 4'b1110;
        #10;
        $display("LDR:  wb_en=%b, mem_r=%b, mem_w=%b (Expected: 1, 1, 0)", wb_en, mem_r_en, mem_w_en);

        // Test STR R1, [R2] (mode=01, opcode=0100, s_in=0)
        mode = 2'b01; opcode = 4'b0100; s_in = 0; cond = 4'b1110;
        #10;
        $display("STR:  wb_en=%b, mem_r=%b, mem_w=%b (Expected: 0, 0, 1)", wb_en, mem_r_en, mem_w_en);

        // Test B Label (mode=10)
        mode = 2'b10; opcode = 4'b0000; s_in = 0; cond = 4'b1110;
        #10;
        $display("B:    b=%b (Expected: 1)", b);

        $display("==================================================================");
        $finish;
    end
endmodule
