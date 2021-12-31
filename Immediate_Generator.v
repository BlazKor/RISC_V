`include "Opcodes.vh"

`ifndef Immediate_Generator
`define Immediate_Generator

module Immediate_Generator (
    input [31:0] instr_in,
    
    input [2:0] imm_signal_in,
    
    output reg [63:0] imm_value_out
);  
    wire [63:0] imm_I;
    wire [63:0] imm_S;
    wire [63:0] imm_U;
    wire [63:0] imm_J;
    wire [63:0] imm_B;
    
    assign signbit = instr_in[31];
    assign imm_I = {{32{signbit}}, {20{signbit}}, instr_in[31:20]};
    assign imm_S = {{32{signbit}}, {20{signbit}}, instr_in[31:25], instr_in[11:7]};
    assign imm_U = {{32{signbit}}, instr_in[31:12], 12'b0};
    assign imm_J = {{32{signbit}}, {12{signbit}}, instr_in[19:12], instr_in[20], instr_in[30:21], 1'b0};
    assign imm_B = {{32{signbit}}, {20{signbit}}, instr_in[7], instr_in[30:25], instr_in[11:8], 1'b0};
    
    always @(*)
        case (imm_signal_in)
            `IMM_I_TYPE : begin 
                imm_value_out <= imm_I;
            end
            `IMM_S_TYPE : begin
                imm_value_out <= imm_S;
            end
            `IMM_U_TYPE : begin 
                imm_value_out <= imm_U;
            end
            `IMM_J_TYPE : begin 
                imm_value_out <= imm_J;
            end
            `IMM_B_TYPE : begin 
                imm_value_out <= imm_B;
            end
            default : begin 
                imm_value_out <= 8'h00;
            end
        endcase
endmodule
`endif