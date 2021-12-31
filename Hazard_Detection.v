`ifndef Hazard_Detection
`define Hazard_Detection

module Hazard_Detection (
    input clk_in,
    
    input [4:0] rs1_in,
    input [4:0] rs2_in,
    input [4:0] rd_ID_EX_in,

    input branch_jump_signal_in,
    input branch_pred_signal_in,
    input read_signal_in,
    input return_interrupt_signal_in,
    input interrupt_signal_in,

    output stall_IF_ID_signal_out,
    output stall_EX_signal_out,
    output stall_MEM_signal_out,
    output flush_ID_signal_out,
    output flush_EX_signal_out
);

    reg [4:0] rd_ID_EX_reg = 5'b00000;
    reg read_signal_reg = 0;
    reg flush_EX_signal_reg = 0;

    always @(*) begin
        rd_ID_EX_reg = rd_ID_EX_in;
        read_signal_reg = read_signal_in;
    end
    
    assign stall_load = (read_signal_reg & ((rs1_in == rd_ID_EX_reg) || (rs2_in == rd_ID_EX_reg)));

    always @(posedge clk_in) begin
        flush_EX_signal_reg <= stall_ID_EX;
    end

    assign stall_ID_EX = stall_load ^ flush_EX_signal_reg;
    
    assign flush_EX_signal_out = flush_EX_signal_reg | interrupt_signal_in | return_interrupt_signal_in;
    assign flush_ID_signal_out = (branch_jump_signal_in & ~branch_pred_signal_in) | interrupt_signal_in | return_interrupt_signal_in;

    assign stall_IF_ID_signal_out = stall_ID_EX | interrupt_signal_in | return_interrupt_signal_in;
    assign stall_EX_signal_out = interrupt_signal_in | return_interrupt_signal_in;
    assign stall_MEM_signal_out = interrupt_signal_in;

endmodule
`endif