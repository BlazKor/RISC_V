`include "Opcodes.vh"
//`include "Branch_Predictor.v"
`include "Stacking_Unit.v"
`include "Hazard_Detection.v"
`include "Forwarding.v"
`include "Instruction_Fetch.v"
`include "Instruction_Decode.v"
`include "Execution.v"
`include "Memory.v"
`include "External_RAM.v"

`ifndef Top
`define Top

module Top (
    input Clk,

    input [3:0] external_button_in,
    input [2:0] external_switch_in,
    input external_button_start_in,
    
    output [63:0] pc_Instruction_Fetch_out,
    output [31:0] instr_Instruction_Fetch_out,
    
    output stacking_signal_out,
    output unstacking_signal_out,
    output return_interrupt_signal_out,
    output stall_IF_ID_signal_out,
    output stall_EX_signal_out,
    output stall_MEM_signal_out,
    output flush_ID_signal_out,
    output flush_EX_signal_out,
    output interrupt_signal_out,
    output empty_fifo_signal_out,
    
    output [15:0] LEDs
);

    wire [63:0] pc_Instruction_Fetch;
    wire [31:0] instr_Instruction_Fetch;

    wire [63:0] rs1_value_Instruction_Decode;
    wire [63:0] rs2_value_Instruction_Decode;
    wire [63:0] imm_value_Instruction_Decode;
    wire [63:0] pc_Instruction_Decode;
    wire [4:0] rs1_Instruction_Decode;
    wire [4:0] rs2_Instruction_Decode;
    wire [4:0] rd_Instruction_Decode;
    wire [2:0] alu_op_signal_Instruction_Decode;
    wire [2:0] alu_src_signal_Instruction_Decode;
    wire [2:0] width_signal_Instruction_Decode;
    wire [2:0] imm_signal_Instruction_Decode;
    wire [1:0] branch_op_signal_Instruction_Decode;
    wire [1:0] csr_op_signal_Instruction_Decode;
    wire pc_src_signal_Instruction_Decode;
    wire jump_signal_Instruction_Decode;
    wire add_sub_srl_sra_signal_Instruction_Decode;
    wire rd_write_signal_Instruction_Decode;
    wire read_signal_Instruction_Decode;
    wire write_signal_Instruction_Decode;
    wire csr_write_signal_Instruction_Decode;
    wire csr_read_signal_Instruction_Decode;
    wire csr_rs1_imm_signal_Instruction_Decode;
    wire wb_src_signal_Instruction_Decode;
    wire valid_instr_signal_Instruction_Decode;
    wire flush_signal_Instruction_Decode;
    
    wire [63:0] pc_Execution;
    wire [63:0] alu_result_Execution;
    wire [63:0] rs2_value_Execution;
    wire [63:0] csr_mepc_Execution;
    wire [4:0] rd_Execution;
    wire [2:0] width_signal_Execution;
    wire branch_jump_signal_Execution;
    wire rd_write_signal_Execution;
    wire read_signal_Execution;
    wire write_signal_Execution;
    wire wb_src_signal_Execution;
    wire valid_instr_signal_Execution;
    wire flush_signal_Execution;
    wire timer_interrupt_trigger_Execution;
    wire csr_mie_mtie_out_Execution;
    wire csr_mie_meie_out_Execution;
        
    wire [63:0] wr_data_Memory;
    wire [63:0] rs2_value_Memory;
    wire [9:0] alu_result_Memory;
    wire [7:0] mask_Memory;
    wire [4:0] rd_Memory;
    wire rd_write_signal_Memory;
    wire read_signal_Memory;
    wire write_signal_Memory;
    wire valid_instr_signal_Memory;
    wire flush_signal_Memory;
    
    wire [1:0] alu_mux1_src_signal_Forwarding;
    wire [1:0] alu_mux2_src_signal_Forwarding;
    wire [1:0] alu_mux3_src_signal_Forwarding;
    wire ras_mux_src_signal_Forwarding;
    wire call_mux_src_signal_Forwarding;
    
    wire [63:0] memory_address_Stacking_Unit;
    wire [4:0] register_addres_Stacking_Unit;
    wire write_signal_Stacking_Unit;
    wire read_signal_Stacking_Unit;
    wire interrupt_signal_Stacking_Unit;
    wire return_interrupt_signal_Stacking_Unit;
    wire interrupt_pending_signal_Stacking_Unit;

    wire return_address_registers_flag_signal_Stacking_Unit;
    wire return_pipeline_registers_signal_Stacking_Unit;
    
    wire branch_pred_signal_Hazard_Detection;
    wire stall_IF_ID_signal_Hazard_Detection;
    wire stall_EX_signal_Hazard_Detection;
    wire stall_MEM_signal_Hazard_Detection;
    wire flush_ID_signal_Hazard_Detection;
    wire flush_EX_signal_Hazard_Detection;
    wire flush_MEM_signal_Hazard_Detection;

    wire [63:0] branch_pc_pred_Branch_Predictor;
    wire [63:0] pc_Branch_Predictor;
    wire [31:0] inst_Branch_Predictor;
    wire pred_signal_Branch_Predictor;
    wire return_pred_signal_Branch_Predictor;
    wire branch_pred_signal_Branch_Predictor;
    
    wire [63:0] data_read_value_External_RAM;
    
    reg [95:0] Instruction_Fetch_interrupt_reg;
    reg [310:0] Instruction_Decode_interrupt_reg;
    reg [24:0] Instruction_Decode_interrupt_signal_reg;
    reg [196:0] Execution_interrupt_reg;
    reg [7:0] Execution_interrupt_signal_reg;
    reg [201:0] Memory_interrupt_reg;
    reg [3:0] Memory_interrupt_signal_reg;
    reg [63:0] External_RAM_interrupt_reg;
    reg external_button_start_reg = 0;
    wire interrupt_signal_Interrupt_Controller;
    wire empty_fifo_signal_Interrupt_Controller;
    wire [63:0] interrupt_pc_out_Interrupt_Controller;
    
    assign pc_Instruction_Fetch_out = pc_Instruction_Fetch;
    assign instr_Instruction_Fetch_out = instr_Instruction_Fetch;
    assign stacking_signal_out = interrupt_signal_Stacking_Unit;
    assign unstacking_signal_out = return_interrupt_signal_Stacking_Unit;
    assign return_interrupt_signal_out = return_pipeline_registers_signal_Stacking_Unit;
    assign stall_IF_ID_signal_out = stall_IF_ID_signal_Hazard_Detection;
    assign stall_EX_signal_out = stall_EX_signal_Hazard_Detection;
    assign stall_MEM_signal_out = stall_MEM_signal_Hazard_Detection;
    assign flush_ID_signal_out = flush_ID_signal_Hazard_Detection;
    assign flush_EX_signal_out = flush_EX_signal_Hazard_Detection;

    assign empty_fifo_signal_out = empty_fifo_signal_Interrupt_Controller;
    assign interrupt_signal_out = interrupt_signal_Interrupt_Controller;
    
    
