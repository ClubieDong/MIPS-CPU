module MIPS(
    input         clk,
    input         rst
);
    // IF Stage
    wire   [31:0] IF_pc;
    wire   [31:0] IF_pc4;
    PC PC
    (
        .clk           (clk           ), // input        
        .rst           (rst           ), // input        
        .branchImmEx   (ID_immEx      ), // input  [31:0]
        .jumpImm       (ID_instr[25:0]), // input  [25:0]
        .jumpReg       (ID_regDout1   ), // input  [31:0]
        .epc           (epc           ), // input  [31:0]
        .takeException (0             ), // input        
        .takeEret      (ID_takeEret   ), // input        
        .takeBranch    (ID_takeBranch ), // input        
        .takeJumpImm   (ID_takeJumpImm), // input        
        .takeJumpReg   (ID_takeJumpReg), // input        
        .pc            (IF_pc         ), // output [31:0]
        .pc4           (IF_pc4        )  // output [31:0]
    );

    wire   [31:0] IF_instr;
    wire          IF_imRequireStall;
    wire          IF_imExcept;
    InstructionMemory InstructionMemory
    (
        .clk          (clk              ), // input        
        .rst          (rst              ), // input        
        .addr         (IF_pc            ), // input  [31:0]
        .dout         (IF_instr         ), // output [31:0]
        .requireStall (IF_imRequireStall), // output  
        .exception    (IF_imExcept      )  // output       
    );

    // ID Stage
    wire   [31:0] ID_pc4;
    wire   [31:0] ID_instr;
    IF_ID IF_ID
    (
        .clk      (clk     ), // input        
        .rst      (rst     ), // input        
        .IF_pc4   (IF_pc4  ), // input  [31:0]
        .IF_instr (IF_instr), // input  [31:0]
        .ID_pc4   (ID_pc4  ), // output [31:0]
        .ID_instr (ID_instr)  // output [31:0]
    );

    wire          ID_braEnable;
    wire   [ 2:0] ID_braOp;
    wire          ID_takeEret;
    wire          ID_takeJumpImm;
    wire          ID_takeJumpReg;
    wire          ID_extSign;
    wire   [ 3:0] ID_aluOp;
    wire          ID_aluDin1Src;
    wire          ID_aluDin2Src;
    wire   [ 1:0] ID_mdOp;
    wire          ID_memWrite;
    wire          ID_memRead;
    wire   [ 1:0] ID_memSize;
    wire          ID_memSign;
    wire          ID_regWrite;
    wire   [ 1:0] ID_regAddr3Src;
    wire   [ 2:0] ID_regDinSrc;
    wire          ID_Cp0Write;
    wire   [ 1:0] ID_hlWrite;
    wire          ID_hlDinHiSrc;
    wire          ID_hlDinLoSrc;
    wire   [ 1:0] ID_ctrlExcept;
    Control Control
    (
        .instr       (ID_instr      ), // input  [31:0]
        .BraEnable   (ID_braEnable  ), // output       
        .BraOp       (ID_braOp      ), // output [ 2:0]
        .TakeEret    (ID_takeEret   ), // output       
        .TakeJumpImm (ID_takeJumpImm), // output       
        .TakeJumpReg (ID_takeJumpReg), // output       
        .ExtSign     (ID_extSign    ), // output       
        .AluOp       (ID_aluOp      ), // output [ 3:0]
        .AluDin1Src  (ID_aluDin1Src ), // output       
        .AluDin2Src  (ID_aluDin2Src ), // output       
        .MdOp        (ID_mdOp       ), // output [ 1:0]
        .MemWrite    (ID_memWrite   ), // output       
        .MemRead     (ID_memRead    ), // output       
        .MemSize     (ID_memSize    ), // output [ 1:0]
        .MemSign     (ID_memSign    ), // output       
        .RegWrite    (ID_regWrite   ), // output       
        .RegAddr3Src (ID_regAddr3Src), // output [ 1:0]
        .RegDinSrc   (ID_regDinSrc  ), // output [ 2:0]
        .Cp0Write    (ID_Cp0Write   ), // output       
        .HlWrite     (ID_hlWrite    ), // output [ 1:0]
        .HlDinHiSrc  (ID_hlDinHiSrc ), // output       
        .HlDinLoSrc  (ID_hlDinLoSrc ), // output       
        .Exception   (ID_ctrlExcept )  // output [ 1:0]
    );

    wire   [31:0] ID_regDout1;
    wire   [31:0] ID_regDout2;
    wire   [ 4:0] regAddr3;
    wire   [31:0] regDin;
    assign regAddr3 =
        WB_regAddr3Src == 2'b00 ? WB_instr[15:11] : // rd field
        WB_regAddr3Src == 2'b01 ? WB_instr[20:16] : // rt field
        WB_regAddr3Src == 2'b10 ? 31              : // jal/bgezal/bltzal
                                  5'bX            ;
    assign regDin = 
        WB_regDinSrc == 3'b000 ? WB_aluDout  :
        WB_regDinSrc == 3'b001 ? WB_pc4 + 4  :
        WB_regDinSrc == 3'b010 ? WB_hlDoutHi :
        WB_regDinSrc == 3'b011 ? WB_hlDoutLo :
        WB_regDinSrc == 3'b100 ? WB_dmDout   :
        WB_regDinSrc == 3'b101 ? WB_cp0Dout  :
                                 32'bX       ;
    RegFile RegFile
    (
        .clk      (clk            ), // input        
        .rst      (rst            ), // input        
        .addr1    (ID_instr[25:21]), // input  [ 4:0]
        .addr2    (ID_instr[20:16]), // input  [ 4:0]
        .addr3    (regAddr3       ), // input  [ 4:0]
        .din      (regDin         ), // input  [31:0]
        .regWrite (WB_regWrite    ), // input        
        .dout1    (ID_regDout1    ), // output [31:0]
        .dout2    (ID_regDout2    )  // output [31:0]
    );

    wire          ID_takeBranch;
    Branch Branch
    (
        .din1       (ID_regDout1  ), // input  [31:0]
        .din2       (ID_regDout2  ), // input  [31:0]
        .braEnable  (ID_braEnable ), // input        
        .braOp      (ID_braOp     ), // input  [ 2:0]
        .takeBranch (ID_takeBranch)  // output       
    );

    wire   [31:0] ID_immEx;
    Extend Extend
    (
        .din     (ID_instr[15:0]), // input  [15:0]
        .extSign (ID_extSign    ), // input        
        .dout    (ID_immEx      )  // output [31:0]
    );

    // EX Stage
    wire   [31:0] EX_pc4;
    wire   [31:0] EX_instr;
    wire   [31:0] EX_regDout1;
    wire   [31:0] EX_regDout2;
    wire   [31:0] EX_immEx;
    wire   [ 3:0] EX_aluOp;
    wire          EX_aluDin1Src;
    wire          EX_aluDin2Src;
    wire   [ 1:0] EX_mdOp;
    wire          EX_memWrite;
    wire          EX_memRead;
    wire   [ 1:0] EX_memSize;
    wire          EX_memSign;
    wire          EX_regWrite;
    wire   [ 1:0] EX_regAddr3Src;
    wire   [ 2:0] EX_regDinSrc;
    wire          EX_cp0Write;
    wire   [ 1:0] EX_hlWrite;
    wire          EX_hlDinHiSrc;
    wire          EX_hlDinLoSrc;
    ID_EX ID_EX
    (
        .clk            (clk           ), // input        
        .rst            (rst           ), // input        
        .ID_pc4         (ID_pc4        ), // input  [31:0]
        .ID_instr       (ID_instr      ), // input  [31:0]
        .ID_regDout1    (ID_regDout1   ), // input  [31:0]
        .ID_regDout2    (ID_regDout2   ), // input  [31:0]
        .ID_immEx       (ID_immEx      ), // input  [31:0]
        .ID_aluOp       (ID_aluOp      ), // input  [ 3:0]
        .ID_aluDin1Src  (ID_aluDin1Src ), // input        
        .ID_aluDin2Src  (ID_aluDin2Src ), // input        
        .ID_mdOp        (ID_mdOp       ), // input  [ 1:0]
        .ID_memWrite    (ID_memWrite   ), // input        
        .ID_memRead     (ID_memRead    ), // input        
        .ID_memSize     (ID_memSize    ), // input  [ 1:0]
        .ID_memSign     (ID_memSign    ), // input        
        .ID_regWrite    (ID_regWrite   ), // input        
        .ID_regAddr3Src (ID_regAddr3Src), // input  [ 1:0]
        .ID_regDinSrc   (ID_regDinSrc  ), // input  [ 2:0]
        .ID_cp0Write    (ID_cp0Write   ), // input        
        .ID_hlWrite     (ID_hlWrite    ), // input  [ 1:0]
        .ID_hlDinHiSrc  (ID_hlDinHiSrc ), // input        
        .ID_hlDinLoSrc  (ID_hlDinLoSrc ), // input        
        .EX_pc4         (EX_pc4        ), // output [31:0]
        .EX_instr       (EX_instr      ), // output [31:0]
        .EX_regDout1    (EX_regDout1   ), // output [31:0]
        .EX_regDout2    (EX_regDout2   ), // output [31:0]
        .EX_immEx       (EX_immEx      ), // output [31:0]
        .EX_aluOp       (EX_aluOp      ), // output [ 3:0]
        .EX_aluDin1Src  (EX_aluDin1Src ), // output       
        .EX_aluDin2Src  (EX_aluDin2Src ), // output       
        .EX_mdOp        (EX_mdOp       ), // output [ 1:0]
        .EX_memWrite    (EX_memWrite   ), // output       
        .EX_memRead     (EX_memRead    ), // output       
        .EX_memSize     (EX_memSize    ), // output [ 1:0]
        .EX_memSign     (EX_memSign    ), // output       
        .EX_regWrite    (EX_regWrite   ), // output       
        .EX_regAddr3Src (EX_regAddr3Src), // output [ 1:0]
        .EX_regDinSrc   (EX_regDinSrc  ), // output [ 2:0]
        .EX_cp0Write    (EX_cp0Write   ), // output       
        .EX_hlWrite     (EX_hlWrite    ), // output [ 1:0]
        .EX_hlDinHiSrc  (EX_hlDinHiSrc ), // output       
        .EX_hlDinLoSrc  (EX_hlDinLoSrc ), // output       
    );

    wire   [31:0] EX_aluDout;
    wire          EX_aluExcept;
    wire   [31:0] aluDin1;
    wire   [31:0] aluDin2;
    assign aluDin1 = EX_aluDin1Src ? {27'bX, EX_instr[10:6]} : EX_regDout1;
    assign aluDin2 = EX_aluDin2Src ? EX_immEx : EX_regDout2;
    ALU ALU
    (
        .aluOp     (EX_aluOp    ), // input  [ 3:0]
        .din1      (aluDin1     ), // input  [31:0]
        .din2      (aluDin2     ), // input  [31:0]
        .dout      (EX_aluDout  ), // output [31:0]
        .exception (EX_aluExcept)  // output       
    );

    wire   [31:0] EX_mdDoutHi;
    wire   [31:0] EX_mdDoutLo;
    MulDiv MulDiv
    (
        .mdOp   (EX_mdOp    ), // input  [ 1:0]
        .din1   (EX_regDout1), // input  [31:0]
        .din2   (EX_regDout2), // input  [31:0]
        .doutHi (EX_mdDoutHi), // output [31:0]
        .doutLo (EX_mdDoutLo)  // output [31:0]
    );

    // MEM Stage
    wire   [31:0] MEM_pc4;
    wire   [31:0] MEM_instr;
    wire   [31:0] MEM_aluDout;
    wire   [31:0] MEM_regDout1;
    wire   [31:0] MEM_regDout2;
    wire   [31:0] MEM_mdDoutHi;
    wire   [31:0] MEM_mdDoutLo;
    wire          MEM_memWrite;
    wire          MEM_memRead;
    wire   [ 1:0] MEM_memSize;
    wire          MEM_memSign;
    wire          MEM_regWrite;
    wire   [ 1:0] MEM_regAddr3Src;
    wire   [ 2:0] MEM_regDinSrc;
    wire          MEM_cp0Write;
    wire   [ 1:0] MEM_hlWrite;
    wire          MEM_hlDinHiSrc;
    wire          MEM_hlDinLoSrc;
    EX_MEM EX_MEM
    (
        .clk             (clk            ), // input        
        .rst             (rst            ), // input        
        .EX_pc4          (EX_pc4         ), // input  [31:0]
        .EX_instr        (EX_instr       ), // input  [31:0]
        .EX_aluDout      (EX_aluDout     ), // input  [31:0]
        .EX_regDout1     (EX_regDout1    ), // input  [31:0]
        .EX_regDout2     (EX_regDout2    ), // input  [31:0]
        .EX_mdDoutHi     (EX_mdDoutHi    ), // input  [31:0]
        .EX_mdDoutLo     (EX_mdDoutLo    ), // input  [31:0]
        .EX_memWrite     (EX_memWrite    ), // input        
        .EX_memRead      (EX_memRead     ), // input        
        .EX_memSize      (EX_memSize     ), // input  [ 1:0]
        .EX_memSign      (EX_memSign     ), // input        
        .EX_regWrite     (EX_regWrite    ), // input        
        .EX_regAddr3Src  (EX_regAddr3Sr  ), // input  [ 1:0]
        .EX_regDinSrc    (EX_regDinSrc   ), // input  [ 2:0]
        .EX_cp0Write     (EX_cp0Write    ), // input        
        .EX_hlWrite      (EX_hlWrite     ), // input  [ 1:0]
        .EX_hlDinHiSrc   (EX_hlDinHiSrc  ), // input        
        .EX_hlDinLoSrc   (EX_hlDinLoSrc  ), // input        
        .MEM_pc4         (MEM_pc4        ), // output [31:0]
        .MEM_instr       (MEM_instr      ), // output [31:0]
        .MEM_aluDout     (MEM_aluDout    ), // output [31:0]
        .MEM_regDout1    (MEM_regDout1   ), // output [31:0]
        .MEM_regDout2    (MEM_regDout2   ), // output [31:0]
        .MEM_mdDoutHi    (MEM_mdDoutHi   ), // output [31:0]
        .MEM_mdDoutLo    (MEM_mdDoutLo   ), // output [31:0]
        .MEM_memWrite    (MEM_memWrite   ), // output       
        .MEM_memRead     (MEM_memRead    ), // output       
        .MEM_memSize     (MEM_memSize    ), // output [ 1:0]
        .MEM_memSign     (MEM_memSign    ), // output       
        .MEM_regWrite    (MEM_regWrite   ), // output       
        .MEM_regAddr3Src (MEM_regAddr3Src), // output [ 1:0]
        .MEM_regDinSrc   (MEM_regDinSrc  ), // output [ 2:0]
        .MEM_cp0Write    (MEM_cp0Write   ), // output       
        .MEM_hlWrite     (MEM_hlWrite    ), // output [ 1:0]
        .MEM_hlDinHiSrc  (MEM_hlDinHiSrc ), // output       
        .MEM_hlDinLoSrc  (MEM_hlDinLoSrc )  // output       
    );

    wire   [31:0] MEM_dmDout;
    wire          MEM_dmRequireStall;
    wire          MEM_dmExcept;
    DataMemory DataMemory
    (
        .clk          (clk                ), // input        
        .rst          (rst                ), // input        
        .addr         (MEM_aluDout        ), // input  [31:0]
        .din          (MEM_regDout2       ), // input  [31:0]
        .memWrite     (MEM_memWrite       ), // input        
        .memRead      (MEM_memRead        ), // input        
        .memSize      (MEM_memSize        ), // input  [ 1:0]
        .memSign      (MEM_Sign           ), // input        
        .dout         (MEM_dmDout        ), // output [31:0]
        .requireStall (MEM_dmRequireStall), // output       
        .exception    (MEM_dmExcept      )  // output       
    );

    wire   [31:0] MEM_cp0Dout;
    wire   [31:0] epc;
    CP0 CP0
    (
        .clk      (clk             ), // input        
        .rst      (rst             ), // input        
        .addrR    (MEM_instr[15:11]), // input  [ 4:0]
        .selR     (MEM_instr[5:0]  ), // input  [ 5:0]
        .addrW    (WB_instr[15:11] ), // input  [ 4:0]
        .selW     (WB_instr[5:0]   ), // input  [ 5:0]
        .din      (WB_regDout2     ), // input  [31:0]
        .cp0Write (WB_cp0Write     ), // input        
        .dout     (MEM_cp0Dout     ), // output [31:0]
        .epc      (epc             )  // output [31:0]
    );

    wire   [31:0] MEM_hlDoutHi;
    wire   [31:0] MEM_hlDoutLo;
    wire   [31:0] hlDinHi;
    wire   [31:0] hlDinLo;
    assign hlDinHi = WB_hlDinHiSrc ? WB_regDout1 : WB_mdDoutHi;
    assign hlDinLo = WB_hlDinLoSrc ? WB_regDout1 : WB_mdDoutLo;
    HiLo HiLo
    (
        .clk     (clk         ), // input        
        .rst     (rst         ), // input        
        .dinHi   (hlDinHi     ), // input  [31:0]
        .dinLo   (hlDinLo     ), // input  [31:0]
        .hlWrite (WB_hlWrite  ), // input  [ 1:0]
        .doutHi  (MEM_hlDoutHi), // output [31:0]
        .doutLo  (MEM_hlDoutLo)  // output [31:0]
    );

    // WB Stage
    wire   [31:0] WB_pc4;
    wire   [31:0] WB_instr;
    wire   [31:0] WB_aluDout;
    wire   [31:0] WB_regDout1;
    wire   [31:0] WB_regDout2;
    wire   [31:0] WB_mdDoutHi;
    wire   [31:0] WB_mdDoutLo;
    wire   [31:0] WB_hlDoutHi;
    wire   [31:0] WB_hlDoutLo;
    wire   [31:0] WB_dmDout;
    wire   [31:0] WB_cp0Dout;
    wire          WB_regWrite;
    wire   [ 1:0] WB_regAddr3Src;
    wire   [ 2:0] WB_regDinSrc;
    wire          WB_cp0Write;
    wire   [ 1:0] WB_hlWrite;
    wire          WB_hlDinHiSrc;
    wire          WB_hlDinLoSrc;
    MEM_WB MEM_WB
    (
        .clk             (clk            ), // input        
        .rst             (rst            ), // input        
        .MEM_pc4         (MEM_pc4        ), // input  [31:0]
        .MEM_instr       (MEM_instr      ), // input  [31:0]
        .MEM_aluDout     (MEM_aluDout    ), // input  [31:0]
        .MEM_regDout1    (MEM_regDout1   ), // input  [31:0]
        .MEM_regDout2    (MEM_regDout2   ), // input  [31:0]
        .MEM_mdDoutHi    (MEM_mdDoutHi   ), // input  [31:0]
        .MEM_mdDoutLo    (MEM_mdDoutLo   ), // input  [31:0]
        .MEM_hlDoutHi    (MEM_hlDoutHi   ), // input  [31:0]
        .MEM_hlDoutLo    (MEM_hlDoutLo   ), // input  [31:0]
        .MEM_dmDout      (MEM_dmDout     ), // input  [31:0]
        .MEM_cp0Dout     (MEM_cp0Dout    ), // input  [31:0]
        .MEM_regWrite    (MEM_regWrite   ), // input        
        .MEM_regAddr3Src (MEM_regAddr3Src), // input  [ 1:0]
        .MEM_regDinSrc   (MEM_regDinSrc  ), // input  [ 2:0]
        .MEM_cp0Write    (MEM_cp0Write   ), // input        
        .MEM_hlWrite     (MEM_hlWrite    ), // input  [ 1:0]
        .MEM_hlDinHiSrc  (MEM_hlDinHiSrc ), // input        
        .MEM_hlDinLoSrc  (MEM_hlDinLoSrc ), // input        
        .WB_pc4          (WB_pc4         ), // output [31:0]
        .WB_instr        (WB_instr       ), // output [31:0]
        .WB_aluDout      (WB_aluDout     ), // output [31:0]
        .WB_regDout1     (WB_regDout1    ), // output [31:0]
        .WB_regDout2     (WB_regDout2    ), // output [31:0]
        .WB_mdDoutHi     (WB_mdDoutHi    ), // output [31:0]
        .WB_mdDoutLo     (WB_mdDoutLo    ), // output [31:0]
        .WB_hlDoutHi     (WB_hlDoutHi    ), // output [31:0]
        .WB_hlDoutLo     (WB_hlDoutLo    ), // output [31:0]
        .WB_dmDout       (WB_dmDout      ), // output [31:0]
        .WB_cp0Dout      (WB_cp0Dout     ), // output [31:0]
        .WB_regWrite     (WB_regWrite    ), // output       
        .WB_regAddr3Src  (WB_regAddr3Src ), // output [ 1:0]
        .WB_regDinSrc    (WB_regDinSrc   ), // output [ 2:0]
        .WB_cp0Write     (WB_cp0Write    ), // output       
        .WB_hlWrite      (WB_hlWrite     ), // output [ 1:0]
        .WB_hlDinHiSrc   (WB_hlDinHiSrc  ), // output       
        .WB_hlDinLoSrc   (WB_hlDinLoSrc  )  // output       
    );

endmodule
