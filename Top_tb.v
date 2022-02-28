`timescale 1ns / 1ps

`include "Opcode_tb.vh"

module Top_tb();

    reg Clk;

    reg [3:0] external_button_in;
    reg [2:0] external_switch_in;
    reg external_button_start_in;
    
    wire [63:0] pc_Instruction_Fetch_out;
    wire [31:0] instr_Instruction_Fetch_out;
    wire stall_IF_ID_signal_out;
    wire stall_EX_signal_out;
    wire stall_MEM_signal_out;
    wire flush_ID_signal_out;
    wire flush_EX_signal_out;
    wire stacking_signal_out;
    wire unstacking_signal_out;
    wire return_interrupt_signal_out;
    wire interrupt_signal_out;
    wire empty_fifo_signal_out;
    wire [15:0] LEDs;

Top UUT(
    .Clk(Clk),

    .external_button_in(external_button_in),
    .external_switch_in(external_switch_in),
    .external_button_start_in(external_button_start_in),
    
    .pc_Instruction_Fetch_out(pc_Instruction_Fetch_out),
    .instr_Instruction_Fetch_out(instr_Instruction_Fetch_out),

    .stall_IF_ID_signal_out(stall_IF_ID_signal_out),
    .stall_EX_signal_out(stall_EX_signal_out),
    .stall_MEM_signal_out(stall_MEM_signal_out),
    .flush_ID_signal_out(flush_ID_signal_out),
    .flush_EX_signal_out(flush_EX_signal_out),
    .stacking_signal_out(stacking_signal_out),
    .unstacking_signal_out(unstacking_signal_out),
    .return_interrupt_signal_out(return_interrupt_signal_out),
    .interrupt_signal_out(interrupt_signal_out),
    .empty_fifo_signal_out(empty_fifo_signal_out),
    
    .LEDs(LEDs)
);

initial begin 
    Clk = 0; 
    external_button_in = 0; 
    external_switch_in = 0;
    external_button_start_in = 0;
end

always #10 Clk<= ~Clk;

initial begin ;   
    #400
    external_button_in = 4'b0001;
    #20
    external_button_in = 4'b0000;
    #800
    external_button_in = 4'b0010;
    #20
    external_button_in = 4'b0000;
