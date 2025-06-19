module datapath (
    input wire clk;
    input wire reset;

    output wire [31:0] Adr,        // -> a [ mem ]
    output wire [31:0] WriteData,  // -> wd [ mem ]
    input wire [31:0] ReadData,    // [ mem ] rd ->
    
    // -/-> [ controller ]
    output wire [31:0] Instr,
    output wire [3:0] ALUFlags,

    // [ controller ] (instr & control signals) -/->
    input wire PCWrite,
    input wire RegWrite,
    input wire IRWrite,
    input wire AdrSrc,
    input wire [1:0] RegSrc,
    input wire [1:0] ALUSrcA,
    input wire [1:0] ALUSrcB,
    input wire [1:0] ResultSrc,
    input wire [1:0] ImmSrc,
    input wire [1:0] ALUControl
);
    wire [31:0] PCNext;
    wire [31:0] PC;
    wire [31:0] ExtImm;
    wire [31:0] SrcA;
    wire [31:0] SrcB;
    wire [31:0] Result;
    wire [31:0] Data;
    wire [31:0] RD1;
    wire [31:0] RD2;
    wire [31:0] A;
    wire [31:0] ALUResult;
    wire [31:0] ALUOut;
    wire [3:0] RA1;
    wire [3:0] RA2;

    // Your datapath hardware goes below. Instantiate each of the 
    // submodules that you need. Remember that you can reuse hardware
    // from previous labs. Be sure to give your instantiated modules 
    // applicable names such as pcreg (PC register), adrmux 
    // (Address Mux), etc. so that your code is easier to understand.

    // FETCH ---------------------------------

    // PC' -> [ reg ] -> PC
    flopenr #(32) flopPCnext(
        .clk(clk),
        .reset(reset),
        .en(PCWrite),
        .d(PCNext),
        .q(PC)
    );
    
    assign PCNext = Result;
    
    // AdrSrc -> (0: PC)(1: Result) -> Adr
    mux2 #(32) adrMux(
        .d0(PC),
        .d1(ALUOut),
        .s(AdrSrc),
        .y(Adr)
    );

    // DECODE ---------------------------------
    // IRWrite -> [ reg ] -> Instr
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
        .d0(Instr[19:16]),
        .d1(4'b1111), // R15
        .s(RegSrc[0]), 
        .y(RA1)
    );

    // RegSrc_2 -> (0: Rm)(1: Rn) -> RA2
    mux2 #(4) ra2Mux(
        .d0(Instr[3:0]), 
        .d1(Instr[15:12]), 
        .s(RegSrc[1]), 
        .y(RA2)
    );

    // RA1, RA2 -> [ regfile ] -> RD1, RD2
    regfile rf(
        .clk(clk),
        .we3(RegWrite),
        .ra1(RA1),
        .ra2(RA2),
        .wa3(Instr[15:12]),
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
    
    // ALUSrcA -> (0: A)(1: PC)(2: ALUOut) -> SrcA
    mux3 #(32) srcAMux(
        .d0(A),
        .d1(PC),
        .d2(ALUOut),
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
        .ALUFlags(ALUFlags)
    );
    
    // WRITEBACK / MEMORY ---------------------------------
    // ALUResult -> [ reg ] -> ALUOut
    flopr #(32) aluoutreg(
        .clk(clk),
        .reset(reset),
        .d(ALUResult),
        .q(ALUOut)
    );

    // ResultSrc -> (0: ALUOut)(1: Data)(2: ALUResult) -> Result
    mux3 #(32) resmux(
        .d0(ALUOut), 
        .d1(Data), 
        .d2(ALUResult), 
        .s(ResultSrc), 
        .y(Result)
    ); 

endmodule
