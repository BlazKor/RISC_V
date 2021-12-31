`include "Opcodes.vh"
`include "Data_Flow_Select.v"

`ifndef Arithmetic_Logic_Unit
`define Arithmetic_Logic_Unit

module Arithmetic_Logic_Unit(
    input [63:0] pc_in,
    input [63:0] alu_result_in,
    input [63:0] wr_data_in,
    input [63:0] rs1_value_in,
    input [63:0] rs2_value_in,
    input [63:0] imm_value_in,
    
    input [2:0] width_data_signal_in,
    input [2:0] alu_op_signal_in,
    input [2:0] alu_src_signal_in,
    input [1:0] alu_mux1_src_signal_in, 
    input [1:0] alu_mux2_src_signal_in, 
    input add_sub_srl_sra_signal_in,
    
    output reg [63:0] alu_result_out,
    output carry_signal_out,
    output zero_signal_out
);

    wire [64:0] sub_value;
    wire [63:0] value1;
    wire [63:0] value2;
    wire [5:0] shamt;
    
    reg [63:0] alu_result_reg;
    reg [63:0] srl_sra_value_reg;
    reg [31:0] srl_sra_value_32_reg;

    assign carry = sub_value[64];
    assign value1_sign = value1[63];
    assign value2_sign = value2[63];
    assign sign = width_data_signal_in[2];

    Data_Flow_Select Data_Flow_Select(
        .pc_in(pc_in),
        .alu_result_in(alu_result_in),
        .wr_data_in(wr_data_in),
        .rs1_value_in(rs1_value_in),
        .rs2_value_in(rs2_value_in),
        .imm_value_in(imm_value_in),

        .alu_src_signal_in(alu_src_signal_in),
        .alu_mux1_src_signal_in(alu_mux1_src_signal_in),
        .alu_mux2_src_signal_in(alu_mux2_src_signal_in),

        .alu_value1_out(value1),
        .alu_value2_out(value2)
    );

    assign shamt = value2[5:0];
    assign sub_value = value1 - value2;
    assign carry_sign = (value1_sign ^ value2_sign) ? ~carry : carry;
    assign carry_unsigned = value1 < value2;

    always @(*)
    case (alu_op_signal_in[2:0])
        `ALU_OP_ADD_SUB : begin
            alu_result_reg = add_sub_srl_sra_signal_in ? sub_value[63:0] : (value1 + value2);  
         end
        `ALU_OP_SLL : begin
            alu_result_reg = value1 << shamt;
         end
        `ALU_OP_SLT : begin
            alu_result_reg = {63'b0, carry_sign};
         end
        `ALU_OP_SLTU : begin
            alu_result_reg = {63'b0, carry_unsigned};
         end
        `ALU_OP_XOR : begin
            alu_result_reg = value1 ^ value2;
         end   
        `ALU_OP_SRL_SRA : begin
            alu_result_reg = srl_sra_value_reg;
         end  
        `ALU_OP_OR : begin
            alu_result_reg = value1 | value2;
         end  
        `ALU_OP_AND : begin
            alu_result_reg = value1 & value2;
         end
    endcase

    assign carry_signal_out = sign ? carry_unsigned : carry_sign;
    assign zero_signal_out = (sub_value == 0);

    always @(*)
    case (width_data_signal_in[1:0])
        `MEM_WIDTH_DWORD : begin
            if(add_sub_srl_sra_signal_in) begin
                srl_sra_value_reg = $signed(value1) >>> shamt;
            end
            else begin
                srl_sra_value_reg = value1 >> shamt;
            end
            alu_result_out = alu_result_reg;
        end
        `MEM_WIDTH_WORD : begin
            if(add_sub_srl_sra_signal_in) begin
                srl_sra_value_32_reg = $signed(value1[31:0]) >>> shamt[4:0];
                srl_sra_value_reg = srl_sra_value_32_reg;
            end
            else begin 
                srl_sra_value_reg = value1[31:0] >> shamt[4:0];
            end
            alu_result_out = {{32{alu_result_reg[31]}}, alu_result_reg[31:0]};
        end
        default : begin
            alu_result_out = alu_result_reg;
            srl_sra_value_reg = 0;    
        end
    endcase
endmodule
`endif