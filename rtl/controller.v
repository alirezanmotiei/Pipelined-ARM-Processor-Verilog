//=============================================================================
// File Name:    controller.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  Main Control Unit decoding ARM opcodes, modes, and producing pipeline control signals.
//=============================================================================
`timescale 1ns / 1ps

module controller (
    input  wire [3:0] cond,
    input  wire [1:0] mode,
    input  wire [3:0] opcode,
    input  wire       s_in,
    output reg        wb_en,
    output reg        mem_r_en,
    output reg        mem_w_en,
    output reg  [3:0] exe_cmd,
    output reg        b,
    output reg        s_out
);
    always @(*) begin
        {mem_r_en, mem_w_en, b, exe_cmd} = 7'd0;
        s_out = s_in;
        wb_en = 1'b0;

        case (mode)
            2'b00: begin // Data Processing Instructions
                case (opcode)
                    4'b1101: begin // MOV
                        wb_en   = 1'b1;
                        exe_cmd = 4'b0001;
                    end
                    4'b1111: begin // MVN
                        wb_en   = 1'b1;
                        exe_cmd = 4'b1001;
                    end
                    4'b0100: begin // ADD
                        wb_en   = 1'b1;
                        exe_cmd = 4'b0010;
                    end
                    4'b0101: begin // ADC
                        wb_en   = 1'b1;
                        exe_cmd = 4'b0011;
                    end
                    4'b0010: begin // SUB
                        wb_en   = 1'b1;
                        exe_cmd = 4'b0100;
                    end
                    4'b0110: begin // SBC
                        wb_en   = 1'b1;
                        exe_cmd = 4'b0101;
                    end
                    4'b0000: begin // AND
                        wb_en   = (cond == 4'b1110) ? 1'b1 : 1'b0;
                        exe_cmd = 4'b0110;
                    end
                    4'b1100: begin // ORR
                        wb_en   = 1'b1;
                        exe_cmd = 4'b0111;
                    end
                    4'b0001: begin // EOR
                        wb_en   = 1'b1;
                        exe_cmd = 4'b1000;
                    end
                    4'b1010: begin // CMP (No WB, updates flags)
                        wb_en   = 1'b0;
                        exe_cmd = 4'b0100;
                    end
                    4'b1000: begin // TST (No WB, updates flags)
                        wb_en   = 1'b0;
                        exe_cmd = 4'b0110;
                    end
                    default: begin
                        wb_en   = 1'b0;
                        exe_cmd = 4'b0000;
                    end
                endcase
            end

            2'b01: begin // Memory Access (LDR / STR)
                if (opcode == 4'b0100) begin
                    exe_cmd = 4'b0010; // Address addition
                    if (s_in == 1'b1) begin
                        // LDR: Read memory, write back to register
                        wb_en    = 1'b1;
                        mem_r_en = 1'b1;
                        mem_w_en = 1'b0;
                    end else begin
                        // STR: Store register to memory, no write back
                        wb_en    = 1'b0;
                        mem_r_en = 1'b0;
                        mem_w_en = 1'b1;
                    end
                end
            end

            2'b10: begin // Branch Instruction
                b = 1'b1;
            end

            default: begin
                {mem_r_en, mem_w_en, b, exe_cmd, wb_en, s_out} = 9'd0;
            end
        endcase
    end
endmodule
