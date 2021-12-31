`ifndef Forwarding
`define Forwarding
`include "Opcodes.vh"

module Forwarding (
    input [4:0] rs1_in,    
    input [4:0] rs2_in,
    input [4:0] rd_ID_EX_in,
    input [4:0] rd_EX_MEM_in,
    input [4:0] rd_MEM_WB_in,

    input [2:0] instr_type_signal_in,
    input rd_write_EX_MEM_signal_in,
    input rd_write_MEM_WB_signal_in,
    input jump_ID_EX_signal_in,

    output reg [1:0] alu_mux1_src_signal_out,
    output reg [1:0] alu_mux2_src_signal_out,
    output reg ras_mux_src_signal_out,
    output reg call_mux_src_signal_out
);

    reg [1:0] alu_mux1_src_signal_reg;
    reg [1:0] alu_mux2_src_signal_reg;

    always @(*) begin
        if(jump_ID_EX_signal_in == 1'b1) begin
            alu_mux1_src_signal_reg = 2'b00;
        end
        else begin
            if (rd_write_EX_MEM_signal_in && (rd_EX_MEM_in != 0) && (rd_EX_MEM_in == rs1_in)) begin
                alu_mux1_src_signal_reg = 2'b01; 
            end
            else if(rd_write_MEM_WB_signal_in && (rd_MEM_WB_in != 0) && ~(rd_write_EX_MEM_signal_in && (rd_EX_MEM_in != 0) && (rd_EX_MEM_in == rs1_in)) && (rd_MEM_WB_in == rs1_in)) begin 
                alu_mux1_src_signal_reg = 2'b10;
            end
            else begin
                alu_mux1_src_signal_reg = 2'b00;
            end
        end
    end

    always @(*) begin
        if(jump_ID_EX_signal_in == 1'b1) begin
            alu_mux2_src_signal_reg = 2'b00;
        end
        else begin
            if (rd_write_EX_MEM_signal_in && (rd_EX_MEM_in != 0) && (rd_EX_MEM_in == rs2_in)) begin 
                alu_mux2_src_signal_reg = 2'b01; 
            end
            else if(rd_write_MEM_WB_signal_in && (rd_MEM_WB_in != 0) && ~(rd_write_EX_MEM_signal_in && (rd_EX_MEM_in != 0) && (rd_EX_MEM_in == rs2_in)) && (rd_MEM_WB_in == rs2_in)) begin 
                alu_mux2_src_signal_reg = 2'b10; 
            end
            else begin
                alu_mux2_src_signal_reg = 2'b00;
            end
        end
    end
    
    always @(*) begin
        if(jump_ID_EX_signal_in && ((rd_MEM_WB_in == rs1_in) && (rd_MEM_WB_in != 0))) begin
            call_mux_src_signal_out = 1'b1;
        end
        else begin
            call_mux_src_signal_out = 1'b0;
        end
        if(jump_ID_EX_signal_in && ((rd_MEM_WB_in == rd_ID_EX_in) && (rd_MEM_WB_in != 0))) begin
            ras_mux_src_signal_out = 1'b1;
        end
        else begin
            ras_mux_src_signal_out = 1'b0;
        end
    end
    
    always @(*)
    case (instr_type_signal_in)
        `IMM_I_TYPE : begin
            alu_mux1_src_signal_out <= alu_mux1_src_signal_reg;
            alu_mux2_src_signal_out <= 2'b00;
         end
        `IMM_S_TYPE : begin
            alu_mux1_src_signal_out <= alu_mux1_src_signal_reg;
            alu_mux2_src_signal_out <= alu_mux2_src_signal_reg;
         end
        `IMM_U_TYPE : begin 
            alu_mux1_src_signal_out <= 2'b00;
            alu_mux2_src_signal_out <= 2'b00;
         end
        `IMM_J_TYPE : begin 
            alu_mux1_src_signal_out <= 2'b00;
            alu_mux2_src_signal_out <= 2'b00;
         end
        `IMM_B_TYPE : begin 
            alu_mux1_src_signal_out <= alu_mux1_src_signal_reg;
            alu_mux2_src_signal_out <= alu_mux2_src_signal_reg;        
         end
         default : begin
            alu_mux1_src_signal_out <= alu_mux1_src_signal_reg;
            alu_mux2_src_signal_out <= alu_mux2_src_signal_reg;
        end
    endcase
endmodule
`endif