Branch_Predictor Branch_Predictor (
    .clk_in(Clk),
    
    .pc_in(pc_Instruction_Fetch),
    .instr_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Fetch_interrupt_reg[95:64] : instr_Instruction_Fetch),
    
    .branch_type_signal_in({width_signal_Instruction_Decode[2], branch_op_signal_Instruction_Decode}),
    .branch_jump_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_signal_reg[5] : branch_jump_signal_Execution),
    .jump_signal_in(jump_signal_Instruction_Decode),
    .interrupt_signal_in(interrupt_signal_Interrupt_Controller & empty_fifo_signal_Interrupt_Controller),
    
    .branch_pc_pred_out(branch_pc_pred_Branch_Predictor),
    .pc_out(pc_Branch_Predictor),
    .inst_out(inst_Branch_Predictor),
    
    .pred_signal_out(pred_signal_Branch_Predictor),
    .branch_pred_signal_out(branch_pred_signal_Branch_Predictor),
    .return_pred_signal_out(return_pred_signal_Branch_Predictor)
);

Stacking_Unit Stacking_Unit (
    .clk_in(Clk),
    
    .rd_in(return_pipeline_registers_signal_Stacking_Unit ? Memory_interrupt_reg[201:197] : rd_Memory),  
    
    .rd_write_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Memory_interrupt_signal_reg[0] : rd_write_signal_Memory),
    .interrupt_signal_in(interrupt_signal_Interrupt_Controller),
    .return_interrupt_signal_in((csr_mepc_Execution == pc_Execution) & interrupt_pending_signal_Stacking_Unit),

    .memory_address_out(memory_address_Stacking_Unit),
    .register_addres_out(register_addres_Stacking_Unit),
    
    .write_signal_out(write_signal_Stacking_Unit),
    .read_signal_out(read_signal_Stacking_Unit),
    .interrupt_signal_out(interrupt_signal_Stacking_Unit),
    .return_interrupt_signal_out(return_interrupt_signal_Stacking_Unit),
    .return_address_registers_flag_signal_out(return_address_registers_flag_signal_Stacking_Unit),
    .return_pipeline_registers_signal_out(return_pipeline_registers_signal_Stacking_Unit),
    .interrupt_pending_signal_out(interrupt_pending_signal_Stacking_Unit)
);

