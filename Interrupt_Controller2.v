`include "Opcodes.vh"

`ifndef Interrupt_Controller2
`define Interrupt_Controller2

`define BUTTON 2'b01
`define SWITCH 2'b10
`define TIMER 2'b11

`define BTN0 2'b00
`define BTN1 2'b01
`define BTN2 2'b10
`define BTN3 2'b11

`define SWT0 2'b00
`define SWT1 2'b01
`define SWT2 2'b10
`define SWT3 2'b11

module Interrupt_Controller2(
    input clk_in,
    input timer_interrupt_trigger,
    input interrupt_enable,
    input [3:0] external_button,
    input [2:0] external_switch,
    input [3:0] csr_mbutton_ctrl_in,
    input [2:0] csr_mswitch_ctrl_in,
    input interrupt_pending,

    input csr_meie_in,
    input csr_mtie_in,

    output reg [63:0] interrupt_pc_out,
    output empty_fifo_out,
    output interrupt_signal
);

reg reset_fifo = 1'b0;
reg wr_enable;
reg [3:0] wr_data;
reg [31:0] button_edge_counter;

initial begin
    interrupt_pc_out = 64'b0;
    //button_edge_flag = 1'b0;
    button_edge_counter = 0;
end

wire full_fifo;
wire empty_fifo;
wire delayed_empty_fifo;
wire [3:0] rd_data;

Sync_FIFO_IntQueue #(.BIT_LEN(4), .DEPTH(8)) Sync_FIFO_IntQueue(
    .clk_in(clk_in), //in
    //.clk_wr(wr_enable),
    //.clk_rd(rd_enable),
    .reset_fifo(reset_fifo), //in

    .wr_enable(wr_enable), //in
    .wr_data(wr_data), //in

    .rd_enable(rd_enable_tick_toFifo), //in
    
    .full_fifo(full_fifo), //out
    .empty_fifo(empty_fifo), //out
    .delay_regc(delayed_empty_fifo),
    .rd_data(rd_data) //out
);

reg rd_enable = 1'b0;


///reg button_edge_flag;


assign button_edge = (|external_button);
assign switch_edge = (|external_switch);

wire [1:0] int_type = rd_data[3:2];
wire [1:0] int_number = rd_data[1:0];

assign interrupt_signal = rd_enable_flag;
assign empty_fifo_out = delayed_empty_fifo;

//Writing to FIFO
always @(posedge clk_in) begin
    if(interrupt_enable) begin
        if(button_edge_flag||(|external_switch)||(timer_interrupt_trigger)) begin
        //if(button_edge||switch_edge||(timer_interrupt_trigger)) begin
            if(~full_fifo) begin
                if(timer_interrupt_trigger && csr_mtie_in) begin
                    wr_data <= 4'b1101;
                    wr_enable <= 1'b1;
                end
                if((button_edge_flag) && (|csr_mbutton_ctrl_in) && csr_meie_in) begin
                //else if((button_edge) && (|csr_mbutton_ctrl_in) && csr_meie_in) begin
                    case (external_button)
                    4'h1: begin
                        if(csr_mbutton_ctrl_in[0]) begin
                            wr_enable <= 1'b1;
                            wr_data <= 4'b0100;
                        end
                    end
                    4'h2: begin
                        if(csr_mbutton_ctrl_in[1]) begin
                            wr_enable <= 1'b1;
                            wr_data <= 4'b0101;
                        end
                    end
                    4'h4: begin
                        if(csr_mbutton_ctrl_in[2]) begin
                            wr_enable <= 1'b1;
                            wr_data <= 4'b0110;
                        end
                    end
                    4'h8: begin
                        if(csr_mbutton_ctrl_in[3]) begin
                            wr_enable <= 1'b1;
                            wr_data <= 4'b0111;
                        end
                    end
                    default:  begin end
                endcase
                end
                else if(switch_edge_flag && (|csr_mswitch_ctrl_in) && csr_meie_in) begin
                    case (external_switch)
                    3'h1: begin
                        if(csr_mswitch_ctrl_in[0]) begin
                            wr_enable <= 1'b1;
                            wr_data <= 4'b1000;
                        end
                    end
                    3'h2: begin
                        if(csr_mswitch_ctrl_in[1]) begin
                            wr_enable <= 1'b1;
                            wr_data <= 4'b1001;
                        end
                    end
                    3'h4: begin
                        if(csr_mswitch_ctrl_in[2]) begin
                            wr_enable <= 1'b1;
                            wr_data <= 4'b1010;
                        end
                    end
                    default:  begin end
                endcase
                end
            end
        end
        else wr_enable <= 1'b0;
    end
