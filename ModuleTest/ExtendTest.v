`timescale 1ns/1ps

module ExtendTest;
    reg    [15:0] din;
    reg           extSign;
    wire   [31:0] dout;

    Extend U1
    (
        .din(din),
        .extSign(extSign),
        .dout(dout)
    );

    initial
    begin
        din = 16'h1234;
        extSign = 1;
        // expect: 32'h0000_1234

        #20
        din = 16'h1234;
        extSign = 0;
        // expect: 32'h0000_1234

        #20
        din = 16'hABCD;
        extSign = 1;
        // expect: 32'hFFFF_ABCD

        #20
        din = 16'hABCD;
        extSign = 0;
        // expect: 32'h0000_ABCD

        #20
        din = 16'hABCD;
        extSign = 1'bX;
        // expect: 32'hXXXX_ABCD
    end
    
endmodule
