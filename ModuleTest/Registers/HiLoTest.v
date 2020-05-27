`timescale 1ns/1ps

module HiLoTest;
    reg           clk;
    reg           rst;
    reg    [31:0] dinHi;
    reg    [31:0] dinLo;
    reg    [ 1:0] hlWrite;
    wire   [31:0] doutHi;
    wire   [31:0] doutLo;

    HiLo U1
    (
        .clk(clk),
        .rst(rst),
        .dinHi(dinHi),
        .dinLo(dinLo),
        .hlWrite(hlWrite),
        .doutHi(doutHi),
        .doutLo(doutLo)
    );

    initial
    begin
        clk = 1;
        rst = 1'b1;
        #100
        rst = 1'b0;
        
        #100
        dinHi = 32'h1111_1111;
        dinLo = 32'h2222_2222;
        hlWrite = 2'b10;
        // expect: 32'h1111_1111 32'hXXXX_XXXX

        #100
        dinHi = 32'h3333_3333;
        dinLo = 32'h4444_4444;
        hlWrite = 2'b01;
        // expect: 32'h1111_1111 32'h4444_4444

        #100
        dinHi = 32'h5555_5555;
        dinLo = 32'h6666_6666;
        hlWrite = 2'b11;
        // expect: 32'h5555_5555 32'h6666_6666
    end
    
    always
    begin
        #10
        clk = ~clk;
    end

endmodule
