`timescale 1ns/1ps

module ExtendTest;
    reg[15:0] din;
    wire[31:0] dout;

    Extend U1
    (
        .din(din),
        .dout(dout)
    );

    initial
    begin
        din = 16'h0000;
        
        #100
        din = 16'h1234;

        #100
        din = 16'hABCD;
    end
    
endmodule