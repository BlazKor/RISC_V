`include "Opcodes.vh"

`ifndef Return_Address_Stack
`define Return_Address_Stack

module Return_Address_Stack(
    input clk_in,
    
    input [63:0] return_address_reg_value_in,
    input [4:0] rs1_in,
    input [4:0] rd_in,
    
    input jalr_inst_signal_in,
    input jump_signal_in,
    input interrupt_signal_in,
    input return_address_registers_flag_signal_in,
    
    output reg [63:0] return_address_out = 0,
    
    output return_signal_out
);
    
    reg [63:0] Stack_reg [0:15];
    
    reg [3:0] stack_pointer_reg = 4'b0000;
    reg [3:0] pointer_pop_push_reg = 4'b1111;
    
    wire [3:0] pointer_pop_push;

    reg stack_enable_x1_reg = 0;
    reg stack_enable_x5_reg = 0;
    reg stack_enable_reg = 0;
    reg stack_empty_reg = 0;
    
    reg interrupt_signal2_reg = 0;
    reg interrupt_signal3_reg = 0;
    
    always @(posedge clk_in) begin
        interrupt_signal2_reg <= interrupt_signal_in;
        interrupt_signal3_reg <= interrupt_signal2_reg;
    end
    
    assign pop_0 = (((rd_in != 5'b00001) || (rd_in != 5'b00101)) && ((rs1_in == 5'b00001) || (rs1_in == 5'b00101)));
    assign pop_1 = (((rd_in == 5'b00001) || (rd_in == 5'b00101)) && ((rs1_in == 5'b00001) || (rs1_in == 5'b00101)) && (rd_in != rs1_in));
    
    assign push_0 = (~jalr_inst_signal_in && ((rd_in == 5'b00001) || (rd_in == 5'b00101)));
    assign push_1 = ((rd_in == 5'b00001) || (rd_in == 5'b00101)) && ((rs1_in != 5'b00001) || (rs1_in != 5'b00101));
    assign push_2 = (((rd_in == 5'b00001) || (rd_in == 5'b00101)) && ((rs1_in == 5'b00001) || (rs1_in == 5'b00101)) && (rd_in != rs1_in));
    assign push_3 = (((rd_in == 5'b00001) || (rd_in == 5'b00101)) && ((rs1_in == 5'b00001) || (rs1_in == 5'b00101)) && (rd_in == rs1_in));
    
    assign pop =  (pop_0 | pop_1) & ~push_3;
    assign push = (push_0 | push_1 | push_2 | push_3) | (interrupt_signal3_reg & ~return_address_registers_flag_signal_in);
    
    always @(posedge clk_in) begin
        if(jump_signal_in) begin
            stack_pointer_reg = pointer_pop_push_reg;
            if(rd_in == 5'b00001) begin
                stack_enable_x1_reg = 1;
            end
            else if (stack_empty_reg) begin
                stack_enable_x1_reg = 0;
            end
            if(rd_in == 5'b00101) begin 
                stack_enable_x5_reg = 1;
            end
            else if (stack_empty_reg) begin
                stack_enable_x5_reg = 0;
            end
        end
    end

    always @(*) begin
        if(jump_signal_in) begin
            if(((rd_in == 5'b00101) & ~stack_enable_x5_reg) || ((rd_in == 5'b00001) & ~stack_enable_x1_reg)) begin
                stack_enable_reg = 0;
            end
            else begin
                stack_enable_reg = stack_enable_x1_reg | stack_enable_x5_reg;
            end
            if((stack_pointer_reg == 4'b0000) & pop) begin
                stack_empty_reg = 1;
            end
            else if((stack_pointer_reg == 4'b0000) & push) begin
                stack_empty_reg = 0;
            end
        end
    end
    
    always @(*) begin 
        if((jump_signal_in & stack_enable_reg) | (interrupt_signal3_reg & ~return_address_registers_flag_signal_in)) begin
            case({pop,push})
                `POP : begin
                    pointer_pop_push_reg = (stack_pointer_reg != 4'b0000) ? (stack_pointer_reg - 1) : stack_pointer_reg;
                end
                `PUSH : begin
                    pointer_pop_push_reg = stack_pointer_reg + 1;
                end
                default : begin
                    pointer_pop_push_reg = stack_pointer_reg;
                end
            endcase
        end
    end
    
    always @(posedge clk_in) begin
        if((jump_signal_in & stack_enable_reg) | (interrupt_signal3_reg & ~return_address_registers_flag_signal_in)) begin
            if(push) begin
                Stack_reg[stack_pointer_reg] <= return_address_reg_value_in;
            end
        end 
    end
    
    always @(negedge clk_in) begin
        if(jump_signal_in & stack_enable_reg) begin
            if(pop) begin
                return_address_out <= Stack_reg[stack_pointer_reg];
            end
        end
    end
    
    assign return_signal_out = pop & jump_signal_in;
endmodule
`endif