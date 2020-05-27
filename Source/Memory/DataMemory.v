module DataMemory(
    input         clk,
    input  [31:0] addr,
    input  [31:0] din,
    input         memWrite,
    input         memRead,
    input  [ 1:0] memSize,
    input         memSign,
    output [31:0] dout,
    output        exception
);
    wire          data_sram_en;
    wire   [ 3:0] data_sram_wen;
    wire   [31:0] data_sram_addr;
    wire   [31:0] data_sram_wdata;
    wire   [31:0] data_sram_rdata;
    data_ram data_ram
    (
        .clka(clk),
        .ena(data_sram_en),
        .wea(data_sram_wen),
        .addra(data_sram_addr[17:2]),
        .dina(data_sram_wdata),
        .douta(data_sram_rdata)
    );

    assign exception = !(memWrite || memRead) ? 0 :
        memSize == 2'b01 && addr[  0] != 1'b0 ? 1 : // halfword
        memSize == 2'b10 && addr[1:0] != 2'b0 ? 1 : // word
                                                0 ;

    assign data_sram_en = (memWrite || memRead) && !exception;
    assign data_sram_wen = !memWrite ? 4'b0000 :
        memSize == 2'b00 ?           // byte
           (addr[1:0] == 2'b00 ? 4'b0001 :
            addr[1:0] == 2'b01 ? 4'b0010 :
            addr[1:0] == 2'b10 ? 4'b0100 :
            addr[1:0] == 2'b11 ? 4'b1000 :
                                 4'bX)   :
        memSize == 2'b01 ?           // halfword
           (addr[1  ] == 1'b0  ? 4'b0011 :
            addr[1  ] == 1'b1  ? 4'b1100 :
                                 4'bX)   :
        memSize == 2'b10 ? 4'b1111 : // word
                           4'bX    ;
    assign data_sram_addr = addr;
    assign data_sram_wdata = !memWrite ? 32'bX :
        memSize == 2'b00 ?        // byte
           (addr[1:0] == 2'b00 ? {8'bX    , 8'bX    , 8'bX    , din[7:0]} :
            addr[1:0] == 2'b01 ? {8'bX    , 8'bX    , din[7:0], 8'bX    } :
            addr[1:0] == 2'b10 ? {8'bX    , din[7:0], 8'bX    , 8'bX    } :
            addr[1:0] == 2'b11 ? {din[7:0], 8'bX    , 8'bX    , 8'bX    } :
                                 32'bX) :
        memSize == 2'b01 ?        // halfword
           (addr[1  ] == 1'b0  ? {16'bX    , din[15:0]} :
            addr[1  ] == 1'b1  ? {din[15:0], 16'bX    } :
                                 32'bX) :
        memSize == 2'b10 ? din  : // word
                           32'bX;

    wire   [ 7:0] byte;
    wire   [15:0] halfword;
    wire   [31:0] byteEx, halfwordEx;
    assign byte = 
        addr[1:0] == 2'b00 ? data_sram_rdata[ 7: 0] :
        addr[1:0] == 2'b01 ? data_sram_rdata[15: 8] :
        addr[1:0] == 2'b10 ? data_sram_rdata[23:16] :
        addr[1:0] == 2'b11 ? data_sram_rdata[31:24] :
                              8'bX                  ;
    assign halfword = 
        addr[1  ] == 1'b0  ? data_sram_rdata[15: 0] :
        addr[1  ] == 1'b1  ? data_sram_rdata[31:16] :
                             16'bX                  ;
    assign     byteEx = memSign ? {{24{    byte[ 7]}},     byte} :     byte;
    assign halfwordEx = memSign ? {{16{halfword[15]}}, halfword} : halfword;

    assign dout = !memRead || exception ? 32'bX :
        memSize == 2'b00 ? byteEx          : // byte
        memSize == 2'b01 ? halfwordEx      : // halfword
        memSize == 2'b10 ? data_sram_rdata : // word
                           32'bX           ;

endmodule
