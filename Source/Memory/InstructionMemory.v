module InstructionMemory(
    input         clk,
    input         rst,
    input  [31:0] addr,
    output [31:0] dout,
    output        requireStall,
    output        exception,

    output        inst_sram_en,   
    output [ 3:0] inst_sram_wen,
    output [31:0] inst_sram_addr,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata
);
    reg           stall;

    always @ (posedge clk)
    begin
        if (rst)
            stall <= 1;
        else
            stall <= !stall;
    end
    assign requireStall = stall && !exception;

    assign inst_sram_en = 1;
    assign inst_sram_wen = 4'b0;
    assign inst_sram_addr = {3'b0, addr[28:0]};
    assign inst_sram_wdata = 32'bX;
    
    assign exception = addr[1:0] != 2'b0;
    assign dout = exception ? 32'bX : inst_sram_rdata;

endmodule
