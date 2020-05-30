module PC(
    input         clk,
    input         rst,
    input         stall,
    input  [31:0] branchImmEx, // Extended Imm of branch instr
    input  [25:0] jumpImm,
    input  [31:0] jumpReg,
    input  [31:0] epc,
    input         takeException,
    input         takeEret,
    input         takeBranch,
    input         takeJumpImm,
    input         takeJumpReg,
    output [31:0] pc,
    output [31:0] pc4 // pc + 4
);
    reg    [31:0] pcReg;

    assign pc = pcReg;
    assign pc4 = pc + 4;

    always @ (posedge clk)
    begin
        if (rst)
            pcReg <= 32'hBFC0_0000;
        else if (takeException)
            pcReg <= 32'hBFC0_0380;
        else if (takeEret)
            pcReg <= epc;
        else if (!stall)
        begin
            if (takeBranch)
                pcReg <= pc + (branchImmEx << 2);
            else if (takeJumpImm)
                pcReg <= {pc[31:28], jumpImm, 2'b0};
            else if (takeJumpReg)
                pcReg <= jumpReg;
            else
                pcReg <= pc4;
        end
    end

endmodule