end
always begin

    #20 
    if(interrupt_signal_out) $display (" Interrupt ");
    if(stacking_signal_out) $display (" Stacking ");
    if(unstacking_signal_out) $display (" Unstacking ");
    if(return_interrupt_signal_out)  $display (" Return Interrupt ");
    //if(stall_IF_ID_signal_out) $display ("   Stall IF & ID ");
    //if(flush_EX_signal_out) $display ("   Flush EX ");
    //if(flush_ID_signal_out) $display ("   Flush ID ");
    if(!flush_ID_signal_out  && !flush_EX_signal_out && !stall_IF_ID_signal_out) begin   
    $display (" line nr : %d", ((pc_Instruction_Fetch_out >> 2) + 1) );
    casez(instr_Instruction_Fetch_out)
       `LUI : $display (" LUI: imm = %h ; rd = %h ", instr_Instruction_Fetch_out[31:12], instr_Instruction_Fetch_out[11:7]);
       `AUIPC : $display (" AUPIC: imm = %h ; rd = %h ", instr_Instruction_Fetch_out[31:12], instr_Instruction_Fetch_out[11:7]);
       `JAL : $display (" JAL: imm = %h ; rd = %h ", {instr_Instruction_Fetch_out[20], instr_Instruction_Fetch_out[10:1], instr_Instruction_Fetch_out[11], instr_Instruction_Fetch_out[19:12]}, instr_Instruction_Fetch_out[11:7]);
       `JALR : $display (" jarl x%d, x%d, %d ", instr_Instruction_Fetch_out[11:7], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[31:20]);
       `BEQ : $display (" beq x%d, x%d, %d ", instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[24:20], {instr_Instruction_Fetch_out[31], instr_Instruction_Fetch_out[7], instr_Instruction_Fetch_out[30:25], instr_Instruction_Fetch_out[11:8]});
       `BNE : $display (" BNE: imm = %h ; rs2 = %h ; rs1 = %h ", {instr_Instruction_Fetch_out[31], instr_Instruction_Fetch_out[7], instr_Instruction_Fetch_out[30:25], instr_Instruction_Fetch_out[11:8]}, instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15]);
       `BLT : $display (" BLT: imm = %h ; rs2 = %h ; rs1 = %h ", {instr_Instruction_Fetch_out[31], instr_Instruction_Fetch_out[7], instr_Instruction_Fetch_out[30:25], instr_Instruction_Fetch_out[11:8]}, instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15]);
       `BGE : $display (" BGE: imm = %h ; rs2 = %h ; rs1 = %h ", {instr_Instruction_Fetch_out[31], instr_Instruction_Fetch_out[7], instr_Instruction_Fetch_out[30:25], instr_Instruction_Fetch_out[11:8]}, instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15]);
       `BLTU : $display (" BLTU: imm = %h ; rs2 = %h ; rs1 = %h ", {instr_Instruction_Fetch_out[31], instr_Instruction_Fetch_out[7], instr_Instruction_Fetch_out[30:25], instr_Instruction_Fetch_out[11:8]}, instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15]);
       `BGEU : $display (" BGEU: imm = %h ; rs2 = %h ; rs1 = %h ", {instr_Instruction_Fetch_out[31], instr_Instruction_Fetch_out[7], instr_Instruction_Fetch_out[30:25], instr_Instruction_Fetch_out[11:8]}, instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15]);
       `LB : $display (" LB: imm = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[31:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `LH : $display (" LH: imm = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[31:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `LW : $display (" LW: imm = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[31:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `LBU : $display (" LBU: imm = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[31:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `LHU : $display (" LHU: imm = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[31:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `SB : $display (" SB: imm = %h ; rs2 = %h ; rs1 = %h ", {instr_Instruction_Fetch_out[31:25], instr_Instruction_Fetch_out[11:7]}, instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15]);
       `SH : $display (" sd x%d, %d(x%d) ", instr_Instruction_Fetch_out[24:20], {instr_Instruction_Fetch_out[31:25], instr_Instruction_Fetch_out[11:7]}, instr_Instruction_Fetch_out[19:15]);
       `SW : $display (" SW: imm = %h ; rs2 = %h ; rs1 = %h ", {instr_Instruction_Fetch_out[31:25], instr_Instruction_Fetch_out[11:7]}, instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15]);
       `ADDI : $display (" addi x%d, x%d, %d ", instr_Instruction_Fetch_out[11:7], instr_Instruction_Fetch_out[19:15], $signed(instr_Instruction_Fetch_out[31:20]));       
       `SLTI : $display (" SLTI: imm = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[31:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `SLTIU : $display (" SLTIU: imm = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[31:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `XORI : $display (" XORI: imm = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[31:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `ORI : $display (" ORI: imm = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[31:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `ANDI : $display (" ANDI: imm = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[31:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `SLLI : $display (" SLLI: shamt = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `SRLI : $display (" SRLI: shamt = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `SRAI : $display (" SRAI: shamt = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `ADD : $display (" add x%d, x%d, x%d ", instr_Instruction_Fetch_out[11:7], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[24:20]); 
       `SUB : $display (" sub x%d, x%d, x%d ", instr_Instruction_Fetch_out[11:7], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[24:20]); 
       `SLL : $display (" SLL: rs2 = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);  
       `SLT : $display (" SLT: rs2 = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `SLTU : $display (" SLTU: rs2 = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]); 
       `XOR : $display (" XOR: rs2 = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]); 
       `SRL : $display (" SRL: rs2 = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]); 
       `SRA : $display (" SRA: rs2 = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]); 
       `OR : $display (" OR: rs2 = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `AND : $display (" AND: rs2 = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]); 
       `FENCE : $display (" FENCE: preh = %b ; succ = %b ", instr_Instruction_Fetch_out[25:23], instr_Instruction_Fetch_out[22:20]);   
       `FENCEI : $display (" FENCEI "); 
       `ECALL : $display (" ECALL ");   
       `EBREAK : $display (" EBREAK ");  
       `CSRRW : $display (" csrrw x%d, x%d, x%d", instr_Instruction_Fetch_out[21:17],instr_Instruction_Fetch_out[31:22], instr_Instruction_Fetch_out[11:7]);   
       `CSRRS : $display (" csrrs: csr = %d ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);    
       `CSRRC : $display (" csrrc: csr = %d ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);    
       `CSRRWI : $display (" csrrwi: csr = %d ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `CSRRSI : $display (" csrrsi: csr = %d ; zimm = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);  
       `CSRRCI : $display (" csrrci: csr = %d ; zimm = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);  
       `LWU : $display (" LWU: imm = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[31:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);   
       `LD : $display (" ld x%d, %d(x%d) ", instr_Instruction_Fetch_out[11:7], instr_Instruction_Fetch_out[31:20], instr_Instruction_Fetch_out[19:15]);       
       `SD : $display (" sd x%d, %d(x%d) ", instr_Instruction_Fetch_out[24:20], {instr_Instruction_Fetch_out[31:25], instr_Instruction_Fetch_out[11:7]}, instr_Instruction_Fetch_out[19:15]);
       `ADDIW : $display (" ADDIW: imm = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[31:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `SLLIW : $display (" SLLIW: shamt = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `SRLIW : $display (" SRLIW: shamt = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `SRAIW : $display (" SRAIW: shamt = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);
       `ADDW : $display (" ADDW: rs2 = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);   
       `SUBW : $display (" SUBW: rs2 = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);  
       `SLLW : $display (" SLLW: rs2 = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);  
       `SRLW : $display (" SRLW: rs2 = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);  
       `SRAW : $display ("SRAW: rs2 = %h ; rs1 = %h ; rd = %h ", instr_Instruction_Fetch_out[24:20], instr_Instruction_Fetch_out[19:15], instr_Instruction_Fetch_out[11:7]);  
       default : $display (" Undefined Instruction ");
    endcase
    end
end
endmodule

