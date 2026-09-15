//=============================================================================
// File Name:    register_file.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  16 x 32-bit Banked Register File with negative-edge write and dual read ports.
//=============================================================================
`timescale 1ns / 1ps

module register_file (
    input  wire        clk,
    input  wire        rst,
    input  wire [3:0]  src1,
    input  wire [3:0]  src2,
    input  wire [3:0]  dest_wb,
    input  wire [31:0] result_wb,
    input  wire        write_back_en,
    output wire [31:0] reg1,
    output wire [31:0] reg2
);
    reg [31:0] rf [15:0];
    integer i;

    // Asynchronous dual read
    assign reg1 = rf[src1];
    assign reg2 = rf[src2];

    // Synchronous write on negative clock edge to avoid RAW hazards across half-cycles
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 16; i = i + 1)
                rf[i] <= i;
        end else if (write_back_en) begin
            rf[dest_wb] <= result_wb;
        end
    end
endmodule
