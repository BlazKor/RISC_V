`ifndef Opcode_tb
`define Opcode_tb

    //RV32I Base Instruction Set
    `define LUI     32'b????????????????????_?????_0110111
    `define AUIPC   32'b????????????????????_?????_0010111
    `define JAL     32'b????????????????????_?????_1101111
    `define JALR    32'b????????????_?????_000_?????_1100111
    `define BEQ     32'b???????_?????_?????_000_?????_1100011
    `define BNE     32'b???????_?????_?????_001_?????_1100011
    `define BLT     32'b???????_?????_?????_100_?????_1100011
    `define BGE     32'b???????_?????_?????_101_?????_1100011
    `define BLTU    32'b???????_?????_?????_110_?????_1100011
    `define BGEU    32'b???????_?????_?????_111_?????_1100011
    `define LB      32'b????????????_?????_000_?????_0000011
    `define LH      32'b????????????_?????_001_?????_0000011
    `define LW      32'b????????????_?????_010_?????_0000011
    `define LBU     32'b????????????_?????_100_?????_0000011
    `define LHU     32'b????????????_?????_101_?????_0000011
    `define SB      32'b???????_?????_?????_000_?????_0100011
    `define SH      32'b???????_?????_?????_001_?????_0100011
    `define SW      32'b???????_?????_?????_010_?????_0100011
    `define ADDI    32'b????????????_?????_000_?????_0010011
    `define SLTI    32'b????????????_?????_010_?????_0010011
    `define SLTIU   32'b????????????_?????_011_?????_0010011
    `define XORI    32'b????????????_?????_100_?????_0010011
    `define ORI     32'b????????????_?????_110_?????_0010011
    `define ANDI    32'b????????????_?????_111_?????_0010011
    `define SLLI    32'b000000_??????_?????_001_?????_0010011
    `define SRLI    32'b000000_??????_?????_101_?????_0010011
    `define SRAI    32'b010000_??????_?????_101_?????_0010011
    `define ADD     32'b0000000_?????_?????_000_?????_0110011
    `define SUB     32'b0100000_?????_?????_000_?????_0110011
    `define SLL     32'b0000000_?????_?????_001_?????_0110011
    `define SLT     32'b0000000_?????_?????_010_?????_0110011
    `define SLTU    32'b0000000_?????_?????_011_?????_0110011
    `define XOR     32'b0000000_?????_?????_100_?????_0110011
    `define SRL     32'b0000000_?????_?????_101_?????_0110011
    `define SRA     32'b0100000_?????_?????_101_?????_0110011
    `define OR      32'b0000000_?????_?????_110_?????_0110011
    `define AND     32'b0000000_?????_?????_111_?????_0110011
    `define FENCE   32'b0000_????_????_00000_000_00000_0001111
    `define FENCEI  32'b0000_0000_0000_00000_001_00000_0001111
    `define ECALL   32'b000000000000_00000_000_00000_1110011
    `define EBREAK  32'b000000000001_00000_000_00000_1110011
    `define CSRRW   32'b????????????_?????_001_?????_1110011
    `define CSRRS   32'b????????????_?????_010_?????_1110011
    `define CSRRC   32'b????????????_?????_011_?????_1110011
    `define CSRRWI  32'b????????????_?????_101_?????_1110011
    `define CSRRSI  32'b????????????_?????_110_?????_1110011
    `define CSRRCI  32'b????????????_?????_111_?????_1110011
    
    //RV64I Base Instruction Set (in addition to RV32I)
    `define LWU     32'b????????????_?????_110_?????_0000011
    `define LD      32'b????????????_?????_011_?????_0000011
    `define SD      32'b???????_?????_?????_011_?????_0100011
    `define ADDIW   32'b????????????_?????_000_?????_0011011
    `define SLLIW   32'b0000000_?????_?????_001_?????_0011011
    `define SRLIW   32'b0000000_?????_?????_101_?????_0011011
    `define SRAIW   32'b0100000_?????_?????_101_?????_0011011
    `define ADDW    32'b0000000_?????_?????_000_?????_0111011
    `define SUBW    32'b0100000_?????_?????_000_?????_0111011
    `define SLLW    32'b0000000_?????_?????_001_?????_0111011
    `define SRLW    32'b0000000_?????_?????_101_?????_0111011
    `define SRAW    32'b0100000_?????_?????_101_?????_0111011
`endif