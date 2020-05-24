module DataMemory(
    input         clk,
    input         rst,
    input  [31:0] addr,
    input  [31:0] din,
    input         memWrite,
    input         memRead,
    input  [ 1:0] memSize,
    input         memSign,
    output [31:0] dout,
    output        exception
);
    reg    [ 7:0] regs[8191:0];
    wire   [12:0] _addr;
    wire   [ 7:0] byte;
    wire   [15:0] halfWord;
    wire   [31:0] word;
    wire   [31:0] byteEx, halfWordEx;
    integer i;

    assign _addr = addr[12:0];
    assign byte     =                                                     regs[_addr] ;
    assign halfWord = {                                  regs[_addr + 1], regs[_addr]};
    assign word     = {regs[_addr + 3], regs[_addr + 2], regs[_addr + 1], regs[_addr]};
    assign byteEx     = memSign ? {{24{byte[7]}},      byte}     : {24'b0, byte}    ;
    assign halfWordEx = memSign ? {{16{halfWord[15]}}, halfWord} : {24'b0, halfWord};

    assign exception = 
        !(memRead || memWrite)                ? 0 :
        memSize == 2'b01 && addr[  0] != 1'b0 ? 1 : // half word
        memSize == 2'b10 && addr[1:0] != 2'b0 ? 1 : // word
                                                0 ;

    assign dout = 
        !memRead || exception ? 32'bX      :
        memSize == 2'b00      ? byteEx     : // byte
        memSize == 2'b01      ? halfWordEx : // half word
        memSize == 2'b10      ? word       : // word
                                32'bX      ; // other

    always @ (posedge clk)
    begin
        if (rst)
            for (i = 0; i < 8192; i = i + 1)
                regs[i] <= 32'bX;
        else if (memWrite && !exception)
            case (memSize)
                2'b00:                                                     regs[_addr]  <= din[ 7:0];
                2'b01: {                                  regs[_addr + 1], regs[_addr]} <= din[15:0];
                2'b10: {regs[_addr + 3], regs[_addr + 2], regs[_addr + 1], regs[_addr]} <= din      ;
            endcase
    end

endmodule


module InstructionMemory(
    input  [31:0] addr,
    output [31:0] dout,
    output        exception
);
    reg    [31:0] regs[2047:0];
    
    initial
    begin
        $readmemh("F:/Project/TestCode/sort.txt", regs);
    end
    
    assign exception = addr[1:0] != 2'b0;
    assign dout = exception ? 32'bX : regs[addr[12:2]];

endmodule
