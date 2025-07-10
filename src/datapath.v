module datapath (
    input wire clk,
    input wire reset,

    output wire [31:0] Adr,        // -> a [ mem ]
    output wire [31:0] WriteData,  // -> wd [ mem ]
    input wire [31:0] ReadData,    // [ mem ] rd ->
    
    // -/-> [ controller ]
    output wire [31:0] Instr,
    output wire [3:0] ALUFlags,
    
    // [ controller ] (instr & control signals) -/->
    input wire opMul, //esto es para multiply
    input wire IsLongMul,      //esto es para smull y umull
    input wire PCWrite,
    input wire RegWrite,
    input wire IRWrite,
    input wire AdrSrc,
    input wire [1:0] RegSrc,
    input wire ALUSrcA,
    input wire [1:0] ALUSrcB,
    input wire [1:0] ResultSrc,
    input wire [1:0] ImmSrc,
    input wire [3:0] ALUControl,
    output wire [31:0] PC,               // para visualizacion
    output wire [31:0] Result,

    // nuevos visualizadores
    output wire [31:0] SrcA,
    output wire [31:0] SrcB,
    //utiles para el multiply:
    output wire [3:0] Rn,                 // Para ver Rn
    output wire [3:0] Rm,                 // Para ver Rm (DP) o Rd (Mem Inmediate)
    output wire [3:0] Rd,                 // Para ver escritura
    output wire [3:0] Ra,                 // Para ver Ra en el caso de SMULL, UMULL
    output wire [31:0] ALUResult,         // resultado 31:0
    output wire [31:0] ALUResult2,         // visualizar resultado mul 64:32
    output wire [31:0] ALUOut
);
    wire [31:0] PCNext;
    wire [31:0] ExtImm;
    wire [31:0] Data;
    wire [31:0] RD1;
    wire [31:0] RD2;
    wire [31:0] A;
    wire [3:0] RA1;
    wire [3:0] RA2;

    // Your datapath hardware goes below. Instantiate each of the 
    // submodules that you need. Remember that you can reuse hardware
    // from previous labs. Be sure to give your instantiated modules 
    // applicable names such as pcreg (PC register), adrmux 
    // (Address Mux), etc. so that your code is easier to understand.

    // FETCH ---------------------------------
    assign PCNext = Result;

    // PC' -> [ reg ] -> PC
    flopenr #(32) flopPCnext(
        .clk(clk),
        .reset(reset),
        .en(PCWrite),
        .d(PCNext),
        .q(PC)
    );
    
    // AdrSrc -> (0: PC)(1: Result) -> Adr
    mux2 #(32) adrMux(
        .d0(PC),
        .d1(Result),
        .s(AdrSrc),
        .y(Adr)
    );
    
    //modulito para Multiply
    MulRegChecker modulito(
        .Instr(Instr[31:0]),
        .opMul(opMul),
        .Rn(Rn),
        .Rm(Rm),
        .Ra(Ra),
        .Rd(Rd)
    );

    // DECODE ---------------------------------    
    // ReadData -> [ reg ] -> Instr
    flopenr #(32) flopIR(
        .clk(clk),
        .reset(reset),
        .en(IRWrite),
        .d(ReadData),
        .q(Instr)
    );

    // ReadData -> [ reg ] -> Data
    flopr #(32) flopData(
        .clk(clk),
        .reset(reset),
        .d(ReadData),
        .q(Data)
    );

     // RegSrc_1 -> (0: Rn)(1: R15) -> RA1
    mux2 #(4) ra1Mux(
        .d0(Rn),
        .d1(4'b1111), // R15
        .s(RegSrc[0]), 
        .y(RA1)
    );

    // RegSrc_2 -> (0: Rm)(1: Rn) -> RA2
    mux2 #(4) ra2Mux(
        .d0(Rm),
        .d1(Rd), 
        .s(RegSrc[1]), 
        .y(RA2)
    );

    // RA1, RA2 -> [ regfile ] -> RD1, RD2
    regfile rf(
        .clk(clk),
        .we3(RegWrite),
        .we4(IsLongMul), //condicion para el SMULL, UMULL y escribir en el Ra
        .ra1(RA1),
        .ra2(RA2),
        .wa3(Rd),
        .wa4(Ra),       //registro agregado para el SMULL, UMULL
        .wd3(Result),
        .r15(Result),
        .rd1(RD1),
        .rd2(RD2)
    );

    // Extend Immediate
    extend ext(
        .Instr(Instr[23:0]), 
        .ImmSrc(ImmSrc), 
        .ExtImm(ExtImm)
    );

    // EXECUTE ---------------------------------
    // RD1 -> [ reg ] -> A
    flopr #(32) srcAReg(
        .clk(clk),
        .reset(reset),
        .d(RD1),
        .q(A)
    );

    // RD2 -> [ reg ] -> WriteData
    flopr #(32) srcBWriteDataReg(
        .clk(clk), 
        .reset(reset), 
        .d(RD2), 
        .q(WriteData)
    );
    
    // ALUSrcA -> (0: A)(1: PC) -> SrcA
    mux2 #(32) srcAMux(
        .d0(A),
        .d1(PC),
        .s(ALUSrcA),
        .y(SrcA)
    );

    // ALUSrcB -> (0: WriteData)(1: ExtImm)(2: 4) -> SrcB
    mux3 #(32) srcBMux(
        .d0(WriteData), 
        .d1(ExtImm), 
        .d2(32'd4), 
        .s(ALUSrcB), 
        .y(SrcB)
    );

    // ALU Logic
    alu alu(
        .a(SrcA), 
        .b(SrcB), 
        .ALUControl(ALUControl), 
        .Result(ALUResult), 
        .Result2(ALUResult2),
        .ALUFlags(ALUFlags)
    );
    
        // WRITEBACK / MEMORY ---------------------------------
    // ALUResult -> [ reg ] -> ALUOut
    floplongr aluoutreg(
        .clk(clk),
        .reset(reset),
        .d(ALUResult),
        .d2(ALUResult2),
        .mulEn(IsLongMul),
        .q(ALUOut)
    );
    
    
    // WRITEBACK / MEMORY ---------------------------------
    // ALUResult -> [ reg ] -> ALUOut
    /*
    flopr #(32) aluoutreg(
        .clk(clk),
        .reset(reset),
        .d(ALUResult),
        .q(ALUOut)
    );*/

    // ResultSrc -> (0: ALUOut)(1: Data)(2: ALUResult) -> Result
    mux3 #(32) resmux(
        .d0(ALUOut),    // ALUOut from ALU (DP)
        .d1(Data),      // Data from memory (LDR)
        .d2(ALUResult), // ALUResult from ALU (Branch or STR)
        .s(ResultSrc), 
        .y(Result)
    ); 

endmodule
