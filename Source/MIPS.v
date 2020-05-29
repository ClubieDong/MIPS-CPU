// module MIPS(
//     .clk(clk),
//     .rst(rst)
// );
//     // IF Stage
//     wire   [31:0] IF_pc;
//     wire   [31:0] IF_pc4;
//     PC PC
//     (
//         .clk           (clk  ), // input        
//         .rst           (rst  ), // input        
//         .branchImmEx   (XXXXX), // input  [31:0]
//         .jumpImm       (XXXXX), // input  [25:0]
//         .jumpReg       (XXXXX), // input  [31:0]
//         .epc           (XXXXX), // input  [31:0]
//         .takeException (XXXXX), // input        
//         .takeEret      (XXXXX), // input        
//         .takeBranch    (XXXXX), // input        
//         .takeJumpImm   (XXXXX), // input        
//         .takeJumpReg   (XXXXX), // input        
//         .pc            (IF_pc), // output [31:0]
//         .pc4           (IF_pc4)  // output [31:0]
//     );

//     wire   [31:0] IF_instr;
//     wire          IF_imExcept;
//     InstructionMemory InstructionMemory
//     (
//         .clk       (clk        ), // input        
//         .addr      (IF_pc      ), // input  [31:0]
//         .dout      (IF_instr   ), // output [31:0]
//         .exception (IF_imExcept)  // output       
//     );

//     // ID Stage
//     wire   [31:0] ID_pc4;
//     wire   [31:0] ID_instr;
//     IF_ID IF_ID
//     (
//         .clk      (clk     ), // input        
//         .rst      (rst     ), // input        
//         .IF_pc4   (IF_pc4  ), // input  [31:0]
//         .IF_instr (IF_instr), // input  [31:0]
//         .ID_pc4   (ID_pc4  ), // output [31:0]
//         .ID_instr (ID_instr)  // output [31:0]
//     );

//     wire          ID_braEnable;
//     wire   [ 2:0] ID_braOp;
//     wire          ID_takeJumpImm;
//     wire          ID_takeJumpReg;
//     wire          ID_extSign;
//     wire   [ 3:0] ID_aluOp;
//     wire          ID_aluDin1Src;
//     wire          ID_aluDin2Src;
//     wire   [ 1:0] ID_mdOp;
//     wire          ID_memWrite;
//     wire          ID_memRead;
//     wire   [ 1:0] ID_memSize;
//     wire          ID_memSign;
//     wire          ID_regWrite;
//     wire   [ 1:0] ID_regAddr3Src;
//     wire   [ 2:0] ID_regDinSrc;
//     wire   [ 1:0] ID_hlWrite;
//     wire          ID_hlDinHiSrc;
//     wire          ID_hlDinLoSrc;
//     wire          ID_takeEret;
//     wire          ID_exception;
//     Control Control
//     (
//         .instr       (ID_instr      ), // input  [31:0]
//         .BraEnable   (ID_braEnable  ), // output       
//         .BraOp       (ID_braOp      ), // output [ 2:0]
//         .TakeJumpImm (ID_takeJumpImm), // output       
//         .TakeJumpReg (ID_takeJumpReg), // output       
//         .ExtSign     (ID_extSign    ), // output       
//         .AluOp       (ID_aluOp      ), // output [ 3:0]
//         .AluDin1Src  (ID_aluDin1Src ), // output       
//         .AluDin2Src  (ID_aluDin2Src ), // output       
//         .MdOp        (ID_mdOp       ), // output [ 1:0]
//         .MemWrite    (ID_memWrite   ), // output       
//         .MemRead     (ID_memRead    ), // output       
//         .MemSize     (ID_memSize    ), // output [ 1:0]
//         .MemSign     (ID_memSign    ), // output       
//         .RegWrite    (ID_regWrite   ), // output       
//         .RegAddr3Src (ID_regAddr3Src), // output [ 1:0]
//         .RegDinSrc   (ID_regDinSrc  ), // output [ 2:0]
//         .HlWrite     (ID_hlWrite    ), // output [ 1:0]
//         .HlDinHiSrc  (ID_hlDinHiSrc ), // output       
//         .HlDinLoSrc  (ID_hlDinLoSrc ), // output       
//         .TakeEret    (ID_takeEret   ), // output       
//         .exception   (ID_exception  )  // output       
//     );

