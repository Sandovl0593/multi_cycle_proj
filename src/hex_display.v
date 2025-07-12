module hex_display(
    input clk, 
    input reset, 
    input wire stop, // para detener el reloj
    output wire [3:0] anode,
    output wire [7:0] catode
);
    wire scl_clk;
    wire [3:0] digit;

    wire [31:0] Result;
    wire [31:0] WriteData;
    wire [31:0] Adr;
    wire MemWrite;
    wire [31:0] PC;
    wire [31:0] Instr;
    wire [31:0] ReadData;
    wire [3:0] state;
    wire opMul;             //para multiply
    wire IsLongMul;         //new para Umul y Smul
    wire [31:0] SrcA;        // para ver SrcA
    wire [31:0] SrcB;        // para ver SrcB
    wire [3:0] Rn;           // Para ver Rn
    wire [3:0] Rm;           // Para ver Rm (DP) o Rd (Mem Inmediate)
    wire [3:0] Rd;           // Para ver escritura
    wire [3:0] Ra;           // Para ver Ra en el caso de SMULL; UMULL
    wire [31:0] ALUResult;    // resultado 31:0 (64:32 si es UMULL/SMULL)
    wire [31:0] ALUResult2;    // visualizar resultado mul 31:0 si es UMULL/SMULL
    wire [3:0] ALUFlags;
    wire RegWrite;
    wire [3:0] ALUControl;      //se expandió a 4 bits
    wire [31:0] ALUOut;

    top top(
        .clk(scl_clk),
        .reset(reset),
        .Result(Result),
        .WriteData(WriteData),
        .Adr(Adr),
        .MemWrite(MemWrite),
        .PC(PC),
        .Instr(Instr),
        .ReadData(ReadData),
        .state(state),
        .opMul(opMul),
        .IsLongMul(IsLongMul),
        .SrcA(SrcA),
        .SrcB(SrcB),
        .Rn(Rn),
        .Rm(Rm),
        .Rd(Rd),
        .Ra(Ra),
        .ALUResult(ALUResult),
        .ALUResult2(ALUResult2),
        .ALUFlags(ALUFlags),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl),
        .ALUOut(ALUOut)
    );
    CLKdivider sc(
        .in_clk(clk),
        .reset_clk(reset),
        .stop(stop),
        .out_clk(scl_clk)
    );
    
    hFSM m(
        .clk(scl_clk),
        .state(state),
        .reset(reset),
        .data(ALUOut[15:0]), // libera resultado
        .digit(digit),
        .anode(anode)
    );
    HexTo7Segment decoder (
        .digit(digit),
        .catode(catode)
    );
endmodule