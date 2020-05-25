module MulDiv(
    input  [ 3:0] mdOp,
    input  [31:0] din1,
    input  [31:0] din2,
    output [31:0] hi,
    output [31:0] lo
);
    wire   [63:0] prodS, prodU;

    assign prodS = $signed(din1) * $signed(din2);
    assign prodU = din1 * din2;

    assign hi = 
        mdOp == 2'b00 ? $signed($signed(din1) % $signed(din2)) : // div
        mdOp == 2'b01 ? din1 % din2                   : // divu
        mdOp == 2'b10 ? prodS[63:32]                  : // mult
        mdOp == 2'b11 ? prodU[63:32]                  : // multu
                        32'bX                         ; // other
    assign lo = 
        mdOp == 2'b00 ? $signed($signed(din1) / $signed(din2)) : // div
        mdOp == 2'b01 ? din1 / din2                   : // divu
        mdOp == 2'b10 ? prodS[31:0]                   : // mult
        mdOp == 2'b11 ? prodU[31:0]                   : // multu
                        32'bX                         ; // other
endmodule