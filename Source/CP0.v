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
    output [31:0] epc,

    input         takeEret,
    input         imExcept,
    input  [ 1:0] ctrlExcept,
    input         aluExcept,
    input         dmExcept,
    input         memWrite,
    input         memRead,
    input         delaySlot,
    input  [31:0] WB_pc4,
    input  [31:0] WB_aluDout,
    output        takeException,

    input         imRequireStall,
    input         dmRequireStall,
    input         fwdRequireStall,
    output        PC_stall,
    output        IF_ID_stall,
    output        ID_EX_stall,
    output        EX_MEM_stall,
    output        MEM_WB_stall,
    output        IF_ID_flush,
    output        ID_EX_flush,
    output        EX_MEM_flush,
    output        MEM_WB_flush
);
    reg    [31:0] regs[31:0];
    integer i;
    
    wire          int; // asserted when an interrupt is detected
    wire   [31:0] cause; // cause register, for convenience
    wire   [31:0] status; // status register, for convenience

    always @ (posedge clk)
    begin
        if (rst)
            for (i = 0; i < 32; i = i + 1)
                regs[i] = 32'b0;
        else 
        begin
            if (cp0Write && selW[2:0] == 0)
                regs[addrW] <= din;
            if (takeException && !EX_MEM_stall)
            begin
                // When not stalled, assert CP0.Status.EXL, update EPC and set Cause
                // CP0.Status.EXL
                regs[12] <= regs[12] | 32'h0000_0002;
                // EPC
                if (int)
                    regs[14] <= WB_pc4;
                else if (delaySlot)
                    regs[14] <= WB_pc4 - 8;
                else
                    regs[14] <= WB_pc4 - 4;
                // Cause.ExcCode
                if (dmExcept && memWrite)
                begin
                    regs[13] <= (regs[13] & 32'h7FFF_FF83) | {delaySlot, 31'h0000_0014};
                    regs[8] <= WB_aluDout;
                end
                else if (dmExcept && memRead)
                begin
                    regs[13] <= (regs[13] & 32'h7FFF_FF83) | {delaySlot, 31'h0000_0010};
                    regs[8] <= WB_aluDout;
                end
                else if (aluExcept)
                    regs[13] <= (regs[13] & 32'h7FFF_FF83) | {delaySlot, 31'h0000_0030};
                else if (ctrlExcept == 2'b01) // break
                    regs[13] <= (regs[13] & 32'h7FFF_FF83) | {delaySlot, 31'h0000_0024};
                else if (ctrlExcept == 2'b10) // syscall
                    regs[13] <= (regs[13] & 32'h7FFF_FF83) | {delaySlot, 31'h0000_0020};
                else if (ctrlExcept == 2'b11) // unknown instruction
                    regs[13] <= (regs[13] & 32'h7FFF_FF83) | {delaySlot, 31'h0000_0028};
                else if (imExcept)
                begin
                    regs[13] <= (regs[13] & 32'h7FFF_FF83) | {delaySlot, 31'h0000_0010};
                    regs[8] <= WB_pc4 - 4;
                end
                else if (int)
                    regs[13] <= (regs[13] & 32'h7FFF_FF83) | {delaySlot, 31'h0000_0000};
            end
            if (takeEret)
                // Deassert CP0.Status.EXL
                regs[12] <= regs[12] & 32'hFFFF_FFFD;
        end
    end

    assign dout = 
        selR[2:0] != 0                             ? 32'bX      :
        addrW == addrR && selR == selW && cp0Write ? din        : 
                                                     regs[addrR];

    assign status = addrW == 12 && selW == 0 && cp0Write ? din : regs[12];
    assign cause  = addrW == 13 && selW == 0 && cp0Write ? din : regs[13];
    assign epc    = addrW == 14 && selW == 0 && cp0Write ? din : regs[14];

    assign int = status[0] == 1 && status[1] == 0 && ((cause[9] && status[9]) || (cause[8] && status[8]));
    assign takeException = (imExcept || ctrlExcept != 2'b00 || aluExcept || dmExcept || int) && regs[12][1] == 0;

    assign PC_stall     = imRequireStall || dmRequireStall || fwdRequireStall;
    assign IF_ID_stall  = imRequireStall || dmRequireStall || fwdRequireStall;
    assign ID_EX_stall  = imRequireStall || dmRequireStall;
    assign EX_MEM_stall = imRequireStall || dmRequireStall;
    assign MEM_WB_stall = imRequireStall || dmRequireStall;

    assign IF_ID_flush  = takeEret || takeException;
    assign ID_EX_flush  = takeEret || takeException || (fwdRequireStall && !EX_MEM_stall);
    assign EX_MEM_flush = takeEret || takeException;
    assign MEM_WB_flush = 0;

endmodule
