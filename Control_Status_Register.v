`include "Opcodes.vh"

`ifndef Control_Status_Register
`define Control_Status_Register

`define CSR_RDCYCLE 12'h000
`define CSR_RDTIME 12'h001
`define CSR_RDINSTRET 12'h002

module Control_Status_Register(
    input clk_in,
    
    input [63:0] rs1_value_in,
    input [63:0] instr_address_in,
    input [11:0] csr_address_in,
    input [4:0] uimm_value_in,
    
    input [1:0] csr_op_signal_in,
    input csr_write_signal_in,
    input csr_rs1_imm_signal_in,
    input wb_valid_inst_signal_in,
    input interrupt_signal_in,
    input return_interrupt_signal_in,
    input stall_signal_in,
    
    output reg [63:0] csr_value_out,
    output [63:0] csr_mepc_out
);

    reg [63:0] cycle_reg = 0;
    reg [63:0] instret_reg = 0;
    reg [63:0] time_reg = 0;
    reg [63:0] csr_mtime = 0;
    reg [63:0] csr_mtimecmp = 0;
    reg [11:0] csr_mie = 0;
    reg [63:0] csr_mepc = 64'h0;
    reg [3:0] csr_mbutton_ctrl = 0;
    reg [3:0] csr_mswitch_ctrl = 0;

    reg [63:0] data_reg;
    reg csr_mepc_flag_reg = 0;

    wire [63:0] write_value;

    assign write_value = csr_rs1_imm_signal_in ? rs1_value_in : {58'b0, uimm_value_in};

    always @(*)
    case(csr_op_signal_in)
        `CSR_OP_RW : data_reg = write_value;
        `CSR_OP_RS : data_reg = write_value | csr_value_out;
        `CSR_OP_RC : data_reg = ~write_value & csr_value_out;
        default : data_reg = 0;
    endcase

    always @(negedge clk_in) begin
        if(csr_write_signal_in) begin
            case(csr_address_in)
                `CSR_MTIMECMP : csr_mtimecmp = data_reg;
                `CSR_MIE : csr_mie = data_reg;
                `CSR_MIEPC : csr_mepc = data_reg;
                `CSR_MBUTTON_CTRL : csr_mbutton_ctrl = data_reg;
                `CSR_MSWITCH_CTRL : csr_mswitch_ctrl = data_reg;
            endcase
        end
        else if(interrupt_signal_in) begin
            csr_mepc = instr_address_in;
        end
    end

    assign csr_mepc_out = csr_mepc;

    always @(posedge clk_in) begin
        if(!stall_signal_in) begin
            instret_reg = instret_reg + wb_valid_inst_signal_in;
        end
        if(cycle_reg == 64'h186A0) begin
            if(csr_mie[`MTIE]) begin
                if(csr_mtime < csr_mtimecmp) begin 
                csr_mtime = csr_mtime + 1;
                //timer_interrupt_trigger = 1'b0;
                end 
                else begin
                csr_mtime = 64'b0;
                //timer_interrupt_trigger = 1'b1;
                end
            end
            time_reg = time_reg + 1'b1;
            cycle_reg = 64'h0;
        end 
        else begin
            cycle_reg = cycle_reg + 1;
        end
    end

    always @(negedge clk_in)
    case(csr_address_in)
        `CSR_RDCYCLE : csr_value_out = cycle_reg;
        `CSR_RDTIME : csr_value_out = time_reg;
        `CSR_RDINSTRET : csr_value_out = instret_reg;
        `CSR_MTIME : csr_value_out = csr_mtime;
        `CSR_MTIMECMP : csr_value_out = csr_mtimecmp;
        `CSR_MIE : csr_value_out = csr_mie;
        `CSR_MIEPC : csr_value_out = csr_mepc;
        `CSR_MBUTTON_CTRL : csr_value_out = csr_mbutton_ctrl;
        `CSR_MSWITCH_CTRL : csr_value_out = csr_mswitch_ctrl;
    endcase

endmodule
`endif
  