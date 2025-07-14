module arm (
    input wire clk,
    input wire reset,

    output wire [31:0] Result,             //para poder visualizar el resultado
    output wire MemWrite,           // -> we [ mem ]
    output wire [31:0] Adr,         // -> a [ mem ]
    output wire [31:0] WriteData,   // -> wd [ mem ]

    input wire [31:0] ReadData,      // [ mem ] rd ->
    output wire [31:0] PC,           // para visualizacion
    output wire [31:0] Instr,         // para visualizacion

    output wire [3:0] state,        // para ver los estados
    output wire opMul,               //para Multiply
    output wire IsLongMul,         //new para Umul y Smul
    // nuevos visualizadores
    output wire [31:0] SrcA,        // para ver SrcA
    output wire [31:0] SrcB,        // para ver SrcB
    // utiles para el multiply:
    output wire [3:0] Rn,           // Para ver Rn
    output wire [3:0] Rm,           // Para ver Rm (DP) o Rd (Mem Inmediate)
    output wire [3:0] Rd,           // Para ver escritura
    output wire [3:0] Ra,           // Para ver Ra en el caso de SMULL, UMULL
    output wire [31:0] ALUResult,     // Para ver el resultado de la ALU
    output wire [31:0] ALUResult2,         // visualizar resultado mul 64:32
    output wire [3:0] ALUFlags,
    output wire RegWrite,
    output wire [3:0] ALUControl,
    output wire [31:0] ALUOut,
    output wire [31:0] rdisplay
);

    wire PCWrite;
    wire IRWrite;
    wire AdrSrc;
    wire [1:0] RegSrc;
    wire ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [1:0] ImmSrc;
    wire [1:0] ResultSrc;   

    controller c(
        .clk(clk),
        .reset(reset),
        // instruction signals inputs -/-> [ decode ]
        .Instr(Instr[31:0]),
        .Rd(Rd),                // entra Rd
        .ALUFlags(ALUFlags),
        
        // instruction signals outputs -/-> [ datapath ]
        .PCWrite(PCWrite),
        .MemWrite(MemWrite),
        .RegWrite(RegWrite),
        // control signals outputs -/-> [ datapath ]
        .IRWrite(IRWrite),
        .AdrSrc(AdrSrc),
        .RegSrc(RegSrc),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .ResultSrc(ResultSrc),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl),
        .state(state),                  // para ver los estados
        .opMul(opMul),
        .IsLongMul(IsLongMul)          //new smull y umull
    );
    
    datapath dp(
        .clk(clk),
        .reset(reset),
        .Adr(Adr),                      // -> a [ mem ]
        .WriteData(WriteData),          // -> wd [ mem ]
        .ReadData(ReadData),            // [ mem ] rd ->
        
        // outputs -/-> [ controller ]
        .Instr(Instr),
        .ALUFlags(ALUFlags),
        
        // [ controller ] (instr & control signals inputs) -/->
        .opMul(opMul),       // new output
        .IsLongMul(IsLongMul), //new output
        
        .PCWrite(PCWrite),
        .RegWrite(RegWrite),
        .IRWrite(IRWrite),
        .AdrSrc(AdrSrc),
        .RegSrc(RegSrc),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .ResultSrc(ResultSrc),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl),
        
        .PC(PC),                   // para visualizacion
        .Result(Result),

        // nuevos visualizadores
        .SrcA(SrcA),
        .SrcB(SrcB),
        // utiles para el multiply:
        .Rn(Rn),                  // Para ver Rn
        .Rm(Rm),                  // Para ver Rm (DP) o Rd (Mem Inmediate)
        .Rd(Rd),                  // Sale Rd para ver escritura
        .Ra(Ra),                  // Para ver Ra en el SMULL y UMULL
        .ALUResult(ALUResult),     // Para ver el resultado de la ALU
        .ALUResult2(ALUResult2),    // visualizar resultado mul 64:32
        .ALUOut(ALUOut)
    );
    
    // harcoded 
    assign rdisplay = dp.rf.rf[4'd0];  // GET R0x
endmodule