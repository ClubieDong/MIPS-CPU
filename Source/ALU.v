module ALU(
    input  [ 3:0] aluOp,
    input  [31:0] din1,
    input  [31:0] din2,
    output [31:0] dout,
    output        exception
);
    wire   [32:0] din1Ex, din2Ex;
    wire   [32:0] addTemp, subTemp; // used for exceptions
    wire   [ 4:0] shift;

    assign din1Ex = $signed(din1);
    assign din2Ex = $signed(din2);
    assign addTemp = din1Ex + din2Ex;
    assign subTemp = din1Ex - din2Ex;
    assign shift = din1[4:0];
    
    assign exception = 
        aluOp == 4'b0000 && addTemp[32] != addTemp[31] ? 1 :
        aluOp == 4'b0010 && subTemp[32] != subTemp[31] ? 1 :
                                                         0 ;
    assign dout =
        aluOp == 4'b0000 ? (exception ? 32'bX : addTemp[31:0])     : // add/addi
        aluOp == 4'b0001 ? din1 + din2                             : // addu/addiu/memory
        aluOp == 4'b0010 ? (exception ? 32'bX : subTemp[31:0])     : // sub
        aluOp == 4'b0011 ? din1 - din2                             : // subu
        aluOp == 4'b0100 ? ($signed(din1) < $signed(din2) ? 1 : 0) : // slt/slti
        aluOp == 4'b0101 ? (din1 < din2 ? 1 : 0)                   : // sltu/sltiu
        aluOp == 4'b0110 ? din1 & din2                             : // and/andi
        aluOp == 4'b0111 ? {din2[15:0], 16'b0}                     : // lui
        aluOp == 4'b1000 ? ~(din1 | din2)                          : // nor
        aluOp == 4'b1001 ? din1 | din2                             : // or/ori
        aluOp == 4'b1010 ? din1 ^ din2                             : // xor/xori
        aluOp == 4'b1011 ? din2 << shift                           : // sllv/sll
        aluOp == 4'b1100 ? $signed($signed(din2) >>> shift)        : // srav/sra
        aluOp == 4'b1101 ? din2 >> shift                           : // srlv/srl
                           32'bX                                   ; // other

endmodule
