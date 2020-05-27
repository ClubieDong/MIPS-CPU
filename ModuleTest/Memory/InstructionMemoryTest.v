`timescale 1ns/1ps

module InstructionMemoryTest;
    reg    [31:0] addr;
    wire   [31:0] dout;
    wire          exception;

    InstructionMemory U1
    (
        .addr(addr),
        .dout(dout),
        .exception(exception)
    );

    initial
    begin
        addr = 32'h0000_0000;
        
        #100
        addr = 32'h0000_0004;

        #100
        addr = 32'h0000_0002;
        // expect: exception
    end

endmodule
