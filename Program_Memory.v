`include "Opcodes.vh"

`ifndef Program_Memory
`define Program_Memory

module Program_Memory (
    input [63:0] instr_address_in,

    output [31:0] instr_read_value_out
);
    
    reg [31:0] memory [0:263];
    
    assign instr_read_value_out = memory[instr_address_in];
    initial begin 
        $readmemb("program.mem",memory);
    end    
endmodule
`endif