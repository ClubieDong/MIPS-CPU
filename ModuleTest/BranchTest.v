`timescale 1ns/1ps

module BranchTest;
    reg    [31:0] din1;
    reg    [31:0] din2;
    reg           braEnable;
    reg    [ 2:0] braOp;
    wire          takeBranch;
    integer i;

    Branch U1
    (
        .din1(din1),
        .din2(din2),
        .braEnable(braEnable),
        .braOp(braOp),
        .takeBranch(takeBranch)
    );

    initial
    begin
        braEnable = 1;

        din1 = 5;
        din2 = 5;
        for (braOp = 0; braOp < 2; braOp = braOp + 1)
            #100;
        // expect: 1 0

        din1 = 4;
        din2 = 3;
        for (braOp = 0; braOp < 2; braOp = braOp + 1)
            #100;
        // expect: 0 1

        din1 = -1;
        for (braOp = 2; braOp < 6; braOp = braOp + 1)
            #100;
        // expect: 0 0 1 1

        din1 = 0;
        for (braOp = 2; braOp < 6; braOp = braOp + 1)
            #100;
        // expect: 1 0 1 0

        din1 = 1;
        for (braOp = 2; braOp < 6; braOp = braOp + 1)
            #100;
        // expect: 1 1 0 0
    end
    
endmodule