Hazard_Detection Hazard_Detection (
    .clk_in(Clk),

    .rs1_in(instr_Instruction_Fetch[19:15]),
    .rs2_in(instr_Instruction_Fetch[24:20]),
    .rd_ID_EX_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_reg[310:306] : rd_Instruction_Decode),
    
    .branch_jump_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_signal_reg[5] : branch_jump_signal_Execution),    
    //.branch_pred_signal_in(pred_signal_Branch_Predictor),
    .branch_pred_signal_in(1'b0),
    .read_signal_in(read_signal_Instruction_Decode),
    .return_interrupt_signal_in(return_interrupt_signal_Stacking_Unit),
    .interrupt_signal_in(interrupt_signal_Stacking_Unit),

    .stall_IF_ID_signal_out(stall_IF_ID_signal_Hazard_Detection),
    .stall_EX_signal_out(stall_EX_signal_Hazard_Detection),
    .stall_MEM_signal_out(stall_MEM_signal_Hazard_Detection),
    .flush_ID_signal_out(flush_ID_signal_Hazard_Detection),
    .flush_EX_signal_out(flush_EX_signal_Hazard_Detection)
);

Forwarding Forwarding (
    .rs1_in(rs1_Instruction_Decode),          
    .rs2_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_reg[305:301] : rs2_Instruction_Decode),
    .rd_ID_EX_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_reg[310:306] : rd_Instruction_Decode),
    .rd_EX_MEM_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_reg[196:192] : rd_Execution),
    .rd_MEM_WB_in(return_pipeline_registers_signal_Stacking_Unit ? Memory_interrupt_reg[201:197] : rd_Memory),
    
    .instr_type_signal_in(imm_signal_Instruction_Decode),                  
    .rd_write_EX_MEM_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_signal_reg[1] : rd_write_signal_Execution),
    .rd_write_MEM_WB_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Memory_interrupt_signal_reg[0] : rd_write_signal_Memory),
    .jump_ID_EX_signal_in(jump_signal_Instruction_Decode),
    
    .alu_mux1_src_signal_out(alu_mux1_src_signal_Forwarding), 
    .alu_mux2_src_signal_out(alu_mux2_src_signal_Forwarding),
    .alu_mux3_src_signal_out(alu_mux3_src_signal_Forwarding),
    .ras_mux_src_signal_out(ras_mux_src_signal_Forwarding),
    .call_mux_src_signal_out(call_mux_src_signal_Forwarding)
);

