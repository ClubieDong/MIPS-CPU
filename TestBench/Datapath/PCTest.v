`timescale 1ns/1ps

module PCTest;
    reg           clk;
    reg           rst;
    reg    [31:0] branchImmEx;
    reg    [25:0] jumpImm;
    reg    [31:0] jumpReg;
    reg           takeBranch;
    reg           takeJumpImm;
    reg           takeJumpReg;
    reg           takeException;
    wire   [31:0] pc;
    wire   [31:0] pc4;

    PC U1
    (
        .clk(clk),
        .rst(rst),
        .branchImmEx(branchImmEx),
        .jumpImm(jumpImm),
        .jumpReg(jumpReg),
        .takeBranch(takeBranch),
        .takeJumpImm(takeJumpImm),
        .takeJumpReg(takeJumpReg),
        .takeException(takeException),
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
        takeBranch = 0;
        takeJumpImm = 0;
        takeJumpReg = 0;
        takeException = 1;
        // expect: 32'hBFC0_0380

        #20
        takeBranch = 1;
        takeJumpImm = 0;
        takeJumpReg = 0;
        takeException = 0;
        branchImmEx = 32'h0000_1234;
        // expect: 32'hBFC0_4C54

        #20
        takeBranch = 0;
        takeJumpImm = 1;
        takeJumpReg = 0;
        takeException = 0;
        jumpImm = 26'h1234_567;
        // expect: 32'hB48D_159C

        #20
        takeBranch = 0;
        takeJumpImm = 0;
        takeJumpReg = 1;
        takeException = 0;
        jumpReg = 32'h1111_1110;
        // expect: 32'h1111_1110

        #20
        takeBranch = 0;
        takeJumpImm = 0;
        takeJumpReg = 0;
        takeException = 0;
        // expect: 32'h1111_1114
    end
        
    always
    begin
        #10
        clk = ~clk;
    end
    
endmodule