module mycpu_top(
    input         clk,
    input         resetn,
    input  [ 5:0] int,

    output        inst_sram_en,   
    output [ 3:0] inst_sram_wen,
    output [31:0] inst_sram_addr,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,

    output        data_sram_en,
    output [ 3:0] data_sram_wen,
    output [31:0] data_sram_addr,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata,

    output [31:0] debug_wb_pc,
    output [ 3:0] debug_wb_rf_wen,
    output [ 4:0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);
    wire          rst;
    wire   [31:0] epc;
    wire          takeException;
    // Stall and flush
    wire          imRequireStall;
    wire          fwdRequireStall;
    wire          dmRequireStall;
    wire          PC_stall;
    wire          IF_ID_stall;
    wire          ID_EX_stall;
    wire          EX_MEM_stall;
    wire          MEM_WB_stall;
    wire          IF_ID_flush;
    wire          ID_EX_flush;
    wire          EX_MEM_flush;
    wire          MEM_WB_flush;
    // IF Stage
    wire   [31:0] IF_pc;
    wire   [31:0] IF_pc4;
    wire   [31:0] IF_instr;
    wire          IF_imExcept;
    wire          IF_delaySlot;
    // ID Stage
    wire   [31:0] ID_pc4;
    wire   [31:0] ID_instr;
    wire   [31:0] ID_regDout1;
    wire   [31:0] ID_regDout2;
    wire   [31:0] ID_immEx;
    wire   [ 4:0] ID_regAddr3;
    wire          ID_imExcept;
    wire   [ 1:0] ID_ctrlExcept;
    wire          ID_delaySlot;
    wire   [ 3:0] ID_aluOp;
    wire          ID_aluDin1Src;
    wire          ID_aluDin2Src;
    wire   [ 1:0] ID_mdOp;
    wire          ID_memWrite;
    wire          ID_memRead;
    wire   [ 1:0] ID_memSize;
    wire          ID_memSign;
    wire          ID_regWrite;
    wire   [ 2:0] ID_regDinSrc;
    wire          ID_cp0Write;
    wire   [ 1:0] ID_hlWrite;
    wire          ID_hlDinHiSrc;
    wire          ID_hlDinLoSrc;
    wire          ID_takeEret;
    wire          ID_braEnable;
    wire   [ 2:0] ID_braOp;
    wire          ID_takeJumpImm;
    wire          ID_takeJumpReg;
    wire          ID_extSign;
    wire   [ 1:0] ID_regAddr3Src;
    wire   [31:0] ID_regDout1_unfwd;
    wire   [31:0] ID_regDout2_unfwd;
    wire          ID_takeBranch;
    // EX Stage
    wire   [31:0] EX_pc4;
    wire   [31:0] EX_instr;
    wire   [31:0] EX_aluDout;
    wire   [31:0] EX_regDout1;
    wire   [31:0] EX_regDout2;
    wire   [31:0] EX_mdDoutHi;
    wire   [31:0] EX_mdDoutLo;
    wire   [ 4:0] EX_regAddr3;
    wire          EX_imExcept;
    wire   [ 1:0] EX_ctrlExcept;
    wire          EX_aluExcept;
    wire          EX_delaySlot;
    wire          EX_memWrite;
    wire          EX_memRead;
    wire   [ 1:0] EX_memSize;
    wire          EX_memSign;
    wire          EX_regWrite;
    wire   [ 2:0] EX_regDinSrc;
    wire          EX_cp0Write;
    wire   [ 1:0] EX_hlWrite;
    wire          EX_hlDinHiSrc;
    wire          EX_hlDinLoSrc;
    wire          EX_takeEret;
    wire   [31:0] EX_immEx;
    wire   [ 3:0] EX_aluOp;
    wire          EX_aluDin1Src;
    wire          EX_aluDin2Src;
    wire   [ 1:0] EX_mdOp;
    wire   [31:0] EX_fwdFromMEM;
    wire   [31:0] EX_regDout1_unfwd;
    wire   [31:0] EX_regDout2_unfwd;
    // MEM Stage
    wire   [31:0] MEM_pc4;
    wire   [31:0] MEM_instr;
    wire   [31:0] MEM_aluDout;
    wire   [31:0] MEM_regDout1;
    wire   [31:0] MEM_regDout2;
    wire   [31:0] MEM_mdDoutHi;
    wire   [31:0] MEM_mdDoutLo;
    wire   [31:0] MEM_hlDoutHi;
    wire   [31:0] MEM_hlDoutLo;
    wire   [31:0] MEM_dmDout;
    wire   [31:0] MEM_cp0Dout;
    wire   [ 4:0] MEM_regAddr3;
    wire          MEM_imExcept;
    wire   [ 1:0] MEM_ctrlExcept;
    wire          MEM_aluExcept;
    wire          MEM_dmExcept;
    wire          MEM_delaySlot;
    wire          MEM_memWrite;
    wire          MEM_memRead;
    wire   [ 1:0] MEM_memSize;
    wire          MEM_memSign;
    wire          MEM_regWrite;
    wire   [ 2:0] MEM_regDinSrc;
    wire          MEM_cp0Write;
    wire   [ 1:0] MEM_hlWrite;
    wire          MEM_hlDinHiSrc;
    wire          MEM_hlDinLoSrc;
    wire          MEM_takeEret;
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
    wire   [ 4:0] WB_regAddr3;
    wire          WB_imExcept;
    wire   [ 1:0] WB_ctrlExcept;
    wire          WB_aluExcept;
    wire          WB_dmExcept;
    wire          WB_delaySlot;
    wire          WB_memWrite;
    wire          WB_memRead;
    wire          WB_regWrite;
    wire   [ 2:0] WB_regDinSrc;
    wire          WB_cp0Write;
    wire   [ 1:0] WB_hlWrite;
    wire          WB_hlDinHiSrc;
    wire          WB_hlDinLoSrc;
    wire          WB_takeEret;
    wire   [31:0] WB_regDin;

    assign rst = !resetn;
    assign debug_wb_pc = WB_pc4 - 4;
    assign debug_wb_rf_wen = MEM_WB_stall || takeException ? 4'b0 : {4{WB_regWrite}};
    assign debug_wb_rf_wnum = WB_regAddr3;
    assign debug_wb_rf_wdata = WB_regDin;

    PC PC
    (
        .clk          (clk           ), // input        
        .rst          (rst           ), // input        
        .stall        (PC_stall      ), // input        
        .branchImmEx  (ID_immEx      ), // input  [31:0]
        .jumpImm      (ID_instr[25:0]), // input  [25:0]
        .jumpReg      (ID_regDout1   ), // input  [31:0]
        .epc          (epc           ), // input  [31:0]
        .takeException(takeException ), // input        
        .takeEret     (WB_takeEret   ), // input        
        .takeBranch   (ID_takeBranch ), // input        
        .takeJumpImm  (ID_takeJumpImm), // input        
        .takeJumpReg  (ID_takeJumpReg), // input        
        .pc           (IF_pc         ), // output [31:0]
        .pc4          (IF_pc4        )  // output [31:0]
    );

    InstructionMemory InstructionMemory
    (
        .clk            (clk            ), // input        
        .rst            (rst            ), // input        
        .addr           (IF_pc          ), // input  [31:0]
        .dout           (IF_instr       ), // output [31:0]
        .requireStall   (imRequireStall ), // output       
        .exception      (IF_imExcept    ), // output       
        .inst_sram_en   (inst_sram_en   ), // output       
        .inst_sram_wen  (inst_sram_wen  ), // output [ 3:0]
        .inst_sram_addr (inst_sram_addr ), // output [31:0]
        .inst_sram_wdata(inst_sram_wdata), // output [31:0]
        .inst_sram_rdata(inst_sram_rdata)  // input  [31:0]
    );

    IF_ID IF_ID
    (
        .clk         (clk         ), // input        
        .rst         (rst         ), // input        
        .flush       (IF_ID_flush ), // input        
        .stall       (IF_ID_stall ), // input        
        .IF_pc4      (IF_pc4      ), // input  [31:0]
        .IF_instr    (IF_instr    ), // input  [31:0]
        .IF_imExcept (IF_imExcept ), // input        
        .IF_delaySlot(IF_delaySlot), // input        
        .ID_pc4      (ID_pc4      ), // output [31:0]
        .ID_instr    (ID_instr    ), // output [31:0]
        .ID_imExcept (ID_imExcept ), // output       
        .ID_delaySlot(ID_delaySlot)  // output       
    );

    Control Control
    (
        .instr      (ID_instr      ), // input  [31:0]
        .DelaySlot  (IF_delaySlot  ), // output       
        .BraEnable  (ID_braEnable  ), // output       
        .BraOp      (ID_braOp      ), // output [ 2:0]
        .TakeJumpImm(ID_takeJumpImm), // output       
        .TakeJumpReg(ID_takeJumpReg), // output       
        .ExtSign    (ID_extSign    ), // output       
        .RegAddr3Src(ID_regAddr3Src), // output [ 3:0]
        .AluOp      (ID_aluOp      ), // output       
        .AluDin1Src (ID_aluDin1Src ), // output       
        .AluDin2Src (ID_aluDin2Src ), // output [ 1:0]
        .MdOp       (ID_mdOp       ), // output       
        .MemWrite   (ID_memWrite   ), // output       
        .MemRead    (ID_memRead    ), // output [ 1:0]
        .MemSize    (ID_memSize    ), // output       
        .MemSign    (ID_memSign    ), // output       
        .RegWrite   (ID_regWrite   ), // output [ 1:0]
        .RegDinSrc  (ID_regDinSrc  ), // output [ 2:0]
        .Cp0Write   (ID_cp0Write   ), // output       
        .HlWrite    (ID_hlWrite    ), // output [ 1:0]
        .HlDinHiSrc (ID_hlDinHiSrc ), // output       
        .HlDinLoSrc (ID_hlDinLoSrc ), // output       
        .TakeEret   (ID_takeEret   ), // output       
        .Exception  (ID_ctrlExcept )  // output [ 1:0]
    );

    wire   [31:0] ID_fwdFromEX;
    wire   [31:0] ID_fwdFromMEM;
    assign WB_regDin = 
        WB_regDinSrc == 3'b000 ? WB_aluDout  :
        WB_regDinSrc == 3'b001 ? WB_pc4 + 4  :
        WB_regDinSrc == 3'b010 ? WB_hlDoutHi :
        WB_regDinSrc == 3'b011 ? WB_hlDoutLo :
        WB_regDinSrc == 3'b100 ? WB_dmDout   :
        WB_regDinSrc == 3'b101 ? WB_cp0Dout  :
                                 32'bX       ;
    RegFile RegFile
    (
        .clk     (clk                          ), // input        
        .rst     (rst                          ), // input        
        .addr1   (ID_instr[25:21]              ), // input  [ 4:0]
        .addr2   (ID_instr[20:16]              ), // input  [ 4:0]
        .addr3   (WB_regAddr3                  ), // input  [ 4:0]
        .din     (WB_regDin                    ), // input  [31:0]
        .regWrite(WB_regWrite && !takeException), // input        
        .dout1   (ID_regDout1_unfwd            ), // output [31:0]
        .dout2   (ID_regDout2_unfwd            )  // output [31:0]
    );
    assign ID_fwdFromEX = 
        EX_regDinSrc == 3'b000 ? EX_aluDout :
        EX_regDinSrc == 3'b001 ? EX_pc4 + 4 :
        EX_regDinSrc == 3'b010 ? 32'bX      : // not available yet
        EX_regDinSrc == 3'b011 ? 32'bX      : // not available yet
        EX_regDinSrc == 3'b100 ? 32'bX      : // not available yet
        EX_regDinSrc == 3'b101 ? 32'bX      : // not available yet
                                 32'bX      ; // invalid
    assign ID_fwdFromMEM = 
        MEM_regDinSrc == 3'b000 ? MEM_aluDout  :
        MEM_regDinSrc == 3'b001 ? MEM_pc4 + 4  :
        MEM_regDinSrc == 3'b010 ? MEM_hlDoutHi :
        MEM_regDinSrc == 3'b011 ? MEM_hlDoutLo :
        MEM_regDinSrc == 3'b100 ? MEM_dmDout   :
        MEM_regDinSrc == 3'b101 ? MEM_cp0Dout  :
                                  32'bX        ; // invalid
    assign ID_regDout1 = 
         EX_regWrite == 1 &&  EX_regAddr3 == ID_instr[25:21] &&  EX_regAddr3 != 0 ? ID_fwdFromEX      :
        MEM_regWrite == 1 && MEM_regAddr3 == ID_instr[25:21] && MEM_regAddr3 != 0 ? ID_fwdFromMEM     :
                                                                                    ID_regDout1_unfwd ; // no need to forward
    assign ID_regDout2 = 
         EX_regWrite == 1 &&  EX_regAddr3 == ID_instr[20:16] &&  EX_regAddr3 != 0 ? ID_fwdFromEX      :
        MEM_regWrite == 1 && MEM_regAddr3 == ID_instr[20:16] && MEM_regAddr3 != 0 ? ID_fwdFromMEM     :
                                                                                    ID_regDout2_unfwd ; // no need to forward
    assign fwdRequireStall = EX_regWrite == 1
        && EX_regAddr3 != 0
        && (EX_regAddr3 == ID_instr[25:21] || EX_regAddr3 == ID_instr[20:16])
        && (EX_regDinSrc == 3'b010 || EX_regDinSrc == 3'b011 || EX_regDinSrc == 3'b101);

    Branch Branch
    (
        .din1      (ID_regDout1  ), // input  [31:0]
        .din2      (ID_regDout2  ), // input  [31:0]
        .braEnable (ID_braEnable ), // input        
        .braOp     (ID_braOp     ), // input  [ 2:0]
        .takeBranch(ID_takeBranch)  // output       
    );

    Extend Extend
    (
        .din    (ID_instr[15:0]), // input  [15:0]
        .extSign(ID_extSign    ), // input        
        .dout   (ID_immEx      )  // output [31:0]
    );

    assign ID_regAddr3 =
        ID_regAddr3Src == 2'b00 ? ID_instr[15:11] : // rd field
        ID_regAddr3Src == 2'b01 ? ID_instr[20:16] : // rt field
        ID_regAddr3Src == 2'b10 ? 31              : // jal/bgezal/bltzal
                                  5'bX            ;
    ID_EX ID_EX
    (
        .clk          (clk              ), // input        
        .rst          (rst              ), // input        
        .flush        (ID_EX_flush      ), // input        
        .stall        (ID_EX_stall      ), // input        
        .ID_pc4       (ID_pc4           ), // input  [31:0]
        .ID_instr     (ID_instr         ), // input  [31:0]
        .ID_regDout1  (ID_regDout1      ), // input  [31:0]
        .ID_regDout2  (ID_regDout2      ), // input  [31:0]
        .ID_immEx     (ID_immEx         ), // input  [31:0]
        .ID_regAddr3  (ID_regAddr3      ), // input  [ 4:0]
        .ID_imExcept  (ID_imExcept      ), // input        
        .ID_ctrlExcept(ID_ctrlExcept    ), // input  [ 1:0]
        .ID_delaySlot (ID_delaySlot     ), // input        
        .ID_aluOp     (ID_aluOp         ), // input  [ 3:0]
        .ID_aluDin1Src(ID_aluDin1Src    ), // input        
        .ID_aluDin2Src(ID_aluDin2Src    ), // input        
        .ID_mdOp      (ID_mdOp          ), // input  [ 1:0]
        .ID_memWrite  (ID_memWrite      ), // input        
        .ID_memRead   (ID_memRead       ), // input        
        .ID_memSize   (ID_memSize       ), // input  [ 1:0]
        .ID_memSign   (ID_memSign       ), // input        
        .ID_regWrite  (ID_regWrite      ), // input        
        .ID_regDinSrc (ID_regDinSrc     ), // input  [ 2:0]
        .ID_cp0Write  (ID_cp0Write      ), // input        
        .ID_hlWrite   (ID_hlWrite       ), // input  [ 1:0]
        .ID_hlDinHiSrc(ID_hlDinHiSrc    ), // input        
        .ID_hlDinLoSrc(ID_hlDinLoSrc    ), // input        
        .ID_takeEret  (ID_takeEret      ), // input        
        .EX_pc4       (EX_pc4           ), // output [31:0]
        .EX_instr     (EX_instr         ), // output [31:0]
        .EX_regDout1  (EX_regDout1_unfwd), // output [31:0]
        .EX_regDout2  (EX_regDout2_unfwd), // output [31:0]
        .EX_immEx     (EX_immEx         ), // output [31:0]
        .EX_regAddr3  (EX_regAddr3      ), // output [ 4:0]
        .EX_imExcept  (EX_imExcept      ), // output       
        .EX_ctrlExcept(EX_ctrlExcept    ), // output [ 1:0]
        .EX_delaySlot (EX_delaySlot     ), // output       
        .EX_aluOp     (EX_aluOp         ), // output [ 3:0]
        .EX_aluDin1Src(EX_aluDin1Src    ), // output       
        .EX_aluDin2Src(EX_aluDin2Src    ), // output       
        .EX_mdOp      (EX_mdOp          ), // output [ 1:0]
        .EX_memWrite  (EX_memWrite      ), // output       
        .EX_memRead   (EX_memRead       ), // output       
        .EX_memSize   (EX_memSize       ), // output [ 1:0]
        .EX_memSign   (EX_memSign       ), // output       
        .EX_regWrite  (EX_regWrite      ), // output       
        .EX_regDinSrc (EX_regDinSrc     ), // output [ 2:0]
        .EX_cp0Write  (EX_cp0Write      ), // output       
        .EX_hlWrite   (EX_hlWrite       ), // output [ 1:0]
        .EX_hlDinHiSrc(EX_hlDinHiSrc    ), // output       
        .EX_hlDinLoSrc(EX_hlDinLoSrc    ), // output       
        .EX_takeEret  (EX_takeEret      )  // output       
    );
    assign EX_fwdFromMEM = 
        MEM_regDinSrc == 3'b000 ? MEM_aluDout :
        MEM_regDinSrc == 3'b001 ? MEM_pc4 + 4 :
        MEM_regDinSrc == 3'b010 ? 32'bX       : // not available yet
        MEM_regDinSrc == 3'b011 ? 32'bX       : // not available yet
        MEM_regDinSrc == 3'b100 ? MEM_dmDout  : // not available yet
        MEM_regDinSrc == 3'b101 ? 32'bX       : // not available yet
                                  32'bX       ; // invalid
    assign EX_regDout1 = 
        MEM_regWrite == 1 && MEM_regAddr3 == EX_instr[25:21] && MEM_regAddr3 != 0 ? EX_fwdFromMEM     :
                                                                                    EX_regDout1_unfwd ; // no need to forward
    assign EX_regDout2 = 
        MEM_regWrite == 1 && MEM_regAddr3 == EX_instr[20:16] && MEM_regAddr3 != 0 ? EX_fwdFromMEM     :
                                                                                    EX_regDout2_unfwd ; // no need to forward

    wire   [31:0] aluDin1;
    wire   [31:0] aluDin2;
    assign aluDin1 = EX_aluDin1Src ? {27'bX, EX_instr[10:6]} : EX_regDout1;
    assign aluDin2 = EX_aluDin2Src ? EX_immEx : EX_regDout2;
    ALU ALU
    (
        .aluOp    (EX_aluOp    ), // input  [ 3:0]
        .din1     (aluDin1     ), // input  [31:0]
        .din2     (aluDin2     ), // input  [31:0]
        .dout     (EX_aluDout  ), // output [31:0]
        .exception(EX_aluExcept)  // output       
    );

    MulDiv MulDiv
    (
        .mdOp  (EX_mdOp    ), // input  [ 1:0]
        .din1  (EX_regDout1), // input  [31:0]
        .din2  (EX_regDout2), // input  [31:0]
        .doutHi(EX_mdDoutHi), // output [31:0]
        .doutLo(EX_mdDoutLo)  // output [31:0]
    );

    EX_MEM EX_MEM
    (
        .clk           (clk           ), // input        
        .rst           (rst           ), // input        
        .flush         (EX_MEM_flush  ), // input        
        .stall         (EX_MEM_stall  ), // input        
        .EX_pc4        (EX_pc4        ), // input  [31:0]
        .EX_instr      (EX_instr      ), // input  [31:0]
        .EX_aluDout    (EX_aluDout    ), // input  [31:0]
        .EX_regDout1   (EX_regDout1   ), // input  [31:0]
        .EX_regDout2   (EX_regDout2   ), // input  [31:0]
        .EX_mdDoutHi   (EX_mdDoutHi   ), // input  [31:0]
        .EX_mdDoutLo   (EX_mdDoutLo   ), // input  [31:0]
        .EX_regAddr3   (EX_regAddr3   ), // input  [ 4:0]
        .EX_imExcept   (EX_imExcept   ), // input        
        .EX_ctrlExcept (EX_ctrlExcept ), // input  [ 1:0]
        .EX_aluExcept  (EX_aluExcept  ), // input        
        .EX_delaySlot  (EX_delaySlot  ), // input        
        .EX_memWrite   (EX_memWrite   ), // input        
        .EX_memRead    (EX_memRead    ), // input        
        .EX_memSize    (EX_memSize    ), // input  [ 1:0]
        .EX_memSign    (EX_memSign    ), // input        
        .EX_regWrite   (EX_regWrite   ), // input        
        .EX_regDinSrc  (EX_regDinSrc  ), // input  [ 2:0]
        .EX_cp0Write   (EX_cp0Write   ), // input        
        .EX_hlWrite    (EX_hlWrite    ), // input  [ 1:0]
        .EX_hlDinHiSrc (EX_hlDinHiSrc ), // input        
        .EX_hlDinLoSrc (EX_hlDinLoSrc ), // input        
        .EX_takeEret   (EX_takeEret   ), // output [31:0]
        .MEM_pc4       (MEM_pc4       ), // output [31:0]
        .MEM_instr     (MEM_instr     ), // output [31:0]
        .MEM_aluDout   (MEM_aluDout   ), // output [31:0]
        .MEM_regDout1  (MEM_regDout1  ), // output [31:0]
        .MEM_regDout2  (MEM_regDout2  ), // output [31:0]
        .MEM_mdDoutHi  (MEM_mdDoutHi  ), // output [31:0]
        .MEM_mdDoutLo  (MEM_mdDoutLo  ), // output [ 4:0]
        .MEM_regAddr3  (MEM_regAddr3  ), // output       
        .MEM_imExcept  (MEM_imExcept  ), // output       
        .MEM_ctrlExcept(MEM_ctrlExcept), // output [ 1:0]
        .MEM_aluExcept (MEM_aluExcept ), // output       
        .MEM_delaySlot (MEM_delaySlot ), // output       
        .MEM_memWrite  (MEM_memWrite  ), // output       
        .MEM_memRead   (MEM_memRead   ), // output [ 2:0]
        .MEM_memSize   (MEM_memSize   ), // output       
        .MEM_memSign   (MEM_memSign   ), // output [ 1:0]
        .MEM_regWrite  (MEM_regWrite  ), // output       
        .MEM_regDinSrc (MEM_regDinSrc ), // output       
        .MEM_cp0Write  (MEM_cp0Write  ), // output       
        .MEM_hlWrite   (MEM_hlWrite   ), // output       
        .MEM_hlDinHiSrc(MEM_hlDinHiSrc), // output       
        .MEM_hlDinLoSrc(MEM_hlDinLoSrc), // output       
        .MEM_takeEret  (MEM_takeEret  )  // output       
    );

    DataMemory DataMemory
    (
        .clk            (clk                                           ), // input        
        .rst            (rst                                           ), // input        
        .addr           (MEM_aluDout                                   ), // input  [31:0]
        .din            (MEM_regDout2                                  ), // input  [31:0]
        .memWrite       (MEM_memWrite && !takeException && !WB_takeEret), // input        
        .memRead        (MEM_memRead                                   ), // input        
        .memSize        (MEM_memSize                                   ), // input  [ 1:0]
        .memSign        (MEM_memSign                                   ), // input        
        .dout           (MEM_dmDout                                    ), // output [31:0]
        .requireStall   (dmRequireStall                                ), // output       
        .exception      (MEM_dmExcept                                  ), // output       
        .data_sram_en   (data_sram_en                                  ), // output       
        .data_sram_wen  (data_sram_wen                                 ), // output [ 3:0]
        .data_sram_addr (data_sram_addr                                ), // output [31:0]
        .data_sram_wdata(data_sram_wdata                               ), // output [31:0]
        .data_sram_rdata(data_sram_rdata                               )  // input  [31:0]
    );

    CP0 CP0
    (
        .clk            (clk             ), // input        
        .rst            (rst             ), // input        
        .addrR          (MEM_instr[15:11]), // input  [ 4:0]
        .selR           (MEM_instr[5:0]  ), // input  [ 5:0]
        .addrW          (WB_instr[15:11] ), // input  [ 4:0]
        .selW           (WB_instr[5:0]   ), // input  [ 5:0]
        .din            (WB_regDout2     ), // input  [31:0]
        .cp0Write       (WB_cp0Write     ), // input        
        .dout           (MEM_cp0Dout     ), // output [31:0]
        .epc            (epc             ), // output [31:0]
        .takeEret       (WB_takeEret     ), // input        
        .imExcept       (WB_imExcept     ), // input        
        .ctrlExcept     (WB_ctrlExcept   ), // input  [ 1:0]
        .aluExcept      (WB_aluExcept    ), // input        
        .dmExcept       (WB_dmExcept     ), // input        
        .memWrite       (WB_memWrite     ), // input        
        .memRead        (WB_memRead      ), // input        
        .delaySlot      (WB_delaySlot    ), // input        
        .WB_pc4         (WB_pc4          ), // input  [31:0]
        .WB_aluDout     (WB_aluDout      ), // input  [31:0]
        .takeException  (takeException   ), // output       
        .imRequireStall (imRequireStall  ), // input        
        .dmRequireStall (dmRequireStall  ), // input        
        .fwdRequireStall(fwdRequireStall ), // input        
        .PC_stall       (PC_stall        ), // output       
        .IF_ID_stall    (IF_ID_stall     ), // output       
        .ID_EX_stall    (ID_EX_stall     ), // output       
        .EX_MEM_stall   (EX_MEM_stall    ), // output       
        .MEM_WB_stall   (MEM_WB_stall    ), // output       
        .IF_ID_flush    (IF_ID_flush     ), // output       
        .ID_EX_flush    (ID_EX_flush     ), // output       
        .EX_MEM_flush   (EX_MEM_flush    ), // output       
        .MEM_WB_flush   (MEM_WB_flush    )  // output       
    );

    wire   [31:0] hlDinHi;
    wire   [31:0] hlDinLo;
    assign hlDinHi = WB_hlDinHiSrc ? WB_regDout1 : WB_mdDoutHi;
    assign hlDinLo = WB_hlDinLoSrc ? WB_regDout1 : WB_mdDoutLo;
    HiLo HiLo
    (
        .clk    (clk         ), // input        
        .rst    (rst         ), // input        
        .dinHi  (hlDinHi     ), // input  [31:0]
        .dinLo  (hlDinLo     ), // input  [31:0]
        .hlWrite(WB_hlWrite  ), // input  [ 1:0]
        .doutHi (MEM_hlDoutHi), // output [31:0]
        .doutLo (MEM_hlDoutLo)  // output [31:0]
    );

    MEM_WB MEM_WB
    (
        .clk           (clk           ), // input        
        .rst           (rst           ), // input        
        .flush         (MEM_WB_flush  ), // input        
        .stall         (MEM_WB_stall  ), // input        
        .MEM_pc4       (MEM_pc4       ), // input  [31:0]
        .MEM_instr     (MEM_instr     ), // input  [31:0]
        .MEM_aluDout   (MEM_aluDout   ), // input  [31:0]
        .MEM_regDout1  (MEM_regDout1  ), // input  [31:0]
        .MEM_regDout2  (MEM_regDout2  ), // input  [31:0]
        .MEM_mdDoutHi  (MEM_mdDoutHi  ), // input  [31:0]
        .MEM_mdDoutLo  (MEM_mdDoutLo  ), // input  [31:0]
        .MEM_hlDoutHi  (MEM_hlDoutHi  ), // input  [31:0]
        .MEM_hlDoutLo  (MEM_hlDoutLo  ), // input  [31:0]
        .MEM_dmDout    (MEM_dmDout    ), // input  [31:0]
        .MEM_cp0Dout   (MEM_cp0Dout   ), // input  [31:0]
        .MEM_regAddr3  (MEM_regAddr3  ), // input  [31:0]
        .MEM_imExcept  (MEM_imExcept  ), // input  [31:0]
        .MEM_ctrlExcept(MEM_ctrlExcept), // input  [31:0]
        .MEM_aluExcept (MEM_aluExcept ), // input  [31:0]
        .MEM_dmExcept  (MEM_dmExcept  ), // input  [ 4:0]
        .MEM_delaySlot (MEM_delaySlot ), // input        
        .MEM_memWrite  (MEM_memWrite  ), // input        
        .MEM_memRead   (MEM_memRead   ), // input        
        .MEM_regWrite  (MEM_regWrite  ), // input        
        .MEM_regDinSrc (MEM_regDinSrc ), // input  [ 2:0]
        .MEM_cp0Write  (MEM_cp0Write  ), // input        
        .MEM_hlWrite   (MEM_hlWrite   ), // input  [ 1:0]
        .MEM_hlDinHiSrc(MEM_hlDinHiSrc), // input        
        .MEM_hlDinLoSrc(MEM_hlDinLoSrc), // input        
        .MEM_takeEret  (MEM_takeEret  ), // output [31:0]
        .WB_pc4        (WB_pc4        ), // output [31:0]
        .WB_instr      (WB_instr      ), // output [31:0]
        .WB_aluDout    (WB_aluDout    ), // output [31:0]
        .WB_regDout1   (WB_regDout1   ), // output [31:0]
        .WB_regDout2   (WB_regDout2   ), // output [31:0]
        .WB_mdDoutHi   (WB_mdDoutHi   ), // output [31:0]
        .WB_mdDoutLo   (WB_mdDoutLo   ), // output [31:0]
        .WB_hlDoutHi   (WB_hlDoutHi   ), // output [31:0]
        .WB_hlDoutLo   (WB_hlDoutLo   ), // output [31:0]
        .WB_dmDout     (WB_dmDout     ), // output [31:0]
        .WB_cp0Dout    (WB_cp0Dout    ), // output [ 4:0]
        .WB_regAddr3   (WB_regAddr3   ), // output       
        .WB_imExcept   (WB_imExcept   ), // output [ 2:0]
        .WB_ctrlExcept (WB_ctrlExcept ), // output       
        .WB_aluExcept  (WB_aluExcept  ), // output [ 1:0]
        .WB_dmExcept   (WB_dmExcept   ), // output       
        .WB_delaySlot  (WB_delaySlot  ), // output       
        .WB_memWrite   (WB_memWrite   ), // input        
        .WB_memRead    (WB_memRead    ), // input        
        .WB_regWrite   (WB_regWrite   ), // output       
        .WB_regDinSrc  (WB_regDinSrc  ), // output       
        .WB_cp0Write   (WB_cp0Write   ), // output       
        .WB_hlWrite    (WB_hlWrite    ), // output       
        .WB_hlDinHiSrc (WB_hlDinHiSrc ), // output       
        .WB_hlDinLoSrc (WB_hlDinLoSrc ), // output       
        .WB_takeEret   (WB_takeEret   )  // output       
    );

endmodule
