module controller (
    input wire clk,
    input wire reset,
    // instruction signals -/-> [ decode ]
    input wire [31:12] Instr,
    input wire [3:0] ALUFlags,

    // instruction signals -/-> [ datapath ]
    output wire PCWrite,
    output wire MemWrite,
    output wire RegWrite,

    // control signals -/-> [ datapath ]
    output wire IRWrite,
    output wire AdrSrc,
    output wire [1:0] RegSrc,
    output wire [1:0] ALUSrcA,
    output wire [1:0] ALUSrcB,
    output wire [1:0] ResultSrc,
    output wire [1:0] ImmSrc,
    output wire [1:0] ALUControl
);
    wire [1:0] FlagW;
    wire PCS;
    wire NextPC;
    wire RegW;
    wire MemW;

    decode dec(
        .clk(clk),
        .reset(reset),
        .Op(Instr[27:26]),
        .Funct(Instr[25:20]),
        .Rd(Instr[15:12]),
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
        .RegSrc(RegSrc)
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
        // Outputs to [ datapath ]
        .PCWrite(PCWrite),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite)
    );
endmodule
