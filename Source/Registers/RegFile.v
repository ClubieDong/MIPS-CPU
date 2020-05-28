module RegFile(
    input         clk,
    input         rst,
    input  [ 4:0] addr1, // read
    input  [ 4:0] addr2, // read
    input  [ 4:0] addr3, // write
    input  [31:0] din,
    input         regWrite,
    output [31:0] dout1, // output data of addr1
    output [31:0] dout2 // output data of addr2
);
    reg    [31:0] regs[31:0];
    integer i;

    always @ (posedge clk)
    begin
        if (rst)
        begin
            regs[0] <= 0;
            for (i = 1; i < 32; i = i + 1)
                regs[i] = 32'bX;
        end
        else if (regWrite && addr3 != 0)
            regs[addr3] <= din;
    end

    assign dout1 = regs[addr1];
    assign dout2 = regs[addr2];

endmodule
