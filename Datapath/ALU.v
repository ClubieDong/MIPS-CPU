module ALU(
    input  [ 3:0] aluOp,
    input  [31:0] din1,
    input  [31:0] din2,
    output [31:0] dout,
    output        exception
);
    wire signed [32:0] din1SEx, din2SEx;
    wire        [32:0] din1UEx, din2UEx;
    wire        [32:0] addTemp, subTemp; // used for exceptions
    wire signed [ 4:0] shift;
    wire signed [31:0] din2S; // used for srav/sra
    wire        [31:0] sraResult;

    assign din1SEx = {din1[31], din1};
    assign din1UEx = {    1'b0, din1};
    assign din2SEx = {din2[31], din2};
    assign din2UEx = {    1'b0, din2};

    assign addTemp = din1SEx + din2SEx;
    assign subTemp = din1SEx - din2SEx;

    assign shift = din1[4:0];
    assign din2S = din2;
    assign sraResult = din2S >>> shift;
    
    assign exception = 
        aluOp == 4'b0000 && addTemp[32] != addTemp[31] ? 1 :
        aluOp == 4'b0010 && subTemp[32] != subTemp[31] ? 1 :
                                                         0 ;
    assign dout =
        aluOp == 4'b0000 ? (exception ? 32'bX : addTemp[31:0]) : // add/addi
        aluOp == 4'b0001 ? din1 + din2                         : // addu/addiu/memory
        aluOp == 4'b0010 ? (exception ? 32'bX : subTemp[31:0]) : // sub
        aluOp == 4'b0011 ? din1 - din2                         : // subu
        aluOp == 4'b0100 ? (din1SEx < din2SEx ? 1 : 0)         : // slt/slti
        aluOp == 4'b0101 ? (din1UEx < din2UEx ? 1 : 0)         : // sltu
        aluOp == 4'b0110 ? (din1UEx < din2SEx ? 1 : 0)         : // sltiu
        aluOp == 4'b0111 ? din1 & din2                         : // and/andi
        aluOp == 4'b1000 ? {din2[15:0], 16'b0}                 : // lui
        aluOp == 4'b1001 ? ~(din1 | din2)                      : // nor
        aluOp == 4'b1010 ? din1 | din2                         : // or/ori
        aluOp == 4'b1011 ? din1 ^ din2                         : // xor/xori
        aluOp == 4'b1100 ? din2 << shift                       : // sllv/sll
        aluOp == 4'b1101 ? sraResult                           : // srav/sra
        aluOp == 4'b1110 ? din2 >> shift                       : // srlv/srl
                           32'bX                               ; // other

endmodule