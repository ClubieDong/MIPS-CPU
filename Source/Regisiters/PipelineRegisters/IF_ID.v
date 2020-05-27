module IF_ID(
    input         clk,
    input         rst,
    input  [31:0] IF_pc4,
    input  [31:0] IF_instr,
    output [31:0] ID_pc4,
    output [31:0] ID_instr
);
    reg    [31:0] pc4Reg;
    reg    [31:0] instrReg;

    always @ (posedge clk)
    begin
        if (rst)
        begin
            pc4Reg <= 32'bX;
            instrReg <= 32'bX;
        end
        else
        begin
            pc4Reg <= IF_pc4;
            instrReg <= IF_instr;
        end
    end

    assign ID_pc4 = pc4Reg;
    assign ID_instr = instrReg;

endmodule
