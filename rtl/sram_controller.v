//=============================================================================
// File Name:    sram_controller.v
// Design:       5-Stage Pipelined ARM Processor (ARMv4T Subset)
// Author:       Alireza Najafi Motiei (ID: 810100224)
// Affiliation:  Department of Electrical and Computer Engineering, University of Tehran
// Course:       Computer Architecture Laboratory (Dr. Saeed Safari)
// Description:  3-State FSM multi-cycle SRAM Controller (4 consecutive byte read/writes).
//=============================================================================
`timescale 1ns / 1ps

module sram_controller (
    input  wire        clk,
    input  wire        rst,

    // CPU Interface
    input  wire [31:0] cpu_addr,
    input  wire [31:0] cpu_wdata,
    input  wire        cpu_mem_read,
    input  wire        cpu_mem_write,
    output reg  [31:0] cpu_rdata,
    output reg         cpu_ready,

    // SRAM Hardware Interface
    output reg  [10:0] sram_addr,
    inout  wire [7:0]  sram_data,
    output reg         sram_cs_n,
    output reg         sram_oe_n,
    output reg         sram_we_n
);
    localparam IDLE = 2'd0;
    localparam WORK = 2'd1;
    localparam DONE = 2'd2;

    reg [1:0] current_state, next_state;
    reg [31:0] read_data_temp;
    reg [1:0] counter;
    reg [7:0] data_to_write;

    assign sram_data = (!sram_we_n) ? data_to_write : 8'bz;

    // State transition and counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            counter       <= 2'd0;
        end else begin
            current_state <= next_state;
            if (current_state == WORK)
                counter <= counter + 1'b1;
            else if (current_state == IDLE)
                counter <= 2'd0;
        end
    end

    // Next state logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (cpu_mem_read || cpu_mem_write)
                    next_state = WORK;
            end
            WORK: begin
                if (counter == 2'd3)
                    next_state = DONE;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Output generation on falling clock edge to guarantee setup time for memory
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            cpu_ready      <= 1'b1;
            sram_cs_n      <= 1'b1;
            sram_oe_n      <= 1'b1;
            sram_we_n      <= 1'b1;
            cpu_rdata      <= 32'd0;
            read_data_temp <= 32'd0;
            sram_addr      <= 11'd0;
            data_to_write  <= 8'd0;
        end else begin
            sram_cs_n <= 1'b0;
            sram_oe_n <= 1'b1;
            sram_we_n <= 1'b1;
            cpu_ready <= 1'b0;

            case (current_state)
                IDLE: begin
                    cpu_ready <= 1'b1;
                    sram_cs_n <= 1'b1;
                    if (cpu_mem_read || cpu_mem_write) begin
                        cpu_ready <= 1'b0;
                        sram_cs_n <= 1'b0;
                        sram_addr <= {cpu_addr[8:0], 2'b00};
                    end
                end

                WORK: begin
                    if (counter < 2'd3)
                        sram_addr <= {cpu_addr[8:0], (counter + 2'b01)};

                    if (cpu_mem_read) begin
                        sram_oe_n <= 1'b0;
                        if (counter == 2'd1) read_data_temp[7:0]   <= sram_data;
                        if (counter == 2'd2) read_data_temp[15:8]  <= sram_data;
                        if (counter == 2'd3) read_data_temp[23:16] <= sram_data;
                    end

                    if (cpu_mem_write) begin
                        sram_we_n <= 1'b0;
                        case (counter)
                            2'd0: data_to_write <= cpu_wdata[7:0];
                            2'd1: data_to_write <= cpu_wdata[15:8];
                            2'd2: data_to_write <= cpu_wdata[23:16];
                            2'd3: data_to_write <= cpu_wdata[31:24];
                        endcase
                    end else begin
                        sram_oe_n <= 1'b0;
                    end
                end

                DONE: begin
                    sram_cs_n <= 1'b1;
                    cpu_ready <= 1'b1;
                    if (cpu_mem_read) begin
                        read_data_temp[31:24] <= sram_data;
                        cpu_rdata             <= {sram_data, read_data_temp[23:0]};
                    end
                end
            endcase
        end
    end
endmodule