//     wire   [31:0] ID_regDout1;
//     wire   [31:0] ID_regDout2;
//     RegFile RegFile
//     (
//         .clk      (clk), // input        
//         .rst      (rst), // input        
//         .addr1    (ID_instr[25:21]), // input  [ 4:0]
//         .addr2    (ID_instr[20:16]), // input  [ 4:0]
//         .addr3    (XXXXX), // input  [ 4:0]
//         .din      (XXXXX), // input  [31:0]
//         .regWrite (XXXXX), // input        
//         .dout1    (ID_regDout1), // output [31:0]
//         .dout2    (ID_regDout2)  // output [31:0]
//     );

//     Branch Branch
//     (
//         .din1       (XXXXX), // input  [31:0]
//         .din2       (XXXXX), // input  [31:0]
//         .braEnable  (XXXXX), // input        
//         .braOp      (XXXXX), // input  [ 2:0]
//         .takeBranch (XXXXX)  // output       
//     );

//     Extend Extend
//     (
//         .din     (XXXXX), // input  [15:0]
//         .extSign (XXXXX), // input        
//         .dout    (XXXXX)  // output [31:0]
//     );

//     ID_EX ID_EX
//     (
//         .clk            (XXXXX), // input        
//         .rst            (XXXXX), // input        
//         .ID_pc4         (XXXXX), // input  [31:0]
//         .ID_instr       (XXXXX), // input  [31:0]
//         .ID_aluOp       (XXXXX), // input  [ 3:0]
//         .ID_aluDin1Src  (XXXXX), // input        
//         .ID_aluDin2Src  (XXXXX), // input        
//         .ID_mdOp        (XXXXX), // input  [ 1:0]
//         .ID_memWrite    (XXXXX), // input        
//         .ID_memRead     (XXXXX), // input        
//         .ID_memSize     (XXXXX), // input  [ 1:0]
//         .ID_memSign     (XXXXX), // input        
//         .ID_regWrite    (XXXXX), // input        
//         .ID_regAddr3Src (XXXXX), // input  [ 1:0]
//         .ID_regDinSrc   (XXXXX), // input  [ 2:0]
//         .ID_hlWrite     (XXXXX), // input  [ 1:0]
//         .ID_hlDinHiSrc  (XXXXX), // input        
//         .ID_hlDinLoSrc  (XXXXX), // input        
//         .ID_takeEret    (XXXXX), // input        
//         .EX_pc4         (XXXXX), // output [31:0]
//         .EX_instr       (XXXXX), // output [31:0]
//         .EX_aluOp       (XXXXX), // output [ 3:0]
//         .EX_aluDin1Src  (XXXXX), // output       
//         .EX_aluDin2Src  (XXXXX), // output       
//         .EX_mdOp        (XXXXX), // output [ 1:0]
//         .EX_memWrite    (XXXXX), // output       
//         .EX_memRead     (XXXXX), // output       
//         .EX_memSize     (XXXXX), // output [ 1:0]
//         .EX_memSign     (XXXXX), // output       
//         .EX_regWrite    (XXXXX), // output       
//         .EX_regAddr3Src (XXXXX), // output [ 1:0]
//         .EX_regDinSrc   (XXXXX), // output [ 2:0]
//         .EX_hlWrite     (XXXXX), // output [ 1:0]
//         .EX_hlDinHiSrc  (XXXXX), // output       
//         .EX_hlDinLoSrc  (XXXXX), // output       
//         .EX_takeEret    (XXXXX)  // output       
//     );

//     ALU ALU
//     (
//         .aluOp     (XXXXX), // input  [ 3:0]
//         .din1      (XXXXX), // input  [31:0]
//         .din2      (XXXXX), // input  [31:0]
//         .dout      (XXXXX), // output [31:0]
//         .exception (XXXXX)  // output       
//     );

//     MulDiv MulDiv
//     (
//         .mdOp   (XXXXX), // input  [ 3:0]
//         .din1   (XXXXX), // input  [31:0]
//         .din2   (XXXXX), // input  [31:0]
//         .doutHi (XXXXX), // output [31:0]
//         .doutLo (XXXXX)  // output [31:0]
//     );

