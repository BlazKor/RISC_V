`include "Opcodes.vh"

`ifndef Control_Unit
`define Control_Unit

module Control_Unit (
    input [31:0] instr_in,

    output reg [2:0] alu_op_signal_out = 0,
    output reg [2:0] alu_src_signal_out = 0,
    output reg [2:0] imm_signal_out = 0,
    output reg [2:0] width_signal_out = 0,
    output reg [1:0] branch_op_signal_out = 0,
    output reg [1:0] csr_op_signal_out = 0,   
    output reg pc_src_signal_out = 0,
    output reg jump_signal_out = 0,
    output reg add_sub_srl_sra_signal_out = 0,
    output reg rd_write_signal_out = 0,
    output reg read_signal_out = 0,
    output reg write_signal_out = 0,
    output reg csr_write_signal_out = 0,
    output reg csr_read_signal_out = 0,
    output reg csr_rs1_imm_signal_out = 0,
    output reg wb_src_signal_out = 0,
    output reg valid_instr_signal_out = 0
);

    always @(instr_in) begin
        alu_op_signal_out = 0;
        alu_src_signal_out = 0;
        imm_signal_out = 0;
        width_signal_out = 0;
        branch_op_signal_out = 2'bzz;
        csr_op_signal_out = 0;
        pc_src_signal_out = 0;
        jump_signal_out = 0;
        add_sub_srl_sra_signal_out = 0;
        rd_write_signal_out = 0;
        read_signal_out = 0;
        write_signal_out = 0;
        csr_write_signal_out = 0;
        csr_read_signal_out = 0;
        csr_rs1_imm_signal_out = 0;
        wb_src_signal_out = 0;
        valid_instr_signal_out = 0;
    case(instr_in[6:0])
        `LUI : begin
            alu_op_signal_out           = `ALU_OP_ADD_SUB;
            alu_src_signal_out          = `ALU_SRC_ZERO_IMM;
            imm_signal_out              = `IMM_U_TYPE;
            width_signal_out            =  {`SIGN, `MEM_WIDTH_DWORD}; 
            add_sub_srl_sra_signal_out  = `ADD_SRL;
            rd_write_signal_out         =  1'b1;
            wb_src_signal_out           = `WB_SRC_ALU_RESULT;
            valid_instr_signal_out      =  1'b1;
        end
        `AUIPC : begin
            alu_op_signal_out           = `ALU_OP_ADD_SUB;
            alu_src_signal_out          = `ALU_SRC_PC_IMM;
            imm_signal_out              = `IMM_U_TYPE;
            width_signal_out            =  {`SIGN, `MEM_WIDTH_DWORD}; 
            add_sub_srl_sra_signal_out  = `ADD_SRL;
            rd_write_signal_out         =  1'b1;
            wb_src_signal_out           = `WB_SRC_ALU_RESULT;
            valid_instr_signal_out      =  1'b1;
        end
        `JAL : begin
            alu_op_signal_out           = `ALU_OP_ADD_SUB;
            alu_src_signal_out          = `ALU_SRC_PC_FOUR;
            imm_signal_out              = `IMM_J_TYPE;
            pc_src_signal_out           = `BRANCH_SRC_PC;
            jump_signal_out             =  1'b1;
            add_sub_srl_sra_signal_out  = `ADD_SRL;
            rd_write_signal_out         =  instr_in[11:7] != 5'b00000;
            wb_src_signal_out           = `WB_SRC_ALU_RESULT;
            valid_instr_signal_out      =  1'b1;
        end
        `JALR : begin
            alu_op_signal_out           = `ALU_OP_ADD_SUB;
            alu_src_signal_out          = `ALU_SRC_PC_FOUR;
            imm_signal_out              = `IMM_I_TYPE;
            pc_src_signal_out           = `BRANCH_SRC_R1;
            jump_signal_out             =  1'b1;
            add_sub_srl_sra_signal_out  = `ADD_SRL;
            rd_write_signal_out         =  instr_in[11:7] != 5'b00000;
            wb_src_signal_out           = `WB_SRC_ALU_RESULT;
            valid_instr_signal_out      =  1'b1;
        end
        `BEQ_BNE_BLT_BGE_BLTU_BGEU : begin
            alu_op_signal_out           = `ALU_OP_ADD_SUB;
            alu_src_signal_out          = `ALU_SRC_R1_R2;
            imm_signal_out              = `IMM_B_TYPE;
            width_signal_out            =  {instr_in[13], `MEM_WIDTH_DWORD};
            branch_op_signal_out        =  {instr_in[14], instr_in[12]};
            pc_src_signal_out           = `BRANCH_SRC_PC;
            add_sub_srl_sra_signal_out  = `SUB_SRA;
            valid_instr_signal_out      =  1'b1;
        end
        `LB_LH_LW_LBU_LHU_LWU_LD : begin
            alu_op_signal_out           = `ALU_OP_ADD_SUB;
            alu_src_signal_out          = `ALU_SRC_R1_IMM;
            imm_signal_out              = `IMM_I_TYPE;
            width_signal_out            =  {instr_in[14], instr_in[13], instr_in[12]};
            add_sub_srl_sra_signal_out  = `ADD_SRL;
            rd_write_signal_out         =  1'b1;
            read_signal_out             =  1'b1;
            wb_src_signal_out           = `WB_SRC_DATA_MEM;
            valid_instr_signal_out      =  1'b1;
        end
        `SB_SH_SW_SD : begin
            alu_op_signal_out           = `ALU_OP_ADD_SUB;
            alu_src_signal_out          = `ALU_SRC_R1_IMM;
            imm_signal_out              = `IMM_S_TYPE;
            width_signal_out            =  {instr_in[14], instr_in[13], instr_in[12]};
            add_sub_srl_sra_signal_out  = `ADD_SRL;
            write_signal_out            =  1'b1;
            valid_instr_signal_out      =  1'b1;
        end
        `ADDI_SLTI_SLTIU_XORI_ORI_ANDI_SLLI_SRLI_SRAI : begin
            alu_op_signal_out           =  {instr_in[14], instr_in[13], instr_in[12]};
            alu_src_signal_out          = `ALU_SRC_R1_IMM;
            imm_signal_out              = `IMM_I_TYPE;
            width_signal_out            =  {`SIGN, `MEM_WIDTH_DWORD}; 
            add_sub_srl_sra_signal_out  =  ({instr_in[14], instr_in[13], instr_in[12]} == 3'b000) ? `ADD_SRL : instr_in[30];
            rd_write_signal_out         =  1'b1;
            wb_src_signal_out           = `WB_SRC_ALU_RESULT;
            valid_instr_signal_out      =  1'b1;
        end
        `ADD_SUB_SLL_SLT_SLTU_XOR_SRL_SRA_OR_AND : begin
            alu_op_signal_out           =  {instr_in[14], instr_in[13], instr_in[12]};
            alu_src_signal_out          = `ALU_SRC_R1_R2;
            width_signal_out            =  {`SIGN, `MEM_WIDTH_DWORD}; 
            add_sub_srl_sra_signal_out  =  instr_in[30];
            rd_write_signal_out         =  1'b1;
            wb_src_signal_out           = `WB_SRC_ALU_RESULT;
            valid_instr_signal_out      =  1'b1;
        end
        `FENCE_FENCEI : begin
            valid_instr_signal_out      =  1'b1;
        end
        //`ECALL_EBREAK : begin
        //end
        `CSRRW_CSRRS_CSRRC_CSRRWI_CSRRSI_CSRRCI : begin
            alu_src_signal_out          = `ALU_SRC_R1_IMM;
            imm_signal_out              = `IMM_I_TYPE;
            csr_op_signal_out           =  {instr_in[13], instr_in[12]};
            rd_write_signal_out         =  |instr_in[11:7];
            csr_write_signal_out        =  (`CSR_OP_RW  == {instr_in[13], instr_in[12]}) ? 1'b1 : (|instr_in[19:15] ? 1'b1 : 1'b0);
            csr_read_signal_out         =  instr_in[13] ? 1'b1 : (|instr_in[11:7] ? 1'b1 : 1'b0);
            csr_rs1_imm_signal_out      =  ~instr_in[14];
            wb_src_signal_out           = `WB_SRC_ALU_RESULT;
            valid_instr_signal_out      =  1'b1;
        end
        `ADDIW_SLLIW_SRLIW_SRLIW_SRAIW_ADDW_SUBW_SLLW_SRLW_SRAW : begin
            alu_op_signal_out           =  {instr_in[14], instr_in[13], instr_in[12]};
            alu_src_signal_out          = `ALU_SRC_R1_IMM;
            imm_signal_out              = `IMM_I_TYPE;
            width_signal_out            =  {`SIGN, `MEM_WIDTH_WORD};
            add_sub_srl_sra_signal_out  =  instr_in[30];
            rd_write_signal_out         =  1'b1;
            wb_src_signal_out           = `WB_SRC_ALU_RESULT;
            valid_instr_signal_out      =  1'b1;
        end
        endcase
    end  
endmodule
`endif