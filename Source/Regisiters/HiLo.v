module HiLo(
    input         clk,
    input         rst,
    input  [31:0] dinHi,
    input  [31:0] dinLo,
    input  [ 1:0] hlWrite,
    output [31:0] doutHi,
    output [31:0] doutLo
);
    reg    [31:0] hiReg, loReg;

    always @ (posedge clk)
    begin
        if (rst)
        begin
            hiReg <= 32'bX;
            loReg <= 32'bX;
        end
        else
        begin
            if (hlWrite[1])
                hiReg <= dinHi;
            if (hlWrite[0])
                loReg <= dinLo;
        end
    end

    assign doutHi = hiReg;
    assign doutLo = loReg;

endmodule
