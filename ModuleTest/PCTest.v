`timescale 1ns/1ps

module PCTest;
    reg           clk;
    reg           rst;
    reg    [31:0] branchImmEx;
    reg    [25:0] jumpImm;
    reg    [31:0] jumpReg;
    reg    [31:0] epc;
    reg           takeException;
    reg           takeEret;
    reg           takeBranch;
    reg           takeJumpImm;
    reg           takeJumpReg;
    wire   [31:0] pc;
    wire   [31:0] pc4;

    PC U1
    (
        .clk(clk),
        .rst(rst),
        .branchImmEx(branchImmEx),
        .jumpImm(jumpImm),
        .jumpReg(jumpReg),
        .epc(epc),
        .takeException(takeException),
        .takeEret(takeEret),
        .takeBranch(takeBranch),
        .takeJumpImm(takeJumpImm),
        .takeJumpReg(takeJumpReg),
        .pc(pc),
        .pc4(pc4)
    );

    initial
    begin
        clk = 1;
        rst = 1'b1;
        #20
        rst = 1'b0;
        // expect: 32'h0000_3000

        #20
        takeException = 1;
        takeEret = 0;
        takeBranch = 0;
        takeJumpImm = 0;
        takeJumpReg = 0;
        // expect: 32'hBFC0_0380

        #20
        takeException = 0;
        takeEret = 1;
        takeBranch = 1;
        takeJumpImm = 0;
        takeJumpReg = 0;
        epc = 32'h1111_1110;
        // expect: 32'h1111_1110;

        #20
        takeException = 0;
        takeEret = 0;
        takeBranch = 1;
        takeJumpImm = 0;
        takeJumpReg = 0;
        branchImmEx = 32'h0000_1234;
        // expect: 32'h1111_59E4

        #20
        takeException = 0;
        takeEret = 0;
        takeBranch = 0;
        takeJumpImm = 1;
        takeJumpReg = 0;
        jumpImm = 26'h123_4567;
        // expect: 32'h148D_159C

        #20
        takeException = 0;
        takeEret = 0;
        takeBranch = 0;
        takeJumpImm = 0;
        takeJumpReg = 1;
        jumpReg = 32'h2222_2220;
        // expect: 32'h2222_2220;

        #20
        takeException = 0;
        takeEret = 0;
        takeBranch = 0;
        takeJumpImm = 0;
        takeJumpReg = 0;
        // expect: 32'h2222_2224
    end
        
    always
    begin
        #10
        clk = ~clk;
    end
    
endmodule
