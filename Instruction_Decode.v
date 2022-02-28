`include "General_Purpose_Registers.v"
`include "Control_Unit.v"
`include "Immediate_Generator.v"

`ifndef Instruction_Decode
`define Instruction_Decode

module Instruction_Decode (
    input clk_in,

    input [63:0] wr_data_in,
    input [63:0] pc_in,
    input [63:0] csr_mepc_in,
    input [31:0] instr_in,
    input [4:0] rd_in,
    input [4:0] register_addres_in,

    input rd_write_signal_in,
    input return_interrupt_signal_in,
    input interrupt_signal_in,
    input return_address_registers_flag_signal_in,
    input stall_signal_in,
    input flush_signal_in,

    output [63:0] rs1_value_out,
    output [63:0] rs2_value_out,
    output reg [63:0] imm_value_out,    
    output reg [63:0] pc_out,
    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,

    output reg [2:0] alu_op_signal_out,
    output reg [2:0] alu_src_signal_out,
    output reg [2:0] width_signal_out,
    output reg [2:0] imm_signal_out,
    output reg [1:0] branch_op_signal_out,
    output reg [1:0] csr_op_signal_out,
    output reg pc_src_signal_out,
    output reg jump_signal_out,
    output reg add_sub_srl_sra_signal_out,
    output reg rd_write_signal_out,
    output reg read_signal_out,
    output reg write_signal_out,
    output reg csr_write_signal_out,
    output reg csr_read_signal_out,
    output reg csr_rs1_imm_signal_out,
    output reg wb_src_signal_out,
    output reg valid_instr_signal_out,
    output reg flush_signal_out
    
    //output [15:0] led_out
);
    reg interrupt_signal_reg = 0;
    
    wire [2:0] alu_op_signal_Control_Unit;
    wire [2:0] alu_src_signal_Control_Unit;
    wire [2:0] imm_signal_Control_Unit;
    wire [2:0] width_signal_Control_Unit;
    wire [1:0] branch_op_signal_Control_Unit;
    wire [1:0] csr_op_signal_Control_Unit;
    wire pc_src_signal_Control_Unit;
    wire jump_signal_Control_Unit;
    wire add_sub_srl_sra_signal_Control_Unit;
    wire rd_write_signal_Control_Unit;
    wire read_signal_Control_Unit;
    wire write_signal_Control_Unit;
    wire csr_write_signal_Control_Unit;
    wire csr_read_signal_Control_Unit;
    wire csr_rs1_imm_signal_Control_Unit;
    wire wb_src_signal_Control_Unit;
    wire valid_instr_signal_out_Control_Unit;

    wire [63:0] imm_value_Immediate_Generation;

General_Purpose_Registers General_Purpose_Registers (
    .clk_in(clk_in),
    
    .wr_data_in((interrupt_signal_in) ? csr_mepc_in : wr_data_in),
    .rs1_in(instr_in[19:15]),
    .rs2_in(interrupt_signal_in ? register_addres_in : (jump_signal_Control_Unit ? instr_in[11:7] : instr_in[24:20])),
    .rd_in(interrupt_signal_in ? 5'b00001 : rd_in),
    
    .rd_write_signal_in(rd_write_signal_in),
    .return_interrupt_signal_in(return_interrupt_signal_in),
    .interrupt_signal_in(interrupt_signal_in),
    .stall_signal_in(stall_signal_in),
    .flush_signal_in(flush_signal_in),
    
    .rs1_value_out(rs1_value_out),
    .rs2_value_out(rs2_value_out)
    
    //.led_out(led_out)
);

Control_Unit Control_Unit (
    .instr_in(instr_in),
    
    .alu_op_signal_out(alu_op_signal_Control_Unit),
    .alu_src_signal_out(alu_src_signal_Control_Unit),
    .imm_signal_out(imm_signal_Control_Unit),
    .width_signal_out(width_signal_Control_Unit),
    .branch_op_signal_out(branch_op_signal_Control_Unit),
    .csr_op_signal_out(csr_op_signal_Control_Unit),
    .pc_src_signal_out(pc_src_signal_Control_Unit),
    .jump_signal_out(jump_signal_Control_Unit),
    .add_sub_srl_sra_signal_out(add_sub_srl_sra_signal_Control_Unit),
    .rd_write_signal_out(rd_write_signal_Control_Unit),
    .read_signal_out(read_signal_Control_Unit),
    .write_signal_out(write_signal_Control_Unit),
    .csr_write_signal_out(csr_write_signal_Control_Unit),
    .csr_read_signal_out(csr_read_signal_Control_Unit),
    .csr_rs1_imm_signal_out(csr_rs1_imm_signal_Control_Unit),
    .wb_src_signal_out(wb_src_signal_Control_Unit),
    .valid_instr_signal_out(valid_instr_signal_out_Control_Unit)
);

Immediate_Generator Immediate_Generator (
    .instr_in(instr_in),
    
    .imm_signal_in(imm_signal_Control_Unit),
    
    .imm_value_out(imm_value_Immediate_Generation)
);
    always @(posedge clk_in) begin
        interrupt_signal_reg <= interrupt_signal_in;
    end
    
    assign interrupt_signal = ~interrupt_signal_reg & interrupt_signal_in;
    
    always @(posedge clk_in) begin
        if(!stall_signal_in) begin
            imm_value_out <= imm_value_Immediate_Generation;
            pc_out <= pc_in;
            rs1_out <= instr_in[19:15];
            rs2_out <= instr_in[24:20];
            rd_out <= instr_in[11:7];
            
            flush_signal_out <= flush_signal_in;
            alu_op_signal_out <= alu_op_signal_Control_Unit;
            alu_src_signal_out <= alu_src_signal_Control_Unit;
            width_signal_out <= width_signal_Control_Unit;
            imm_signal_out <= imm_signal_Control_Unit;
            branch_op_signal_out <= branch_op_signal_Control_Unit;
            csr_op_signal_out <= csr_op_signal_Control_Unit;
            pc_src_signal_out <= pc_src_signal_Control_Unit;
            jump_signal_out <= jump_signal_Control_Unit;
            add_sub_srl_sra_signal_out <= add_sub_srl_sra_signal_Control_Unit;
            rd_write_signal_out <= rd_write_signal_Control_Unit;
            read_signal_out <= read_signal_Control_Unit;
            write_signal_out <= write_signal_Control_Unit;
            csr_write_signal_out <= csr_write_signal_Control_Unit;
            csr_read_signal_out <= csr_read_signal_Control_Unit;
            csr_rs1_imm_signal_out <= csr_rs1_imm_signal_Control_Unit;
            wb_src_signal_out <= wb_src_signal_Control_Unit;
            valid_instr_signal_out <= valid_instr_signal_out_Control_Unit;
            
            if(flush_signal_in) begin
                alu_op_signal_out <= 8'h00;
                alu_src_signal_out <= 8'h00;
                width_signal_out <= 8'h00;
                imm_signal_out <= 8'h00;
                branch_op_signal_out <= 8'hzz;
                csr_op_signal_out <= 8'h00;
                pc_src_signal_out <= 8'h00;
                jump_signal_out <= 8'h00;
                add_sub_srl_sra_signal_out <= 8'h00;
                rd_write_signal_out <= 8'h00;
                read_signal_out <= 8'h00;
                write_signal_out <= 8'h00;
                csr_write_signal_out <= 8'h00;
                csr_read_signal_out <= 8'h00;
                csr_rs1_imm_signal_out <= 8'h00;
                wb_src_signal_out <= 8'h00;
                valid_instr_signal_out <= 8'h00;
            end
        end
        if(interrupt_signal) begin
            alu_op_signal_out <= 8'h00;
            alu_src_signal_out <= 8'h00;
            width_signal_out <= 8'h00;
            imm_signal_out <= 8'h00;
            branch_op_signal_out <= 8'hzz;
            csr_op_signal_out <= 8'h00;
            pc_src_signal_out <= 8'h00;
            jump_signal_out <= 8'h00;
            add_sub_srl_sra_signal_out <= 8'h00;
            rd_write_signal_out <= 8'h00;
            read_signal_out <= 8'h00;
            write_signal_out <= 8'h00;
            csr_write_signal_out <= 8'h00;
            csr_read_signal_out <= 8'h00;
            csr_rs1_imm_signal_out <= 8'h00;
            wb_src_signal_out <= 8'h00;
            valid_instr_signal_out <= 8'h00;
        end
    end
endmodule
`endif