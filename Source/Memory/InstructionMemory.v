module InstructionMemory(
    input         clk,
    input         rst,
    input  [31:0] addr,
    output [31:0] dout,
    output        requireStall,
    output        exception
);
    reg           stall;

    wire          inst_sram_en;   
    wire   [ 3:0] inst_sram_wen;
    wire   [31:0] inst_sram_addr;
    wire   [31:0] inst_sram_wdata;
    wire   [31:0] inst_sram_rdata;
    inst_ram inst_ram
    (
        .clka(clk),
        .ena(inst_sram_en),
        .wea(inst_sram_wen),
        .addra(inst_sram_addr[19:2]),
        .dina(inst_sram_wdata),
        .douta(inst_sram_rdata)
    );

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
    assign inst_sram_addr = addr;
    assign inst_sram_wdata = 32'bX;
    
    assign exception = addr[1:0] != 2'b0;
    assign dout = exception ? 32'bX : inst_sram_rdata;

endmodule
