`ifndef Sync_FIFO_IntQueue
`define Sync_FIFO_IntQueue

module Sync_FIFO_IntQueue #(
    parameter BIT_LEN = 4,
    parameter DEPTH = 8
)(
    input clk_in,
//    input clk_wr,
//    input clk_rd,
    input reset_fifo,

    input wr_enable,
    input [BIT_LEN - 1:0] wr_data,

    input rd_enable,
    
    output full_fifo,
    output empty_fifo,
    output reg delay_regc = 1,
    output reg [BIT_LEN - 1:0] rd_data
);


reg [BIT_LEN - 1:0] fifo_mem [0 : DEPTH - 1];

reg [2:0] wr_pointer;
reg [2:0] rd_pointer;
reg [3:0] counter;

initial begin
//    full_fifo = 1'b0;
//    empty_fifo = 1'b0;
    counter = 4'b0;
    rd_pointer = 3'b0;
    wr_pointer = 3'b0;
    rd_data = 0;
end

assign full_fifo = (counter == DEPTH)? 1 : 0; 
assign empty_fifo = (counter == 0)? 1 : 0;

    reg delay_rega = 1;
    reg delay_regb = 1;
    //reg delay_regc = 1;
    always @(posedge clk_in)begin
            delay_rega <= empty_fifo;
            delay_regc <= delay_rega;
            end
    // decoding logic
    //assign empty_fifo_delayed = ~delay_regc & delay_regb;

/* Data write handler */
always @(posedge clk_in) begin // or posedge reset_fifo
    if(wr_enable == 1) begin
        fifo_mem[wr_pointer] <= wr_data;
        wr_pointer <= wr_pointer + 1;
        end
    if(rd_enable == 1 && fifo_mem[rd_pointer] != 0) begin
        rd_data <= fifo_mem[rd_pointer];
        rd_pointer <= rd_pointer + 1;
        end        
end

/*always @(posedge clk_in) begin // or posedge reset_fifo
//    if(reset_fifo) begin
//        wr_pointer <= 3'd0;
//    end 
    //else 
    begin if(wr_enable == 1) begin
        fifo_mem[wr_pointer] <= wr_data;
        wr_pointer <= wr_pointer + 1;
        end
    end        
end
*/

/* Data read handler */
//always @(posedge clk_in) begin // or posedge reset_fifo
//    begin if(rd_enable == 1 && fifo_mem[rd_pointer] != 0) begin
//        rd_data = fifo_mem[rd_pointer];
//        rd_pointer = rd_pointer + 1;
//        end
//    end        
//end

/*always @(posedge clk_in) begin // or posedge reset_fifo
//    if(reset_fifo) begin
//        rd_pointer <= 3'd0;
//    end 
    //else 
    begin if(rd_enable == 1 && fifo_mem[rd_pointer] != 0) begin
        rd_data = fifo_mem[rd_pointer];
        rd_pointer <= rd_pointer + 1;
        end
    end        
end */

//assign clk_help = clk_rd | clk_wr;
/* Cases of wr_enable and rd_enable combinations */
always @(posedge clk_in) begin
begin
        case ({wr_enable, rd_enable})
            2'b10: if(counter != 8) counter <= counter + 1;
            2'b01: if(counter != 0) counter <= counter - 1;
            2'b11: counter <= counter;
            2'b00: counter <= counter;
            default: counter <= counter;
        endcase
    end
end

endmodule
`endif