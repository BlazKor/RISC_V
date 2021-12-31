`ifndef External_RAM
`define External_RAM

module External_RAM (
    input clk_in,
    
    input [9:0] address_in,
    input [63:0] value_in,
    input [7:0] mask_in,
    
    input write_signal_in,
    input read_signal_in,
    
    output reg [63:0] data_read_value_out
);

    reg [63:0] memory_ram [1023:0];
       
    always @(posedge clk_in) begin  
        if(write_signal_in) begin
            if(mask_in[0]) begin
                memory_ram[address_in][7:0] <= value_in[7:0];
            end
            if(mask_in[1]) begin
                memory_ram[address_in][15:8] <= value_in[15:8];
            end
            if(mask_in[2]) begin
                memory_ram[address_in][23:16] <= value_in[23:16];
            end
            if(mask_in[3]) begin
                memory_ram[address_in][31:24] <= value_in[31:24];
            end
            if(mask_in[4]) begin
                memory_ram[address_in][39:32] <= value_in[39:32];
            end
            if(mask_in[5]) begin
                memory_ram[address_in][47:40] <= value_in[47:40];
            end
            if(mask_in[6]) begin
                memory_ram[address_in][55:48] <= value_in[55:48];
            end
            if(mask_in[7]) begin
                memory_ram[address_in][63:56] <= value_in[63:56];
            end
        end
    end
    
    always @(negedge clk_in) begin
        if(read_signal_in) begin
            data_read_value_out <= memory_ram[address_in];
        end
    end
    
endmodule
`endif