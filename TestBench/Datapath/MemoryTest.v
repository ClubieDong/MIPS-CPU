`timescale 1ns/1ps

module DataMemoryTest;
    reg           clk;
    reg           rst;
    reg    [31:0] addr;
    reg    [31:0] din;
    reg           memWrite;
    reg           memRead;
    reg    [ 1:0] memSize;
    reg           memSign;
    wire   [31:0] dout;
    wire          exception;

    DataMemory U1
    (
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .din(din),
        .memWrite(memWrite),
        .memRead(memRead),
        .memSize(memSize),
        .memSign(memSign),
        .dout(dout),
        .exception(exception)
    );

    initial
    begin
        clk = 1;
        rst = 1;
        #100
        rst = 0;

        #100
        // sw
        addr = 32'h0000_0000;
        din = 32'h1234_5678;
        memWrite = 1'b1;
        memRead = 1'b0;
        memSize = 2'b10;
        memSign = 1'bX;

        #100
        // sh
        addr = 32'h0000_0004;
        din = 32'h1234_5678;
        memWrite = 1'b1;
        memRead = 1'b0;
        memSize = 2'b01;
        memSign = 1'bX;

        #100
        // sb
        addr = 32'h0000_0006;
        din = 32'hFFFF_FFFF;
        memWrite = 1'b1;
        memRead = 1'b0;
        memSize = 2'b00;
        memSign = 1'bX;

        #100
        // sb
        addr = 32'h0000_0007;
        din = 32'hEEEE_EEEE;
        memWrite = 1'b1;
        memRead = 1'b0;
        memSize = 2'b00;
        memSign = 1'bX;

        // Memory:
        // 0  1  2  3  4  5  6  7
        // 78 56 34 12 78 56 FF EE

        #100
        // lw
        addr = 32'h0000_0000;
        memWrite = 1'b0;
        memRead = 1'b1;
        memSize = 2'b10;
        memSign = 1'bX;
        // expected: 32'h1234_5678

        #100
        // lh
        addr = 32'h0000_0006;
        memWrite = 1'b0;
        memRead = 1'b1;
        memSize = 2'b01;
        memSign = 1'b1;
        // expected: 32'hFFFF_EEFF

        #100
        // lhu
        addr = 32'h0000_0006;
        memWrite = 1'b0;
        memRead = 1'b1;
        memSize = 2'b01;
        memSign = 1'b0;
        // expected: 32'h0000_EEFF

        #100
        // lb
        addr = 32'h0000_0000;
        memWrite = 1'b0;
        memRead = 1'b1;
        memSize = 2'b00;
        memSign = 1'b1;
        // expected: 32'h0000_0078

        #100
        // lbu
        addr = 32'h0000_0000;
        memWrite = 1'b0;
        memRead = 1'b1;
        memSize = 2'b00;
        memSign = 1'b0;
        // expected: 32'h0000_0078

        #100
        // lw
        addr = 32'h0000_0003;
        memWrite = 1'b0;
        memRead = 1'b1;
        memSize = 2'b10;
        memSign = 1'bX;
        // expected: exception

        #100
        // lh
        addr = 32'h0000_0005;
        memWrite = 1'b0;
        memRead = 1'b1;
        memSize = 2'b01;
        memSign = 1'b1;
        // expected: exception
    end

    always
    begin
        #10
        clk = ~clk;
    end

endmodule


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