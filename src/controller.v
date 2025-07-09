module controller (
    input wire clk,
    input wire reset,
    // instruction signals -/-> [ decode ]
    input wire [31:0] Instr,
    input wire [3:0] Rd,
    input wire [3:0] ALUFlags,

    // instruction signals -/-> [ datapath ]
    output wire PCWrite,
    output wire MemWrite,
    output wire RegWrite,

    // control signals -/-> [ datapath ]
    output wire IRWrite,
    output wire AdrSrc,
    output wire [1:0] RegSrc,
    output wire ALUSrcA,
    output wire [1:0] ALUSrcB,
    output wire [1:0] ResultSrc,
    output wire [1:0] ImmSrc,
    output wire [2:0] ALUControl,
    output wire [3:0] state,         // para ver los estados
    output wire opMul, //para MUL
    output wire IsLongMul//para tipo UMULL y SMULL
                  
);
    wire [1:0] FlagW;
    wire PCS;
    wire NextPC;
    wire RegW;
    wire MemW;
    wire noWrite; // caso de CMP

    decode dec(
        .clk(clk),
        .reset(reset),
        .Op(Instr[27:26]),
        .Funct(Instr[25:20]),
        .Rd(Rd),
        .IsMul(Instr[7:4]), // esto determina si es Multiply (1001)
        .PCS(PCS),
        
        // FSM signals 
        .NextPC(NextPC),
        .RegW(RegW),
        .MemW(MemW),
        .IRWrite(IRWrite),
        .AdrSrc(AdrSrc),
        .ResultSrc(ResultSrc),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),

        // ALU Decoder signals
        .FlagW(FlagW),
        .ALUControl(ALUControl),
        // Op Decoder signals
        .ImmSrc(ImmSrc),
        .RegSrc(RegSrc),

        .state(state),
        .noWrite(noWrite), // caso de CMP
        .opMul(opMul),//para Multiply
        .IsLongMul(IsLongMul) //new output
    );
    condlogic cl(
        .clk(clk),
        .reset(reset),
        .Cond(Instr[31:28]),
        .ALUFlags(ALUFlags),
        // Inputs from [ decode ] -/->
        .FlagW(FlagW),
        .PCS(PCS),
        .NextPC(NextPC),
        .RegW(RegW),
        .MemW(MemW),
        .noWrite(noWrite), // caso de CMP
        // Outputs to [ datapath ]
        .PCWrite(PCWrite),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite)
    );
endmodule