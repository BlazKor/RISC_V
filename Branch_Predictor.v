`include "Opcodes.vh"

`ifndef Branch_Predictor
`define Branch_Predictor

module Branch_Predictor(
    input clk_in,
    
    input [63:0] pc_in,
    input [31:0] instr_in,
    
    input [2:0] branch_type_signal_in,
    input branch_jump_signal_in,
    input jump_signal_in,
    input interrupt_signal_in,
    
    output [63:0] branch_pc_pred_out,
    output reg [63:0] pc_out,
    output reg [31:0] inst_out,
    
    output pred_signal_out,
    output reg branch_pred_signal_out = 0,
    output return_pred_signal_out
);
    
    wire [2:0] instr_type;
    wire [63:0] branch_pc_pred_in;
    
    reg [2:0] prediction_type_reg = 3'b010;
    reg [63:0] pc_return_address_reg = 64'b0;
    
    reg return_pred_signal_reg = 0;
    
    assign branch_pc_pred_in = {{51{instr_in[31]}}, instr_in[7], instr_in[30:25], instr_in[11:8], 2'b00};
    assign instr_type = {instr_in[13], instr_in[14], instr_in[12]};
    assign Prediction_enable = (instr_in[6:0] == `BEQ_BNE_BLT_BGE_BLTU_BGEU);
    
    always @(negedge clk_in) begin
        if(branch_jump_signal_in & ~jump_signal_in) begin
            prediction_type_reg <= branch_type_signal_in;
        end
        if(return_pred_signal_out | interrupt_signal_in) begin 
            prediction_type_reg <= 3'b010;
        end
    end
    
    always @(*) begin
        if(Prediction_enable) begin
            pc_return_address_reg <= pc_in;
        end
        if(branch_jump_signal_in & (pc_in != pc_return_address_reg)) begin
            inst_out <= instr_in;
            pc_out <= pc_in;
        end
    end
    
    assign return_pred_signal_out = (~branch_jump_signal_in & branch_pred_signal_out) ^ return_pred_signal_reg;

    always @(posedge clk_in) begin
        return_pred_signal_reg <= return_pred_signal_out & ~interrupt_signal_in;
        branch_pred_signal_out <= pred_signal_out & ~interrupt_signal_in;
    end
    
    assign pred_signal_out = (return_pred_signal_out | (Prediction_enable & (prediction_type_reg == instr_type)));
    assign branch_pc_pred_out = return_pred_signal_out ? (pc_out + 4) : (pred_signal_out ? (pc_in + branch_pc_pred_in - 4) : 64'b0);
endmodule
`endif