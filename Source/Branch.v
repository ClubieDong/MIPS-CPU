module Branch(
    input  [31:0] din1,
    input  [31:0] din2,
    input         braEnable,
    input  [ 2:0] braOp,
    output        takeBranch
);
    wire          result;

    assign result =
        braOp == 3'b000 ? din1 == din2          : // beq
        braOp == 3'b001 ? din1 != din2          : // bne
        braOp == 3'b010 ? $signed(din1) >= 0    : // bgez/bgezal
        braOp == 3'b011 ? $signed(din1) >  0    : // bgtz
        braOp == 3'b100 ? $signed(din1) <= 0    : // blez
        braOp == 3'b101 ? $signed(din1) <  0    : // bltz/bltzal
                          1'bX                  ; // other
    assign takeBranch = braEnable && result;

endmodule
