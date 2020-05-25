`timescale 1ns/1ps

module MulDivTest;
    reg    [ 3:0] mdOp;
    reg    [31:0] din1;
    reg    [31:0] din2;
    wire   [31:0] hi;
    wire   [31:0] lo;

    MulDiv U1
    (
        .mdOp(mdOp),
        .din1(din1),
        .din2(din2),
        .hi(hi),
        .lo(lo)
    );
    
    initial
    begin
        mdOp = 2'b00; // div
        din1 = 5;
        din2 = -3;
        // expect 32'h0000_0002 32'hFFFF_FFFF

        #100
        mdOp = 2'b01; // divu
        din1 = 5;
        din2 = 3;
        // expect 32'h0000_0002 32'h0000_0001

        #100
        mdOp = 2'b10; // mult
        din1 = -5;
        din2 = 3;
        // expect 32'hFFFF_FFFF 32'hFFFF_FFF1

        #100
        mdOp = 2'b11; // multu
        din1 = 32'hABCD_CDEF;
        din2 = 32'h1234_5678;
        // expect 32'h0C37_9850 32'h4E32_D208
    end
    
endmodule