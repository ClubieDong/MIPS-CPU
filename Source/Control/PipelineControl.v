module PipelineControl(
    input         IF_requireStall,
    input         ID_requireStall,
    input         EX_requireStall,
    input         MEM_requireStall,
    input         WB_requireStall,
    output        PC_stall,
    output        IF_ID_stall,
    output        ID_EX_stall,
    output        EX_MEM_stall,
    output        MEM_WB_stall,
    output        IF_ID_flush,
    output        ID_EX_flush,
    output        EX_MEM_flush,
    output        MEM_WB_flush
);
    assign PC_stall     = IF_requireStall || ID_requireStall || EX_requireStall || MEM_requireStall || WB_requireStall;
    assign IF_ID_stall  =                    ID_requireStall || EX_requireStall || MEM_requireStall || WB_requireStall;
    assign ID_EX_stall  =                                       EX_requireStall || MEM_requireStall || WB_requireStall;
    assign EX_MEM_stall =                                                          MEM_requireStall || WB_requireStall;
    assign MEM_WB_stall =                                                                              WB_requireStall;

    assign IF_ID_flush  = IF_requireStall && !ID_requireStall && !EX_requireStall && !MEM_requireStall && !WB_requireStall;
    assign ID_EX_flush  =                     ID_requireStall && !EX_requireStall && !MEM_requireStall && !WB_requireStall;
    assign EX_MEM_flush =                                         EX_requireStall && !MEM_requireStall && !WB_requireStall;
    assign MEM_WB_flush =                                                             MEM_requireStall && !WB_requireStall;

endmodule
