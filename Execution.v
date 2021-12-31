`include "Jump_n_Branches.v"
`include "Arithmetic_Logic_Unit.v"
`include "Control_Status_Register.v"

`ifndef Execution
`define Execution

module Execution (
    input clk_in,

    input [63:0] pc_in,
    input [63:0] alu_result_in,
    input [63:0] wr_data_in,
    input [63:0] rs1_value_in,
    input [63:0] rs2_value_in,
    input [63:0] imm_value_in,
    input [63:0] instr_address_in,
    input [4:0] rs1_in,
    input [4:0] rd_in,

    input [2:0] alu_op_signal_in,
    input [2:0] alu_src_signal_in,
    input [2:0] width_signal_in,
    input [1:0] branch_op_signal_in,
    input [1:0] csr_op_signal_in,
    input [1:0] alu_mux1_src_signal_in,
    input [1:0] alu_mux2_src_signal_in,
    input ras_mux_src_signal_in,
    input call_mux_src_signal_in,
    input pc_src_signal_in,
    input jump_signal_in,
    input add_sub_srl_sra_signal_in,
    input rd_write_signal_in,
    input read_signal_in,
    input write_signal_in,
    input csr_write_signal_in,
    input csr_read_signal_in,
    input csr_rs1_imm_signal_in,
    input wb_src_signal_in,
    input valid_instr_signal_in,
    input wb_valid_instr_signal_in,
    input interrupt_signal_in,
    input return_interrupt_signal_in,
    input stall_signal_in,
    input flush_signal_in,

    output [63:0] pc_out,
    output reg [63:0] alu_result_out,
    output reg [63:0] rs2_value_out,
    output [63:0] csr_mepc_out,
    output reg [4:0] rd_out,

    output reg [2:0] width_signal_out,
    output branch_jump_signal_out,
    output reg rd_write_signal_out,
    output reg read_signal_out,
    output reg write_signal_out,
    output reg wb_src_signal_out, 
    output reg valid_instr_signal_out,
    output reg flush_signal_out
);

    wire [63:0] alu_result_Arithmetic_Logic_Unit;
    wire [63:0] csr_value_Control_Status_Register;
    wire carry_signal_Arithmetic_Logic_Unit;
    wire zero_signal_Arithmetic_Logic_Unit;
    
    wire [63:0] return_address_Return_Address_Stack;    
    wire return_signal_Return_Address_Stack;
    
Arithmetic_Logic_Unit Arithmetic_Logic_Unit(
    .pc_in(pc_in),                  
    .alu_result_in(alu_result_in),          
    .wr_data_in(wr_data_in),             
    .rs1_value_in(rs1_value_in),           
    .rs2_value_in(rs2_value_in),           
    .imm_value_in(imm_value_in),

    .width_data_signal_in((read_signal_in | write_signal_in) ? {`SIGN, `MEM_WIDTH_DWORD} : width_signal_in[2:0]),
    .alu_op_signal_in(alu_op_signal_in),
    .alu_src_signal_in(alu_src_signal_in),
    .alu_mux1_src_signal_in(alu_mux1_src_signal_in), 
    .alu_mux2_src_signal_in(alu_mux2_src_signal_in), 
    .add_sub_srl_sra_signal_in(add_sub_srl_sra_signal_in),
    
    .alu_result_out(alu_result_Arithmetic_Logic_Unit),
    .carry_signal_out(carry_signal_Arithmetic_Logic_Unit),
    .zero_signal_out(zero_signal_Arithmetic_Logic_Unit)
);

Return_Address_Stack Return_Address_Stack(
    .clk_in(clk_in),
    
    .return_address_reg_value_in(ras_mux_src_signal_in ? wr_data_in : rs2_value_in),
    .rs1_in(rs1_in),
    .rd_in(rd_in),
    
    .jalr_inst_signal_in(pc_src_signal_in),
    .jump_signal_in(jump_signal_in),
    .interrupt_signal_in(interrupt_signal_in),
    .return_address_out(return_address_Return_Address_Stack),
    
    .return_signal_out(return_signal_Return_Address_Stack)
);

Jump_n_Branches Jump_n_Branches(   
    .rs1_value_in(call_mux_src_signal_in ? wr_data_in : rs1_value_in),
    .pc_in(pc_in),
    .imm_value_in(imm_value_in),
    
    .branch_op_signal_in(branch_op_signal_in),
    .pc_src_signal_in(pc_src_signal_in),
    .jump_signal_in(jump_signal_in),
    .carry_signal_in(carry_signal_Arithmetic_Logic_Unit),
    .zero_signal_in(zero_signal_Arithmetic_Logic_Unit),
    
    .pc_out(pc_out),
        
    .branch_jump_signal_out(branch_jump_signal_out)
);

Control_Status_Register Control_Status_Register(
    .clk_in(clk_in),

    .rs1_value_in(rs1_value_in),
    .instr_address_in(instr_address_in),
    .csr_address_in(imm_value_in[11:0]),
    .uimm_value_in(rs1_in),
    
    .csr_op_signal_in(csr_op_signal_in),
    .csr_write_signal_in(csr_write_signal_in),
    .csr_rs1_imm_signal_in(csr_rs1_imm_signal_in),
    .wb_valid_inst_signal_in(wb_valid_instr_signal_in),
    .interrupt_signal_in(interrupt_signal_in),
    .return_interrupt_signal_in(return_interrupt_signal_in),
    .stall_signal_in(stall_signal_in),

    .csr_value_out(csr_value_Control_Status_Register),
    .csr_mepc_out(csr_mepc_out)
);

    always @(posedge clk_in) begin
        if(!stall_signal_in) begin
            alu_result_out <= csr_read_signal_in ? csr_value_Control_Status_Register : (return_signal_Return_Address_Stack ? return_address_Return_Address_Stack : alu_result_Arithmetic_Logic_Unit);
            rs2_value_out <= rs2_value_in;
            rd_out <= return_signal_Return_Address_Stack ? rs1_in : rd_in;
            flush_signal_out <= flush_signal_in;
        end
        if(!flush_signal_in) begin
            width_signal_out <= width_signal_in;
            rd_write_signal_out <= rd_write_signal_in | (return_signal_Return_Address_Stack & jump_signal_in);
            read_signal_out <= read_signal_in;
            write_signal_out <= write_signal_in;
            wb_src_signal_out <= wb_src_signal_in;
            valid_instr_signal_out <= valid_instr_signal_in;
        end 
        else begin
            width_signal_out <= 0;
            rd_write_signal_out <= 0;
            read_signal_out <= 0;
            write_signal_out <= 0;
            wb_src_signal_out <= 0;
            valid_instr_signal_out <= 0;
        end
    end
endmodule
`endif