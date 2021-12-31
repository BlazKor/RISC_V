`ifndef Opcodes
`define Opcodes
    
    //Return_Address_Stac
    `define PUSH               2'b01
    `define POP                2'b10
    
    //General_Purpose_Registers
    `define STACK_POINTER      5'b00010
    `define FRAME_POINTER      5'b01000
    
    //Instruction_Fetch
    `define NON_BRANCH_PC      3'b000
    `define BRANCH_PC          3'b001
    `define BRANCH_PRED_PC     3'b01x
    `define INTERRUPT_PC       3'b1xx
    
    //Control_Unit
    `define NON                1'b1
    `define SIGN               1'b0
    `define UNSIGNED           1'b1
    `define BRANCH_SRC_PC      1'b0
    `define BRANCH_SRC_R1      1'b1
    `define WB_SRC_ALU_RESULT  1'b1
    `define WB_SRC_DATA_MEM    1'b0
    `define SUB_SRA            1'b1
    `define ADD_SRL            1'b0
    
    //Branch
    `define BRANCH_BEQ         2'b00
    `define BRANCH_BNE         2'b01
    `define BRANCH_BLT         2'b10
    `define BRANCH_BGE         2'b11
    `define BRANCH_PC_ACCEPTED 1'b1
    
    //Arithmetic_Logic_Unit 
    `define ALU_OP_ADD_SUB     3'b000
    `define ALU_OP_SLL         3'b001
    `define ALU_OP_SLT         3'b010
    `define ALU_OP_SLTU        3'b011
    `define ALU_OP_XOR         3'b100
    `define ALU_OP_SRL_SRA     3'b101
    `define ALU_OP_OR          3'b110
    `define ALU_OP_AND         3'b111
    
    //Data_Flow_Select 
    `define ALU_SRC_R1_R2      3'b000 
    `define ALU_SRC_R1_IMM     3'b001
    `define ALU_SRC_R1_FOUR    3'b010
    `define ALU_SRC_PC_R2      3'b011
    `define ALU_SRC_PC_IMM     3'b100
    `define ALU_SRC_PC_FOUR    3'b101
    `define ALU_SRC_ZERO_R2    3'b110
    `define ALU_SRC_ZERO_IMM   3'b111
    
    //Control_And_Status_Register
    `define CSR_OP_RW          2'b01
    `define CSR_OP_RS          2'b10
    `define CSR_OP_RC          2'b11
    `define MSIE 3 //machine software interrupt enable
    `define MTIE 7 //machine timer interrupt enable
    `define MEIE 11 //machine external interrupt enable
    `define CSR_RDCYCLE 12'h000
    `define CSR_RDTIME 12'h001
    `define CSR_RDINSTRET 12'h002
    `define CSR_MTIME 12'h003
    `define CSR_MTIMECMP 12'h004
    `define CSR_MIE 12'h005
    `define CSR_MIEPC 12'h006
    `define CSR_MBUTTON_CTRL   12'h00A
    `define CSR_MSWITCH_CTRL   12'h00B

    //Immediate_Generation
    `define IMM_I_TYPE         3'b000
    `define IMM_S_TYPE         3'b001
    `define IMM_U_TYPE         3'b010
    `define IMM_J_TYPE         3'b011
    `define IMM_B_TYPE         3'b100

    //Memory
    `define MEM_WIDTH_BYTE     2'b00
    `define MEM_WIDTH_HWORD    2'b01
    `define MEM_WIDTH_WORD     2'b10
    `define MEM_WIDTH_DWORD    2'b11
    
    //Control_Unit
    `define LUI 7'b0110111
    `define AUIPC 7'b0010111
    `define JAL 7'b1101111
    `define JALR 7'b1100111
    `define BEQ_BNE_BLT_BGE_BLTU_BGEU 7'b1100011
    `define LB_LH_LW_LBU_LHU_LWU_LD 7'b0000011
    `define SB_SH_SW_SD 7'b0100011
    `define ADDI_SLTI_SLTIU_XORI_ORI_ANDI_SLLI_SRLI_SRAI 7'b0010011
    `define ADD_SUB_SLL_SLT_SLTU_XOR_SRL_SRA_OR_AND 7'b0110011
    `define FENCE_FENCEI 7'b0001111
    `define ECALL_EBREAK 7'b1110011
    `define CSRRW_CSRRS_CSRRC_CSRRWI_CSRRSI_CSRRCI 7'b1110011
    `define ADDIW_SLLIW_SRLIW_SRLIW_SRAIW_ADDW_SUBW_SLLW_SRLW_SRAW 7'b0011011

`endif