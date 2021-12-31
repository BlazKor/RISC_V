`include "Opcodes.vh"

`ifndef Memory
`define Memory

module Memory(
    input clk_in,

    input [63:0] alu_result_in,
    input [63:0] rs2_value_in,
    input [63:0] data_read_value_in,
    input [4:0] rd_in,

    input [2:0] width_signal_in,
    input rd_write_signal_in,
    input wb_src_signal_in,
    input read_signal_in,
    input write_signal_in,
    input valid_instr_signal_in,
    input stall_signal_in,
    input flush_signal_in,

    output reg [63:0] wr_data_out = 0,       
    output reg [63:0] rs2_value_out,
    output [9:0] alu_result_out,
    output reg [7:0] mask_out,
    output reg [4:0] rd_out = 0,

    output reg rd_write_signal_out = 0,
    output read_signal_out,
    output write_signal_out,
    output reg valid_instr_signal_out = 0
);

    reg [63:0] ram_data_read_reg;

    always @(*) begin
        rs2_value_out = 0;
        mask_out = 8'b00000000;
    case(width_signal_in[1:0])
        `MEM_WIDTH_BYTE : begin
            case(alu_result_in[2:0])
                3'b000 : begin
                    mask_out = 8'b00000001;
                    rs2_value_out[7:0] = rs2_value_in[7:0];
                    if(width_signal_in[2]) begin
                        ram_data_read_reg = {56'b0, data_read_value_in[7:0]};
                    end 
                    else begin
                        ram_data_read_reg = {{56{data_read_value_in[7]}}, data_read_value_in[7:0]};
                    end
                end
                3'b001 : begin
                    mask_out = 8'b00000010;
                    rs2_value_out[15:8] = rs2_value_in[7:0];
                    if(width_signal_in[2]) begin
                        ram_data_read_reg = {56'b0, data_read_value_in[15:8]};
                    end 
                    else begin       
                        ram_data_read_reg = {{56{data_read_value_in[15]}}, data_read_value_in[15:8]};
                    end
                end
                3'b010 : begin
                    mask_out = 8'b00000100;
                    rs2_value_out[23:16] = rs2_value_in[7:0];
                    if(width_signal_in[2]) begin
                        ram_data_read_reg = {56'b0, data_read_value_in[23:16]};
                    end 
                    else begin
                        ram_data_read_reg = {{56{data_read_value_in[23]}}, data_read_value_in[23:16]};
                    end
                end
                3'b011 : begin
                    mask_out = 8'b00001000;
                    rs2_value_out[31:24] = rs2_value_in[7:0];
                    if(width_signal_in[2]) begin
                        ram_data_read_reg = {56'b0, data_read_value_in[31:24]};
                    end 
                    else begin
                        ram_data_read_reg = {{56{data_read_value_in[31]}}, data_read_value_in[31:24]};
                    end
                end
                3'b100 : begin
                    mask_out = 8'b00010000;
                    rs2_value_out[39:32] = rs2_value_in[7:0];
                    if(width_signal_in[2]) begin
                        ram_data_read_reg = {56'b0, data_read_value_in[39:32]};
                    end 
                    else begin
                        ram_data_read_reg = {{56{data_read_value_in[39]}}, data_read_value_in[39:32]};
                    end
                end
                3'b101 : begin
                    mask_out = 8'b00100000;
                    rs2_value_out[47:40] = rs2_value_in[7:0];
                    if(width_signal_in[2]) begin
                        ram_data_read_reg = {56'b0, data_read_value_in[47:40]};
                    end 
                    else begin
                        ram_data_read_reg = {{56{data_read_value_in[47]}}, data_read_value_in[47:40]};
                    end
                end
                3'b110 : begin
                    mask_out = 8'b01000000;
                    rs2_value_out[55:48] = rs2_value_in[7:0];
                    if(width_signal_in[2]) begin
                        ram_data_read_reg = {56'b0, data_read_value_in[55:48]}; 
                    end 
                    else begin
                        ram_data_read_reg = {{56{data_read_value_in[55]}}, data_read_value_in[55:48]};
                    end
                end
                3'b111 : begin
                    mask_out = 8'b10000000;
                    rs2_value_out[63:56] = rs2_value_in[7:0];
                    if(width_signal_in[2]) begin
                        ram_data_read_reg = {56'b0, data_read_value_in[63:56]};
                    end 
                    else begin
                        ram_data_read_reg = {{56{data_read_value_in[63]}}, data_read_value_in[63:56]};
                    end
                end
            endcase
        end
        `MEM_WIDTH_HWORD : begin
             case(alu_result_in[2:1])
                2'b00 : begin
                    mask_out = 8'b00000011;
                    rs2_value_out[15:0] = rs2_value_in[15:0];
                    if(width_signal_in[2]) begin
                        ram_data_read_reg = {48'b0, data_read_value_in[15:0]};
                    end 
                    else begin
                        ram_data_read_reg = {{48{data_read_value_in[15]}}, data_read_value_in[15:0]};
                    end
                end
                2'b01 : begin
                    mask_out = 8'b00001100;
                    rs2_value_out[31:16] = rs2_value_in[15:0];
                    if(width_signal_in[2]) begin
                        ram_data_read_reg = {48'b0, data_read_value_in[31:16]};
                    end 
                    else begin
                        ram_data_read_reg = {{48{data_read_value_in[31]}}, data_read_value_in[31:16]};
                    end
                end
                2'b10 : begin
                    mask_out = 8'b00110000;
                    rs2_value_out[47:32] = rs2_value_in[15:0];
                    if(width_signal_in[2]) begin
                        ram_data_read_reg = {48'b0, data_read_value_in[47:32]};
                    end 
                    else begin
                        ram_data_read_reg = {{48{data_read_value_in[47]}}, data_read_value_in[47:32]};
                    end
                end
                2'b11 : begin
                    mask_out = 8'b11000000;
                    rs2_value_out[63:48] = rs2_value_in[15:0];
                    if(width_signal_in[2]) begin
                        ram_data_read_reg = {48'b0, data_read_value_in[63:48]};
                    end 
                    else begin
                        ram_data_read_reg = {{48{data_read_value_in[63]}}, data_read_value_in[63:48]};
                    end
                end
            endcase
        end
        `MEM_WIDTH_WORD : begin
             case(alu_result_in[2])
                1'b0 : begin
                    mask_out = 8'b00001111;
                    rs2_value_out[31:0] = rs2_value_in[31:0];
                    if(width_signal_in[2]) begin
                        ram_data_read_reg = {32'b0, data_read_value_in[31:0]};
                    end 
                    else begin
                        ram_data_read_reg = {{32{data_read_value_in[31]}}, data_read_value_in[31:0]};
                    end
                end
                1'b1 : begin
                    mask_out = 8'b11110000;
                    rs2_value_out[63:32] = rs2_value_in[31:0];
                    if(width_signal_in[2]) begin
                        ram_data_read_reg = {32'b0, data_read_value_in[63:48]};
                    end
                    else begin
                        ram_data_read_reg = {{32{data_read_value_in[63]}}, data_read_value_in[63:32]};
                    end
                end
            endcase
        end
        `MEM_WIDTH_DWORD : begin
            mask_out = 8'b11111111;
            rs2_value_out = rs2_value_in;
            ram_data_read_reg = data_read_value_in;
        end
    endcase
    end
    
    assign alu_result_out = alu_result_in[13:3];
    assign write_signal_out = write_signal_in;
    assign read_signal_out = stall_signal_in ? 0 : read_signal_in;
    
    always @(posedge clk_in) begin
        if(!stall_signal_in) begin
            wr_data_out <= wb_src_signal_in ? alu_result_in : ram_data_read_reg;
            rd_out <= rd_in;
        end
        if(!flush_signal_in) begin
                rd_write_signal_out <= rd_write_signal_in;
                valid_instr_signal_out <= valid_instr_signal_in;
            end 
            else begin
                rd_write_signal_out <= 0;
                valid_instr_signal_out <= 0;
            end
    end
endmodule
`endif