Instruction_Fetch Instruction_Fetch (
    .clk_in(Clk),
    
    .branch_pc_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_reg[63:0] : pc_Execution),
    .branch_pc_pred_in(pc_Branch_Predictor),
    //.branch_pc_pred_in(64'b0),
    .interrupt_pc_in(external_button_start_in ? 64'b100 : interrupt_pc_out_Interrupt_Controller),
    
    .branch_jump_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_signal_reg[5] : (branch_pred_signal_Branch_Predictor ? 1'b0 : branch_jump_signal_Execution)),
    //.branch_jump_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_signal_reg[5] : branch_jump_signal_Execution),
    .branch_pred_signal_in(pred_signal_Branch_Predictor),  
    //.branch_pred_signal_in(1'b0),  
    .interrupt_signal_in(external_button_start_in | interrupt_signal_Interrupt_Controller),
    .interrupt_pending_signal_in(write_signal_Stacking_Unit),
    .stall_signal_in(stall_IF_ID_signal_Hazard_Detection),
    
    .pc_out(pc_Instruction_Fetch),
    .instr_out(instr_Instruction_Fetch)
);

    always @(posedge Clk) begin
        if(interrupt_signal_Interrupt_Controller) begin
            Instruction_Fetch_interrupt_reg[63:0] = pc_Instruction_Fetch;
            Instruction_Fetch_interrupt_reg[95:64] = instr_Instruction_Fetch; 
        end
    end

Instruction_Decode Instruction_Decode (
    .clk_in(Clk),
    
    .wr_data_in(return_pipeline_registers_signal_Stacking_Unit ? Memory_interrupt_reg[63:0] : wr_data_Memory),
    .pc_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Fetch_interrupt_reg[63:0] : (return_pred_signal_Branch_Predictor ? pc_Branch_Predictor : pc_Instruction_Fetch)),
    //.pc_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Fetch_interrupt_reg[63:0] : pc_Instruction_Fetch),
    .csr_mepc_in(csr_mepc_Execution),
    .instr_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Fetch_interrupt_reg[95:64] : (return_pred_signal_Branch_Predictor ? inst_Branch_Predictor : instr_Instruction_Fetch)),
    //.instr_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Fetch_interrupt_reg[95:64] : instr_Instruction_Fetch),
    .rd_in(return_pipeline_registers_signal_Stacking_Unit ? Memory_interrupt_reg[201:197] : rd_Memory),
    .register_addres_in(register_addres_Stacking_Unit),

    .rd_write_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Memory_interrupt_signal_reg[0] : rd_write_signal_Memory),
    .return_interrupt_signal_in(return_interrupt_signal_Stacking_Unit),
    .interrupt_signal_in(interrupt_signal_Stacking_Unit),
    .return_address_registers_flag_signal_in(return_address_registers_flag_signal_Stacking_Unit),
    .stall_signal_in(stall_IF_ID_signal_Hazard_Detection),
    .flush_signal_in(flush_ID_signal_Hazard_Detection),

    .rs1_value_out(rs1_value_Instruction_Decode),
    .rs2_value_out(rs2_value_Instruction_Decode),
    .imm_value_out(imm_value_Instruction_Decode),    
    .pc_out(pc_Instruction_Decode),
    .rs1_out(rs1_Instruction_Decode),
    .rs2_out(rs2_Instruction_Decode),  
    .rd_out(rd_Instruction_Decode),
 
    .alu_op_signal_out(alu_op_signal_Instruction_Decode),
    .alu_src_signal_out(alu_src_signal_Instruction_Decode),
    .width_signal_out(width_signal_Instruction_Decode),
    .imm_signal_out(imm_signal_Instruction_Decode),
    .branch_op_signal_out(branch_op_signal_Instruction_Decode),
    .csr_op_signal_out(csr_op_signal_Instruction_Decode),
    .pc_src_signal_out(pc_src_signal_Instruction_Decode),
    .jump_signal_out(jump_signal_Instruction_Decode),
    .rd_write_signal_out(rd_write_signal_Instruction_Decode),
    .add_sub_srl_sra_signal_out(add_sub_srl_sra_signal_Instruction_Decode),
    .read_signal_out(read_signal_Instruction_Decode),
    .write_signal_out(write_signal_Instruction_Decode),
    .csr_write_signal_out(csr_write_signal_Instruction_Decode),
    .csr_read_signal_out(csr_read_signal_Instruction_Decode),
    .csr_rs1_imm_signal_out(csr_rs1_imm_signal_Instruction_Decode),
    .wb_src_signal_out(wb_src_signal_Instruction_Decode),
    .valid_instr_signal_out(valid_instr_signal_Instruction_Decode),
    .flush_signal_out(flush_signal_Instruction_Decode)
);

    always @(posedge Clk) begin
        if(interrupt_signal_Interrupt_Controller) begin
            Instruction_Decode_interrupt_reg[63:0] = rs1_value_Instruction_Decode;
            Instruction_Decode_interrupt_reg[127:64] = rs2_value_Instruction_Decode;
            Instruction_Decode_interrupt_reg[191:128] = imm_value_Instruction_Decode;
            Instruction_Decode_interrupt_reg[255:192] = pc_Instruction_Decode;
            Instruction_Decode_interrupt_reg[300:256] = rs1_Instruction_Decode;
            Instruction_Decode_interrupt_reg[305:301] = rs2_Instruction_Decode;
            Instruction_Decode_interrupt_reg[310:306] = rd_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[2:0] = alu_op_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[5:3] = alu_src_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[8:6] = width_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[10:9] = branch_op_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[12:11] = csr_op_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[13] = pc_src_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[14] = jump_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[15] = rd_write_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[16] = add_sub_srl_sra_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[17] = read_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[18] = write_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[19] = csr_write_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[20] = csr_read_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[21] = csr_rs1_imm_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[22] = wb_src_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[23] = valid_instr_signal_Instruction_Decode;
            Instruction_Decode_interrupt_signal_reg[24] = flush_signal_Instruction_Decode;
        end
    end

