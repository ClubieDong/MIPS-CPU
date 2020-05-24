module Extend(
    input  [15:0] din,
    input         extSign,
    output [31:0] dout
);
    assign dout = extSign ? {{16{din[15]}}, din} : {16'b0, din};

endmodule