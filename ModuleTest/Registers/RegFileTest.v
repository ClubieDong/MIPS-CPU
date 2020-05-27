`timescale 1ns/1ps

module RegFileTest;
    reg           clk;
    reg           rst;
    reg    [ 4:0] addr1;
    reg    [ 4:0] addr2;
    reg    [ 4:0] addr3;
    reg    [31:0] din;
    reg           regWrite;
    wire   [31:0] dout1;
    wire   [31:0] dout2;

    RegFile U1
    (
        .clk(clk),
        .rst(rst),
        .addr1(addr1),
        .addr2(addr2),
        .addr3(addr3),
        .din(din),
        .regWrite(regWrite),
        .dout1(dout1),
        .dout2(dout2)
    );

    initial
    begin
        clk = 0;
        rst = 1'b1;
        #20
        rst = 1'b0;
        
        #20
        addr3 = 0;
        din = 32'h1234_5678;
        regWrite = 1'b1;
        
        #20
        addr3 = 1;
        din = 32'h1111_1111;
        regWrite = 1'b1;

        #20;
        addr1 = 0;
        addr2 = 1;
        regWrite = 1'b0;
        // expect: 32'h0000_0000 32'h1111_1111

        #20
        addr1 = 2;
        addr3 = 2;
        din = 32'h2222_2222;
        regWrite = 1;
        // expect: 32'h2222_2222
    end
    
    always
    begin
        #10
        clk = ~clk;
    end

endmodule
