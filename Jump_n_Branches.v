`include "Opcodes.vh"

`ifndef Jump_n_Branches
`define Jump_n_Branches

module Jump_n_Branches(   
    input [63:0] pc_in,
    input [63:0] rs1_value_in,
    input [63:0] imm_value_in,

    input [1:0] branch_op_signal_in,
    input pc_src_signal_in,
    input jump_signal_in,
    input carry_signal_in,
    input zero_signal_in,
    
    output [63:0] pc_out,
    
    output branch_jump_signal_out 
);

    reg branch_signal_reg = 0;
    reg jump_signal_reg = 0;
    
    always @(*) begin
        jump_signal_reg <= jump_signal_in;
    end
    
    always @(branch_op_signal_in or zero_signal_in or carry_signal_in)
    case(branch_op_signal_in)
        `BRANCH_BEQ : begin
            if(~(zero_signal_in ^ 1'b1)) begin
                branch_signal_reg = `BRANCH_PC_ACCEPTED; 
            end
            else branch_signal_reg = 1'b0; 
         end
        `BRANCH_BNE : begin
            if(~(zero_signal_in ^ 1'b0)) begin
                branch_signal_reg = `BRANCH_PC_ACCEPTED; 
            end
            else branch_signal_reg = 1'b0; 
         end
        `BRANCH_BLT : begin
            if(carry_signal_in) begin
                branch_signal_reg = `BRANCH_PC_ACCEPTED; 
            end
            else branch_signal_reg = 1'b0; 
         end
        `BRANCH_BGE : begin
            if(~carry_signal_in | zero_signal_in) begin
                branch_signal_reg = `BRANCH_PC_ACCEPTED; 
            end
            else branch_signal_reg = 1'b0; 
         end
         default : branch_signal_reg = 1'b0; 
    endcase
    
    assign branch_jump_signal_out = jump_signal_reg | branch_signal_reg;
    assign pc_out = ((pc_src_signal_in ? rs1_value_in : (pc_in - 4))) + (imm_value_in << 1);        
    
endmodule
`endif