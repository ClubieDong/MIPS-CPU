module Extend(
    input  [15:0] din,
    input         extSign,
    output [31:0] dout
);
    assign sign = extSign ? din[15] : 1'b0;
    assign dout = {{16{sign}}, din};

endmodule