module Extend(
    input[15:0] din,
    output[31:0] dout
);
    assign dout = {{16{din[15]}}, din};

endmodule