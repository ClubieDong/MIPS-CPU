`timescale 1ns/1ps

module MIPSTest;
    reg           clk;
    reg           rst;

    MIPS U1
    (
        .clk(clk),
        .rst(rst)
    );

    initial
    begin
        clk = 0;
        rst = 1'b1;
        #20
        rst = 1'b0;
    end
    
    always
    begin
        #10
        clk = ~clk;
    end

endmodule
