//=============================================================================
// File Name:    alu.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  32-bit Arithmetic Logic Unit supporting ARMv4 data-processing instructions.
//=============================================================================
`timescale 1ns / 1ps

module alu (
    input  wire [3:0]  exe_cmd,
    input  wire [31:0] val1,
    input  wire [31:0] val2,
    input  wire        cin,
    output reg  [31:0] alu_res,
    output reg         c,
    output wire        n,
    output wire        z,
    output reg         v
);
    always @(*) begin
        v = 1'b0;
        c = 1'b0;
        case (exe_cmd)
            4'b0001: begin // MOV
                alu_res = val2;
            end
            4'b1001: begin // MVN
                alu_res = ~val2;
            end
            4'b0010: begin // ADD
                {c, alu_res} = val1 + val2;
                v = (~val1[31] & ~val2[31] & alu_res[31]) | (val1[31] & val2[31] & ~alu_res[31]);
            end
            4'b0011: begin // ADC
                {c, alu_res} = val1 + val2 + cin;
                v = (~val1[31] & ~val2[31] & alu_res[31]) | (val1[31] & val2[31] & ~alu_res[31]);
            end
            4'b0100: begin // SUB / CMP
                {c, alu_res} = val1 - val2;
                v = (~val1[31] & val2[31] & alu_res[31]) | (val1[31] & ~val2[31] & ~alu_res[31]);
            end
            4'b0101: begin // SBC
                {c, alu_res} = val1 - val2 - !cin;
                v = (~val1[31] & val2[31] & alu_res[31]) | (val1[31] & ~val2[31] & ~alu_res[31]);
            end
            4'b0110: begin // AND / TST
                alu_res = val1 & val2;
            end
            4'b0111: begin // ORR
                alu_res = val1 | val2;
            end
            4'b1000: begin // EOR
                alu_res = val1 ^ val2;
            end
            default: begin
                alu_res = 32'd0;
            end
        endcase
    end

    assign z = (alu_res == 32'd0);
    assign n = alu_res[31];
endmodule
