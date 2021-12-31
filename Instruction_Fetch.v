`include "Program_Memory.v"
`include "Opcodes.vh"

`ifndef Instruction_Fetch
`define Instruction_Fetch

module Instruction_Fetch (
    input clk_in,
    
    input [63:0] branch_pc_in,
    input [63:0] branch_pc_pred_in,
    input [63:0] interrupt_pc_in,
    
    input branch_jump_signal_in,
    input branch_pred_signal_in,
    input interrupt_signal_in,
    input stall_signal_in,
    
    output reg [63:0] pc_out = 0,
    output reg [31:0] instr_out = 0
);

    wire [31:0] instr_read_value_Program_Memory;
    
    reg [63:0] instr_address_reg = 0;
    reg [63:0] instr_address_pc_reg = 0;
    reg interrupt_signal_reg = 0;

    initial
        instr_address_pc_reg = 0;

    Program_Memory Program_Memory (
        .instr_address_in(instr_address_reg),
        .instr_read_value_out(instr_read_value_Program_Memory)
    );
    
    always @(*)
    casex({interrupt_signal_reg, branch_pred_signal_in, branch_jump_signal_in})   
        `BRANCH_PC : begin
            instr_address_reg <= (branch_pc_in >> 2);
        end
        `NON_BRANCH_PC : begin
            instr_address_reg <= instr_address_pc_reg;
        end 
        `BRANCH_PRED_PC : begin
            instr_address_reg <= (branch_pc_pred_in >> 2);
        end
        `INTERRUPT_PC : begin
            instr_address_reg <= (interrupt_pc_in >> 2);
        end
        default : instr_address_reg <= instr_address_pc_reg;
    endcase

    always @(posedge clk_in) begin
        interrupt_signal_reg <= interrupt_signal_in;
    end

    always @(posedge clk_in) begin
        if(!stall_signal_in | interrupt_signal_reg) begin
            pc_out <= (instr_address_reg << 2);          
            instr_out <= instr_read_value_Program_Memory;
            instr_address_pc_reg <= instr_address_reg + 8'h01;
        end
    end
    
endmodule
`endif