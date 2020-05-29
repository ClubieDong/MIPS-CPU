`timescale 1ns/1ps

module CP0Test;
    reg           clk;
    reg           rst;
    reg    [ 4:0] addr;
    reg    [ 5:0] sel;
    reg    [31:0] din;
    reg           cp0Write;
    wire   [31:0] dout;
    wire   [31:0] epc;

    CP0 U1
    (
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .sel(sel),
        .din(din),
        .cp0Write(cp0Write),
        .dout(dout),
        .epc(epc)
    );

    initial
    begin
        clk = 0;
        rst = 1'b1;
        #20
        rst = 1'b0;
        
        addr = 8;
        sel = 0;
        din = 32'h1234_5678;
        cp0Write = 1'b1;

        #20
        addr = 8;
        sel = 1;
        din = 32'h8765_4321;
        cp0Write = 1'b1;
        
        #20
        addr = 14;
        sel = 0;
        din = 32'h1111_1111;
        cp0Write = 1'b1;

        #20;
        addr = 8;
        sel = 0;
        cp0Write = 1'b0;
        // expect: 32'h1234_5678 32'h1111_1111

        #20;
        addr = 8;
        sel = 1;
        cp0Write = 1'b0;
        // expect: 32'hXXXX_XXXX 32'h1111_1111
    end
    
    always
    begin
        #10
        clk = ~clk;
    end

endmodule