Execution Execution (
    .clk_in(Clk),
    
    .pc_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_reg[255:192] : pc_Instruction_Decode),
    .alu_result_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_reg[127:64] : alu_result_Execution),
    .wr_data_in(return_pipeline_registers_signal_Stacking_Unit ? Memory_interrupt_reg[63:0] : wr_data_Memory),
    .rs1_value_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_reg[63:0] : rs1_value_Instruction_Decode),  
    .rs2_value_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_reg[127:64] : rs2_value_Instruction_Decode),  
    .imm_value_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_reg[191:128] : imm_value_Instruction_Decode),
    .instr_address_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Fetch_interrupt_reg[63:0] : pc_Instruction_Fetch),
    .rs1_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_reg[260:256] : rs1_Instruction_Decode),
    .rd_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_reg[310:306] : rd_Instruction_Decode),
    
    .alu_op_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[2:0] : alu_op_signal_Instruction_Decode),
    .alu_src_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[5:3] : alu_src_signal_Instruction_Decode),
    .width_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[8:6] : width_signal_Instruction_Decode),
    .branch_op_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[10:9] : branch_op_signal_Instruction_Decode),
    .csr_op_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[12:11] : csr_op_signal_Instruction_Decode),
    .alu_mux1_src_signal_in(alu_mux1_src_signal_Forwarding),
    .alu_mux2_src_signal_in(alu_mux2_src_signal_Forwarding),
    .alu_mux3_src_signal_in(alu_mux3_src_signal_Forwarding),
    .ras_mux_src_signal_in(ras_mux_src_signal_Forwarding),
    .call_mux_src_signal_in(call_mux_src_signal_Forwarding),
    .pc_src_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[13] : pc_src_signal_Instruction_Decode),
    .jump_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[14] : jump_signal_Instruction_Decode),
    .add_sub_srl_sra_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[15] : add_sub_srl_sra_signal_Instruction_Decode),
    .rd_write_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[15] : rd_write_signal_Instruction_Decode),
    .read_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[17] : read_signal_Instruction_Decode),
    .write_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[18] : write_signal_Instruction_Decode),
    .csr_write_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[19] : csr_write_signal_Instruction_Decode),
    .csr_read_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[20] : csr_read_signal_Instruction_Decode),  
    .csr_rs1_imm_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[21] : csr_rs1_imm_signal_Instruction_Decode),
    .wb_src_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[22] : wb_src_signal_Instruction_Decode),
    .valid_instr_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[23] : valid_instr_signal_Instruction_Decode),
    .wb_valid_instr_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Memory_interrupt_signal_reg[3] : valid_instr_signal_Memory),
    .interrupt_signal_in(interrupt_signal_Interrupt_Controller),
    .return_interrupt_signal_in(return_interrupt_signal_Stacking_Unit),
    .return_address_registers_flag_signal_in(return_address_registers_flag_signal_Stacking_Unit),
    .stacking_signal_in(interrupt_signal_Stacking_Unit | write_signal_Stacking_Unit),
    .stall_signal_in(stall_EX_signal_Hazard_Detection),
    .flush_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Instruction_Decode_interrupt_signal_reg[24] : (flush_EX_signal_Hazard_Detection | flush_signal_Instruction_Decode)),
    
    .pc_out(pc_Execution),
    .alu_result_out(alu_result_Execution),       
    .rs2_value_out(rs2_value_Execution),
    .csr_mepc_out(csr_mepc_Execution),
    .led_out(LEDs),
    .rd_out(rd_Execution),
    
    .width_signal_out(width_signal_Execution),
    .branch_jump_signal_out(branch_jump_signal_Execution),
    .rd_write_signal_out(rd_write_signal_Execution),
    .read_signal_out(read_signal_Execution),
    .write_signal_out(write_signal_Execution),
    .wb_src_signal_out(wb_src_signal_Execution),
    .valid_instr_signal_out(valid_instr_signal_Execution),
    .flush_signal_out(flush_signal_Execution),
    .timer_interrupt_trigger_out(timer_interrupt_trigger_Execution),
    .csr_mie_mtie_out(csr_mie_mtie_out_Execution),
    .csr_mie_meie_out(csr_mie_meie_out_Execution)
);

   always @(posedge Clk) begin
        if(interrupt_signal_Interrupt_Controller) begin
            Execution_interrupt_reg[63:0] = pc_Execution;
            Execution_interrupt_reg[127:64] = alu_result_Execution;  
            Execution_interrupt_reg[191:128] = rs2_value_Execution;
            Execution_interrupt_reg[196:192] = rd_Execution;
            Execution_interrupt_signal_reg[0] = width_signal_Execution;
            Execution_interrupt_signal_reg[1] = rd_write_signal_Execution;
            Execution_interrupt_signal_reg[2] = read_signal_Execution;
            Execution_interrupt_signal_reg[3] = write_signal_Execution;
            Execution_interrupt_signal_reg[4] = wb_src_signal_Execution;
            Execution_interrupt_signal_reg[5] = branch_jump_signal_Execution;
            Execution_interrupt_signal_reg[6] = valid_instr_signal_Execution;
            Execution_interrupt_signal_reg[7] = flush_signal_Execution;
        end
    end

