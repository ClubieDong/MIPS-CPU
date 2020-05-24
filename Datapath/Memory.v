module DataMemory(
    input         clk,
    input         rst,
    input  [31:0] addr,
    input  [31:0] din,
    input         memWrite,
    input         memRead,
    input  [ 1:0] memSize,
    input         memSign,
    output [31:0] dout
);
    // todo:
    // Exceptions

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

    assign dout = !memRead ? 32'bX :
         (memSize == 2'b00 ? byteEx     :
          memSize == 2'b01 ? halfWordEx :
          memSize == 2'b10 ? word       :
                             32'bX);
    
    always @ (posedge clk)
    begin
        if (rst)
            for (i = 0; i < 8192; i = i + 1)
                regs[i] <= 32'bX;
        if (memWrite)
            case (memSize)
                2'b00:                                                     regs[_addr]  <= din[ 7:0];
                2'b01: {                                  regs[_addr + 1], regs[_addr]} <= din[15:0];
                2'b10: {regs[_addr + 3], regs[_addr + 2], regs[_addr + 1], regs[_addr]} <= din      ;
            endcase
    end

endmodule


module InstructionMemory(
    input  [31:0] addr,
    output [31:0] dout
);
    // todo:
    // Exceptions

    reg    [31:0] regs[2047:0];
    
    initial
    begin
        $readmemh("F:/Project/TestCode/sort.txt", regs);
    end
    
    assign dout = regs[addr[12:2]];

endmodule