//     EX_MEM EX_MEM
//     (
//         .clk             (XXXXX), // input        
//         .rst             (XXXXX), // input        
//         .EX_pc4          (XXXXX), // input  [31:0]
//         .EX_instr        (XXXXX), // input  [31:0]
//         .EX_memWrite     (XXXXX), // input        
//         .EX_memRead      (XXXXX), // input        
//         .EX_memSize      (XXXXX), // input  [ 1:0]
//         .EX_memSign      (XXXXX), // input        
//         .EX_regWrite     (XXXXX), // input        
//         .EX_regAddr3Src  (XXXXX), // input  [ 1:0]
//         .EX_regDinSrc    (XXXXX), // input  [ 2:0]
//         .EX_hlWrite      (XXXXX), // input  [ 1:0]
//         .EX_hlDinHiSrc   (XXXXX), // input        
//         .EX_hlDinLoSrc   (XXXXX), // input        
//         .EX_takeEret     (XXXXX), // input        
//         .MEM_pc4         (XXXXX), // output [31:0]
//         .MEM_instr       (XXXXX), // output [31:0]
//         .MEM_memWrite    (XXXXX), // output       
//         .MEM_memRead     (XXXXX), // output       
//         .MEM_memSize     (XXXXX), // output [ 1:0]
//         .MEM_memSign     (XXXXX), // output       
//         .MEM_regWrite    (XXXXX), // output       
//         .MEM_regAddr3Src (XXXXX), // output [ 1:0]
//         .MEM_regDinSrc   (XXXXX), // output [ 2:0]
//         .MEM_hlWrite     (XXXXX), // output [ 1:0]
//         .MEM_hlDinHiSrc  (XXXXX), // output       
//         .MEM_hlDinLoSrc  (XXXXX), // output       
//         .MEM_takeEret    (XXXXX)  // output       
//     );

//     DataMemory DataMemory
//     (
//         .clk       (XXXXX), // input        
//         .addr      (XXXXX), // input  [31:0]
//         .din       (XXXXX), // input  [31:0]
//         .memWrite  (XXXXX), // input        
//         .memRead   (XXXXX), // input        
//         .memSize   (XXXXX), // input  [ 1:0]
//         .memSign   (XXXXX), // input        
//         .dout      (XXXXX), // output [31:0]
//         .exception (XXXXX)  // output       
//     );

//     MEM_WB MEM_WB
//     (
//         .clk             (XXXXX), // input        
//         .rst             (XXXXX), // input        
//         .MEM_pc4         (XXXXX), // input  [31:0]
//         .MEM_instr       (XXXXX), // input  [31:0]
//         .MEM_regWrite    (XXXXX), // input        
//         .MEM_regAddr3Src (XXXXX), // input  [ 1:0]
//         .MEM_regDinSrc   (XXXXX), // input  [ 2:0]
//         .MEM_hlWrite     (XXXXX), // input  [ 1:0]
//         .MEM_hlDinHiSrc  (XXXXX), // input        
//         .MEM_hlDinLoSrc  (XXXXX), // input        
//         .MEM_takeEret    (XXXXX), // input        
//         .WB_pc4          (XXXXX), // output [31:0]
//         .WB_instr        (XXXXX), // output [31:0]
//         .WB_regWrite     (XXXXX), // output       
//         .WB_regAddr3Src  (XXXXX), // output [ 1:0]
//         .WB_regDinSrc    (XXXXX), // output [ 2:0]
//         .WB_hlWrite      (XXXXX), // output [ 1:0]
//         .WB_hlDinHiSrc   (XXXXX), // output       
//         .WB_hlDinLoSrc   (XXXXX), // output       
//         .WB_takeEret     (XXXXX)  // output       
//     );

//     HiLo HiLo
//     (
//         .clk     (XXXXX), // input        
//         .rst     (XXXXX), // input        
//         .dinHi   (XXXXX), // input  [31:0]
//         .dinLo   (XXXXX), // input  [31:0]
//         .hlWrite (XXXXX), // input  [ 1:0]
//         .doutHi  (XXXXX), // output [31:0]
//         .doutLo  (XXXXX)  // output [31:0]
//     );

// endmodule

