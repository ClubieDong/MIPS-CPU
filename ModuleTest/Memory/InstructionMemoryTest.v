`timescale 1ns/1ps

module InstructionMemoryTest;
    reg           clk;
    reg           rst;
    reg    [31:0] addr;
    wire   [31:0] dout;
    wire          requireStall;
    wire          exception;

    InstructionMemory U1
    (
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .dout(dout),
        .requireStall(requireStall),
        .exception(exception)
    );

    initial
    begin
        clk = 0;
        rst = 1;
        #20
        rst = 0;

        addr = 32'h0000_0000;
        
        #40
        addr = 32'h0000_0004;

        #40
        addr = 32'h0000_0002;
        // expect: exception
    end

    always
    begin
        #10
        clk = ~clk;
    end

endmodule
