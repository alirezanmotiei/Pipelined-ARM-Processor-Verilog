//=============================================================================
// File Name:    instruction_memory.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  Behavioral Instruction ROM preloaded with the laboratory validation program.
//=============================================================================
`timescale 1ns / 1ps

module instruction_memory #(
    parameter MEM_DEPTH = 1024,
    parameter INIT_FILE = "program.hex"
)(
    input  wire [31:0] addr,
    output wire [31:0] instruction
);
    reg [31:0] rom [0:MEM_DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1)
            rom[i] = 32'd0;
        $readmemb(INIT_FILE, rom);
    end

    // Instruction address is word-aligned (PC incremented by 1)
    assign instruction = rom[addr[9:0]];
endmodule
