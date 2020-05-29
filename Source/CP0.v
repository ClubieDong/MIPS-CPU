module CP0(
    input         clk,
    input         rst,
    input  [ 4:0] addr,
    input  [ 5:0] sel,
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
        else if (cp0Write && sel[2:0] == 0)
            regs[addr] <= din;
    end

    assign dout = sel[2:0] == 0 ? regs[addr] : 32'bX;
    assign epc = regs[14];

endmodule
