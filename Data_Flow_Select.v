`include "Opcodes.vh"

`ifndef Data_Flow_Select
`define Data_Flow_Select

module Data_Flow_Select(
    input [63:0] pc_in,
    input [63:0] alu_result_in,
    input [63:0] wr_data_in,
    input [63:0] rs1_value_in,
    input [63:0] rs2_value_in,
    input [63:0] imm_value_in,

    input [2:0] alu_src_signal_in,
    input [1:0] alu_mux1_src_signal_in,
    input [1:0] alu_mux2_src_signal_in,
    
    output reg [63:0] alu_value1_out,
    output reg [63:0] alu_value2_out
    );
    
    reg [63:0] value_rs1_pc_zero_reg;
    reg [63:0] value_rs2_imm_four_reg;
    
    always @(*) begin
    case (alu_src_signal_in)
        `ALU_SRC_R1_R2 : begin
            value_rs1_pc_zero_reg <= rs1_value_in;
            value_rs2_imm_four_reg <= rs2_value_in;
         end
        `ALU_SRC_R1_IMM : begin
            value_rs1_pc_zero_reg <= rs1_value_in;
            value_rs2_imm_four_reg <= imm_value_in;     
         end
        `ALU_SRC_PC_IMM : begin
            value_rs1_pc_zero_reg <= pc_in;
            value_rs2_imm_four_reg <= imm_value_in;     
         end
        `ALU_SRC_PC_FOUR : begin
            value_rs1_pc_zero_reg <= pc_in;
            value_rs2_imm_four_reg <= 4;     
         end
        `ALU_SRC_ZERO_IMM : begin
            value_rs1_pc_zero_reg <= 0;
            value_rs2_imm_four_reg <= imm_value_in;     
         end
         default : begin
            value_rs1_pc_zero_reg <= rs1_value_in;
            value_rs2_imm_four_reg <= rs2_value_in;
         end
    endcase
  
    case(alu_mux1_src_signal_in)
        2'b00 : alu_value1_out <= value_rs1_pc_zero_reg;
        2'b01 : alu_value1_out <= alu_result_in;  
        2'b10 : alu_value1_out <= wr_data_in;    
        default:  alu_value1_out <= value_rs1_pc_zero_reg;
    endcase
    
    case(alu_mux2_src_signal_in)
        2'b00: alu_value2_out <= value_rs2_imm_four_reg;
        2'b01: alu_value2_out <= alu_result_in;  
        2'b10: alu_value2_out <= wr_data_in;    
        default: alu_value2_out <= value_rs2_imm_four_reg;
    endcase
    end
endmodule
`endif