Memory Memory (
    .clk_in(Clk),
    
    .alu_result_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_reg[127:64] : ((write_signal_Stacking_Unit | read_signal_Stacking_Unit) ? memory_address_Stacking_Unit : alu_result_Execution)),   
    .rs2_value_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_reg[191:128] : (write_signal_Stacking_Unit ? rs2_value_Instruction_Decode : rs2_value_Execution)),    
    .data_read_value_in(return_pipeline_registers_signal_Stacking_Unit ? External_RAM_interrupt_reg[63:0] : data_read_value_External_RAM),
    .rd_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_reg[196:192] : (read_signal_Stacking_Unit ? register_addres_Stacking_Unit : rd_Execution)),

    .width_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_signal_reg[0] : ((read_signal_Stacking_Unit | write_signal_Stacking_Unit) ? {`UNSIGNED, `MEM_WIDTH_DWORD} : width_signal_Execution)),
    .rd_write_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_signal_reg[1] : (interrupt_signal_Stacking_Unit ? 1'b0 : (read_signal_Stacking_Unit ? 1'b1 : rd_write_signal_Execution))),
    .wb_src_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_signal_reg[4] : (read_signal_Stacking_Unit ? `WB_SRC_DATA_MEM : wb_src_signal_Execution)),
    .read_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_signal_reg[2] : (read_signal_Stacking_Unit ? 1'b1 : read_signal_Execution)),
    .write_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_signal_reg[3] : (write_signal_Stacking_Unit ? 1'b1 : write_signal_Execution)),
    .valid_instr_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_signal_reg[6] : valid_instr_signal_Execution),
    .interrupt_signal_in(interrupt_signal_Interrupt_Controller),
    .stall_signal_in(stall_MEM_signal_Hazard_Detection),
    .flush_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Execution_interrupt_signal_reg[7] :(read_signal_Stacking_Unit ? 1'b0 : flush_signal_Execution)),
 
    .wr_data_out(wr_data_Memory),       
    .rs2_value_out(rs2_value_Memory),    
    .alu_result_out(alu_result_Memory),
    .mask_out(mask_Memory),
    .rd_out(rd_Memory),
    
    .rd_write_signal_out(rd_write_signal_Memory),
    .read_signal_out(read_signal_Memory),
    .write_signal_out(write_signal_Memory),
    .valid_instr_signal_out(valid_instr_signal_Memory)
);

    always @(posedge Clk) begin
        if(interrupt_signal_Interrupt_Controller) begin
            Memory_interrupt_reg[63:0] = wr_data_Memory;
            Memory_interrupt_reg[127:64] = rs2_value_Memory;
            Memory_interrupt_reg[136:128] = alu_result_Memory;
            Memory_interrupt_reg[196:192] = mask_Memory; 
            Memory_interrupt_reg[201:197] = rd_Memory;
            Memory_interrupt_signal_reg[0] = rd_write_signal_Memory;
            Memory_interrupt_signal_reg[1] = read_signal_Memory;
            Memory_interrupt_signal_reg[2] = write_signal_Memory;
            Memory_interrupt_signal_reg[3] = valid_instr_signal_Memory;
        end
    end

External_RAM External_RAM (
    .clk_in(Clk),
    
    .address_in(return_pipeline_registers_signal_Stacking_Unit ? Memory_interrupt_reg[136:128] : alu_result_Memory),
    .value_in(return_pipeline_registers_signal_Stacking_Unit ? Memory_interrupt_reg[127:64] : rs2_value_Memory),
    .mask_in(return_pipeline_registers_signal_Stacking_Unit ? Memory_interrupt_reg[196:192] : mask_Memory),
    
    .write_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Memory_interrupt_signal_reg[2] : write_signal_Memory),
    .read_signal_in(return_pipeline_registers_signal_Stacking_Unit ? Memory_interrupt_signal_reg[1] : read_signal_Memory),
       
    .data_read_value_out(data_read_value_External_RAM)
);

    always @(posedge Clk) begin
        if(interrupt_signal_Interrupt_Controller) begin
            External_RAM_interrupt_reg[63:0] = data_read_value_External_RAM;
        end
    end
    
Interrupt_Controller2 Interrupts(
    .clk_in(Clk),
    
    .timer_interrupt_trigger(timer_interrupt_trigger_Execution),
    .interrupt_enable(1'b1),
    .external_button(external_button_in),
    .external_switch(external_switch_in),
    .csr_mbutton_ctrl_in(4'b1111),
    .csr_mswitch_ctrl_in(3'b111),
    .interrupt_pending(interrupt_pending_signal_Stacking_Unit),
    
    .csr_meie_in(1'b1),
    .csr_mtie_in(csr_mie_mtie_out_Execution),
    
    .interrupt_pc_out(interrupt_pc_out_Interrupt_Controller),
    .empty_fifo_out(empty_fifo_signal_Interrupt_Controller),
    .interrupt_signal(interrupt_signal_Interrupt_Controller)
);

endmodule
`endif