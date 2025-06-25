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
    output wire opMul               //para Multiply
);

    wire [3:0] ALUFlags;
    wire PCWrite;
    wire RegWrite;
    wire IRWrite;
    wire AdrSrc;
    wire [1:0] RegSrc;
    wire ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [1:0] ImmSrc;
    wire [2:0] ALUControl;
    wire [1:0] ResultSrc;

    controller c(
        .clk(clk),
        .reset(reset),
        // instruction signals inputs -/-> [ decode ]
        .Instr(Instr[31:0]),
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
        .opMul(opMul)
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
        .opMul(opMul),
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
        .Result(Result)
    );
endmodule
