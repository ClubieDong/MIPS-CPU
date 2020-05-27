module InstructionMemory(
    input  [31:0] addr,
    output [31:0] dout,
    output        exception
);
    reg    [31:0] regs[2047:0];
    
    initial
    begin
        $readmemh("F:/Project/TestCode/sort.txt", regs);
    end
    
    assign exception = addr[1:0] != 2'b0;
    assign dout = exception ? 32'bX : regs[addr[12:2]];

endmodule
