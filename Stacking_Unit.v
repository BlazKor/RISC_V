`ifndef Stacking_Unit
`define Stacking_Unit

module Stacking_Unit (
    input clk_in,

    input [4:0] rd_in,

    input rd_write_signal_in,
    input interrupt_signal_in,
    input return_interrupt_signal_in,

    output reg [63:0] memory_address_out,
    output [4:0] register_addres_out,

    output reg write_signal_out = 0,
    output reg read_signal_out = 0,
    output interrupt_signal_out,
    output return_interrupt_signal_out,
    output reg return_address_registers_flag_signal_out = 0,
    output reg return_pipeline_registers_signal_out = 0
);

    reg [31:0] registers_flag_reg = 32'h00000000;
    reg [31:0] registers_stacking_flag_reg = 32'h00000105;
    reg [31:0] registers_memory_flag_reg = 32'h00000000;
    reg [31:0] registers_interrupt_flag_reg = 32'h00000000;

    reg [4:0] register_addres_reg = 5'h00;
    reg [4:0] register_unstacking_addres_reg;
    reg [1:0] delay_signal_reg = 1'h0;

    reg stacking_signal_reg = 1'h0;
    reg unstacking_signal_reg = 1'h0;
    reg write_signal_reg = 1'h0;
    reg interrupt_pending_signal_reg = 1'h0;
    reg return_interrupt_signal_reg = 1'h0;
    
    always @(*) begin
        if(interrupt_pending_signal_reg) begin
            return_interrupt_signal_reg <= return_interrupt_signal_in;
        end
        if(rd_write_signal_in) begin
            if(~interrupt_pending_signal_reg) begin
                registers_stacking_flag_reg[rd_in] <= 1'h1;
            end
            else if(return_pipeline_registers_signal_out) begin
                registers_stacking_flag_reg <= 1'h0;
            end
            if(interrupt_pending_signal_reg & ~return_interrupt_signal_out) begin
                registers_interrupt_flag_reg[rd_in] <= 1'h1;
            end
            else if(return_interrupt_signal_reg) begin
                registers_interrupt_flag_reg <= 32'h00000000;
            end
        end
    end
    
    always @(posedge clk_in) begin
        if(interrupt_signal_in) begin
            interrupt_pending_signal_reg <= 1'h1;
        end
        if(return_pipeline_registers_signal_out) begin
            interrupt_pending_signal_reg <= 1'h0;
        end
    end

    always @(posedge clk_in) begin
        if(~stacking_signal_reg) begin
            stacking_signal_reg <= interrupt_signal_in;
        end
        if(~unstacking_signal_reg) begin
            unstacking_signal_reg <= return_interrupt_signal_reg;
        end       
        if(~|registers_flag_reg) begin
            if(stacking_signal_reg | unstacking_signal_reg) begin
                delay_signal_reg <= delay_signal_reg + 1'h1;
            end
            case(delay_signal_reg)
                2'h2 : begin
                    if(stacking_signal_reg) begin
                        stacking_signal_reg <= 1'h0;
                        delay_signal_reg <= 1'h0;
                    end
                    if(unstacking_signal_reg) begin
                        read_signal_out <= 1'h0;
                    end
                end
                2'h3 : begin
                    if(unstacking_signal_reg) begin
                        unstacking_signal_reg <= 1'h0;
                        return_pipeline_registers_signal_out <= 1'h1;
                        delay_signal_reg <= 1'h0;
                    end
                end
            endcase
        end
        else begin
            delay_signal_reg <= 2'h1;
            if(delay_signal_reg == 2'h1) begin
                read_signal_out <= unstacking_signal_reg;
                delay_signal_reg <= 1'h0;
            end
        end
        register_unstacking_addres_reg <= register_addres_reg;
        return_pipeline_registers_signal_out = return_pipeline_registers_signal_out ? 1'h0 : return_pipeline_registers_signal_out;
        return_address_registers_flag_signal_out <= return_pipeline_registers_signal_out ? 1'h0 : registers_stacking_flag_reg[5'h01];
        memory_address_out <= (32'h3FF - register_addres_reg) << 2'h3;
        registers_memory_flag_reg[register_addres_reg] <= 1'h1;
    end

    assign register_addres_out = write_signal_reg ? register_addres_reg : register_unstacking_addres_reg;
    assign interrupt_signal_out = stacking_signal_reg;
    assign return_interrupt_signal_out = unstacking_signal_reg | return_pipeline_registers_signal_out;
    
    always @(posedge clk_in) begin
        if(stacking_signal_reg) begin
            write_signal_reg <= stacking_signal_reg;
            write_signal_out <= write_signal_reg;
        end
        else begin
            write_signal_reg = 1'h0;
            write_signal_out = 1'h0;
        end
    end

    always @(posedge clk_in) begin
        if(interrupt_signal_in) begin
            registers_flag_reg <= registers_stacking_flag_reg;
        end
        if(return_interrupt_signal_reg) begin
            registers_flag_reg <= (registers_stacking_flag_reg & registers_interrupt_flag_reg) | (registers_memory_flag_reg & registers_interrupt_flag_reg);
        end
        if(stacking_signal_reg | unstacking_signal_reg) begin
            if(registers_flag_reg[5'h00]) begin
                registers_flag_reg[5'h00] = 1'h0;
                register_addres_reg = 5'h00;
            end
            else if(registers_flag_reg[5'h01]) begin
                registers_flag_reg[5'h01] = 1'h0;
                register_addres_reg = 5'h01;
            end
            else if(registers_flag_reg[5'h02]) begin
                registers_flag_reg[5'h02] = 1'h0;
                register_addres_reg = 5'h02;
            end
            else if(registers_flag_reg[5'h03]) begin
                registers_flag_reg[5'h03] = 1'h0;
                register_addres_reg = 5'h03;
            end
            else if(registers_flag_reg[5'h04]) begin
                registers_flag_reg[5'h04] = 1'h0;
                register_addres_reg = 5'h04;
            end 
            else if(registers_flag_reg[5'h05]) begin
                registers_flag_reg[5'h05] = 1'h0;
                register_addres_reg = 5'h05;
            end
            else if(registers_flag_reg[5'h06]) begin
                registers_flag_reg[5'h06] = 1'h0;
                register_addres_reg = 5'h06;
            end
            else if(registers_flag_reg[5'h07]) begin
                registers_flag_reg[5'h07] = 1'h0;
                register_addres_reg = 5'h07;
            end 
            else if(registers_flag_reg[5'h08]) begin
                registers_flag_reg[5'h08] = 1'h0;
                register_addres_reg = 5'h08;
            end
            else if(registers_flag_reg[5'h09]) begin
                registers_flag_reg[5'h09] = 1'h0;
                register_addres_reg = 5'h09;
            end
            else if(registers_flag_reg[5'h0A]) begin
                registers_flag_reg[5'h0A] = 1'h0;
                register_addres_reg = 5'h0A;
            end
            else if(registers_flag_reg[5'h0B]) begin
                registers_flag_reg[5'h0B] = 1'h0;
                register_addres_reg = 5'h0B;
            end
            else if(registers_flag_reg[5'h0C]) begin
                registers_flag_reg[5'h0C] = 1'h0;
                register_addres_reg = 5'h0C;
            end 
            else if(registers_flag_reg[5'h0D]) begin
                registers_flag_reg[5'h0D] = 1'h0;
                register_addres_reg = 5'h0D;
            end
            else if(registers_flag_reg[5'h0E]) begin
                registers_flag_reg[5'h0E] = 1'h0;
                register_addres_reg = 5'h0E;
            end
            else if(registers_flag_reg[5'h0F]) begin
                registers_flag_reg[5'h0F] = 1'h0;
                register_addres_reg = 5'h0F;
            end
            else if(registers_flag_reg[5'h10]) begin
                registers_flag_reg[5'h10] = 1'h0;
                register_addres_reg = 5'h10;
            end
            else if(registers_flag_reg[5'h11]) begin
                registers_flag_reg[5'h11] = 1'h0;
                register_addres_reg = 5'h11;
            end
            else if(registers_flag_reg[5'h12]) begin
                registers_flag_reg[5'h12] = 1'h0;
                register_addres_reg = 5'h12;
            end
            else if(registers_flag_reg[5'h13]) begin
                registers_flag_reg[5'h13] = 1'h0;
                register_addres_reg = 5'h13;
            end
            else if(registers_flag_reg[5'h14]) begin
                registers_flag_reg[5'h14] = 1'h0;
                register_addres_reg = 5'h14;
            end 
            else if(registers_flag_reg[5'h15]) begin
                registers_flag_reg[5'h15] = 1'h0;
                register_addres_reg = 5'h15;
            end
            else if(registers_flag_reg[5'h16]) begin
                registers_flag_reg[5'h16] = 1'h0;
                register_addres_reg = 5'h16;
            end
            else if(registers_flag_reg[5'h17]) begin
                registers_flag_reg[5'h17] = 1'h0;
                register_addres_reg = 5'h17;
            end 
            else if(registers_flag_reg[5'h18]) begin
                registers_flag_reg[5'h18] = 1'h0;
                register_addres_reg = 5'h18;
            end
            else if(registers_flag_reg[5'h19]) begin
                registers_flag_reg[5'h19] = 1'h0;
                register_addres_reg = 5'h19;
            end
            else if(registers_flag_reg[5'h1A]) begin
                registers_flag_reg[5'h1A] = 1'h0;
                register_addres_reg = 5'h1A;
            end
            else if(registers_flag_reg[5'h1B]) begin
                registers_flag_reg[5'h1B] = 1'h0;
                register_addres_reg = 5'h1B;
            end
            else if(registers_flag_reg[5'h1C]) begin
                registers_flag_reg[5'h1C] = 1'h0;
                register_addres_reg = 5'h1C;
            end 
            else if(registers_flag_reg[5'h1D]) begin
                registers_flag_reg[5'h1D] = 1'h0;
                register_addres_reg = 5'h1D;
            end
            else if(registers_flag_reg[5'h1E]) begin
                registers_flag_reg[5'h1E] = 1'h0;
                register_addres_reg = 5'h1E;
            end
            else if(registers_flag_reg[5'h1F]) begin
                registers_flag_reg[5'h1F] = 1'h0;
                register_addres_reg = 5'h1F;
            end
        end
    end

endmodule
`endif