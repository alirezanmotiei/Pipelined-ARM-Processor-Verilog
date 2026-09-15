//=============================================================================
// File Name:    condition_check.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  Evaluates ARM 4-bit condition field against NZCV Status Register flags.
//=============================================================================
`timescale 1ns / 1ps

module condition_check (
    input  wire [3:0] cond,
    input  wire [3:0] status, // status: [3]=Z, [2]=C, [1]=N, [0]=V
    output reg        cond_met
);
    wire z = status[3];
    wire c = status[2];
    wire n = status[1];
    wire v = status[0];

    always @(*) begin
        case (cond)
            4'b0000: cond_met =  z;              // EQ: Equal
            4'b0001: cond_met = ~z;              // NE: Not equal
            4'b0010: cond_met =  c;              // CS / HS: Carry set / Unsigned higher or same
            4'b0011: cond_met = ~c;              // CC / LO: Carry clear / Unsigned lower
            4'b0100: cond_met =  n;              // MI: Minus / Negative
            4'b0101: cond_met = ~n;              // PL: Plus / Positive or zero
            4'b0110: cond_met =  v;              // VS: Overflow set
            4'b0111: cond_met = ~v;              // VC: Overflow clear
            4'b1000: cond_met =  c & ~z;         // HI: Unsigned higher
            4'b1001: cond_met = ~c | z;          // LS: Unsigned lower or same
            4'b1010: cond_met = (n == v);        // GE: Signed greater than or equal
            4'b1011: cond_met = (n != v);        // LT: Signed less than
            4'b1100: cond_met = ~z & (n == v);   // GT: Signed greater than
            4'b1101: cond_met =  z | (n != v);   // LE: Signed less than or equal
            4'b1110: cond_met = 1'b1;            // AL: Always executed
            4'b1111: cond_met = 1'b0;            // NV: Never executed (reserved)
            default: cond_met = 1'b0;
        endcase
    end
endmodule