end

//reg int_type [1:0];
//reg int_number [1:0];


//Reading from FIFO
always @(posedge clk_in) begin
    if(~delayed_empty_fifo && ~interrupt_pending ) begin
        rd_enable <= 1'b1;
        case (int_type)
            `TIMER: begin
                interrupt_pc_out <= 64'h1;
            end 
            `BUTTON: begin
                case (int_number)
                    `BTN0: begin
                        interrupt_pc_out <= 64'h12;
                    end
                    `BTN1: begin
                        interrupt_pc_out <= 64'h1C;
                    end
                    `BTN2: begin
                        interrupt_pc_out <= 64'hCC;
                    end
                    `BTN3: begin
                        interrupt_pc_out <= 64'hCA;
                    end
                    default: begin end
                endcase
            end
            `SWITCH: begin
                case (int_number)
                    `SWT0: begin
                        interrupt_pc_out <= 64'h3C;
                    end 
                    `SWT1: begin
                        interrupt_pc_out <= 64'h4;
                    end
                    `SWT2: begin
                        interrupt_pc_out <= 64'h8;
                    end
                    default: begin end 
                endcase
            end
            default: begin end
        endcase
    end 
    else begin 
    rd_enable <= 1'b0;
    //interrupt_pc_out <= 4'h0;
    end
end

//----Tick for buttons
    reg delay_reg = 0;
    always @(posedge clk_in)begin
            delay_reg <= button_edge;
            end
    // decoding logic
    assign button_edge_flag = ~delay_reg & button_edge;
    
    reg delay_regEn = 0;
    reg delay_regEn1 = 0;
    reg delay_regEn2 = 0;
    always @(posedge clk_in)begin
            delay_regEn <= rd_enable;
            delay_regEn1 <= delay_regEn;
            delay_regEn2 <= delay_regEn1;
            end
    // decoding logic
    assign rd_enable_flag = ~delay_regEn2 & delay_regEn1;
    assign rd_enable_tick_toFifo = ~delay_regEn & rd_enable;
    
    reg delay_rega = 0;
    reg delay_regb = 0;
    reg delay_regc = 0;
    always @(posedge clk_in)begin
            delay_rega <= button_edge;
            delay_regb <= delay_rega;
            delay_regc <= delay_regb;
            end
    // decoding logic
    assign button_edge_flag2 = ~delay_regc & delay_regb;
    
    
//----Tick for switches
    reg delay_reg2 = 0;
    always @(posedge clk_in)
            delay_reg2 <= switch_edge;
    // decoding logic
    assign switch_edge_flag = ~delay_reg2 & switch_edge;
    
//----Tick for empty_fifo
//    reg delay_reg3 = 0;
//    always @(posedge clk_in)begin
//            delay_reg3 <= ~empty_fifo;
//            end
//    // decoding logic
//    assign nempty_fifo_flag = ~delay_reg3 & ~empty_fifo;
    
    
//always @(posedge clk_in) begin
//    if(button_edge == 1'b1 && button_edge_flag == 1'b0) begin
//        button_edge_flag = button_edge^button_edge_flag;
//        if(button_edge_flag == (1'b0)) begin
//            button_edge_flag <= 1'b1;
//        end else button_edge_flag <= 1'b0;
//    end else begin
//    button_edge_counter <= 1'b0;
//    end
//end

// 00 01 11 01 01 01 00


/* always @(posedge clk_in) begin
    if(button_edge == 1'b1) begin
    button_edge_counter <= button_edge_counter + 1'b1;
        if(button_edge_counter == (1'b1)) begin
            button_edge_flag <= 1'b1;
        end else button_edge_flag <= 1'b0;
    end else begin
    button_edge_counter <= 1'b0;
    end
end */

//always @(posedge button_edge or negedge button_edge) begin
//    if(button_edge == 1) begin
//        button_edge_flag = 1'b1;
//    end else begin
    
//    end
//end

//reg button_edge_flag_reg = 1'b0;

//assign button_edge_flag = ~(button_edge & button_edge_flag_reg) & button_edge;

//always @(posedge clk_in) begin
//     button_edge_flag_reg <= button_edge;    
//end

endmodule
`endif
