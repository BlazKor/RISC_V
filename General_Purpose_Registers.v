`include "Opcodes.vh"

`ifndef General_Purpose_Registers
`define General_Purpose_Registers

module General_Purpose_Registers #( 
    parameter NUM_REG = 32, 
    parameter SIZE_REG = 64 
)(
    input clk_in,
    
    input [63:0] wr_data_in, 
    input [4:0] rs1_in,
    input [4:0] rs2_in,
    input [4:0] rd_in,
    
    input rd_write_signal_in,
    input return_interrupt_signal_in,
    input interrupt_signal_in,
    input return_address_registers_flag_signal_in,
    input stall_signal_in,
    input flush_signal_in,
    
    output reg [63:0] rs1_value_out = 0,
    output reg [63:0] rs2_value_out = 0 
);

    reg [SIZE_REG - 1:0] Regs_reg [0:NUM_REG - 1];

    initial begin
        Regs_reg[0] = 64'h00000000;
        Regs_reg[`FRAME_POINTER] = 64'h88000000;
        Regs_reg[`STACK_POINTER] = 64'h87FFFFF0;
    end
    
    always @(posedge clk_in) begin
        if(~stall_signal_in) begin
            rs1_value_out <= Regs_reg[rs1_in];
            rs2_value_out <= Regs_reg[rs2_in];
        end
        if(~stall_signal_in | interrupt_signal_in) begin
            rs2_value_out <= Regs_reg[rs2_in];
        end
    end
    
    always @(negedge clk_in) begin
        if(~stall_signal_in | (interrupt_signal_in & ~return_address_registers_flag_signal_in) | return_interrupt_signal_in) begin
            if(rd_write_signal_in) begin
                Regs_reg[rd_in] <= wr_data_in;
            end  
        end
    end
endmodule
`endif