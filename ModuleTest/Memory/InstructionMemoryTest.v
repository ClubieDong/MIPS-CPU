`timescale 1ns/1ps

module InstructionMemoryTest;
    reg           clk;
    reg    [31:0] addr;
    wire   [31:0] dout;
    wire          exception;

    InstructionMemory U1
    (
        .clk(clk),
        .addr(addr),
        .dout(dout),
        .exception(exception)
    );

    initial
    begin
        clk = 0;
        addr = 32'h0000_0000;
        
        #20
        addr = 32'h0000_0004;

        #20
        addr = 32'h0000_0002;
        // expect: exception
    end

    always
    begin
        #10
        clk = ~clk;
    end

endmodule
