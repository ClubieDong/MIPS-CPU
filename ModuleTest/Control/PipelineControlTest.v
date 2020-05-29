`timescale 1ns/1ps

module PipelineControlTest;
    reg           IF_requireStall;
    reg           ID_requireStall;
    reg           EX_requireStall;
    reg           MEM_requireStall;
    reg           WB_requireStall;
    wire          PC_stall;
    wire          IF_ID_stall;
    wire          ID_EX_stall;
    wire          EX_MEM_stall;
    wire          MEM_WB_stall;
    wire          IF_ID_flush;
    wire          ID_EX_flush;
    wire          EX_MEM_flush;
    wire          MEM_WB_flush;

    PipelineControl U1
    (
        .IF_requireStall(IF_requireStall),
        .ID_requireStall(ID_requireStall),
        .EX_requireStall(EX_requireStall),
        .MEM_requireStall(MEM_requireStall),
        .WB_requireStall(WB_requireStall),
        .PC_stall(PC_stall),
        .IF_ID_stall(IF_ID_stall),
        .ID_EX_stall(ID_EX_stall),
        .EX_MEM_stall(EX_MEM_stall),
        .MEM_WB_stall(MEM_WB_stall),
        .IF_ID_flush(IF_ID_flush),
        .ID_EX_flush(ID_EX_flush),
        .EX_MEM_flush(EX_MEM_flush),
        .MEM_WB_flush(MEM_WB_flush)
    );

    initial
    begin
        IF_requireStall = 0;
        ID_requireStall = 0;
        EX_requireStall = 0;
        MEM_requireStall = 0;
        WB_requireStall = 0;

        #20
        IF_requireStall = 1;
        ID_requireStall = 0;
        EX_requireStall = 0;
        MEM_requireStall = 0;
        WB_requireStall = 0;

        #20
        IF_requireStall = 0;
        ID_requireStall = 1;
        EX_requireStall = 0;
        MEM_requireStall = 0;
        WB_requireStall = 0;

        #20
        IF_requireStall = 0;
        ID_requireStall = 0;
        EX_requireStall = 1;
        MEM_requireStall = 0;
        WB_requireStall = 0;

        #20
        IF_requireStall = 0;
        ID_requireStall = 0;
        EX_requireStall = 0;
        MEM_requireStall = 1;
        WB_requireStall = 0;

        #20
        IF_requireStall = 0;
        ID_requireStall = 0;
        EX_requireStall = 0;
        MEM_requireStall = 0;
        WB_requireStall = 1;

        #20
        IF_requireStall = 1;
        ID_requireStall = 0;
        EX_requireStall = 0;
        MEM_requireStall = 1;
        WB_requireStall = 0;
    end
    
endmodule
