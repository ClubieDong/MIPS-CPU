module CP0(
    input         clk,
    input         rst,
    input  [ 4:0] addrR,
    input  [ 5:0] selR,
    input  [ 4:0] addrW,
    input  [ 5:0] selW,
    input  [31:0] din,
    input         cp0Write,
    output [31:0] dout,
    output [31:0] epc
);
    reg    [31:0] regs[31:0];
    integer i;

    always @ (posedge clk)
    begin
        if (rst)
            for (i = 0; i < 32; i = i + 1)
                regs[i] = 32'bX;
        else if (cp0Write && selW[2:0] == 0)
            regs[addrW] <= din;
    end

    assign dout = 
        selR[2:0] != 0                             ? 32'bX       :
        addrW == addrR && selR == selW && cp0Write ? din         : 
                                                      regs[addrR];
    assign epc = addrW == 14 && selW == 0 && cp0Write ? din : regs[14];

endmodule
