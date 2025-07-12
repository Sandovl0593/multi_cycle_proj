module top (
    input wire clk,
    input wire reset,
    // Outputs de visualización en Testbench
    /*output wire [31:0] Result,
    output wire [31:0] WriteData,
    output wire [31:0] Adr,
    output wire MemWrite,
    output wire [31:0] PC,
    output wire [31:0] Instr,
    output wire [31:0] ReadData,
    output wire opMul, //para multiply
    output wire IsLongMul,         //new para Umul y Smul

    // nuevos visualizadores
    output wire [31:0] SrcA,        // para ver SrcA
    output wire [31:0] SrcB,        // para ver SrcB
    // utiles para el multiply:
    output wire [3:0] Rn,           // Para ver Rn
    output wire [3:0] Rm,           // Para ver Rm (DP) o Rd (Mem Inmediate)
    output wire [3:0] Rd,           // Para ver escritura
    output wire [3:0] Ra,           // Para ver Ra en el caso de SMULL, UMULL
    output wire [31:0] ALUResult,    // Para ver el resultado de la ALU
    output wire [31:0] ALUResult2,    // visualizar resultado mul 64:32
    output wire [3:0] state,
    output wire [3:0] ALUFlags,
    output wire RegWrite,
    output wire [3:0] ALUControl,      //se expandió a 4 bits
    output wire [31:0] ALUOut,*/

    output wire [3:0] anode,
    output wire [7:0] catode
);
    
    wire [31:0] Result;
    wire [31:0] WriteData;
    wire [31:0] Adr;
    wire MemWrite;
    wire [31:0] PC;
    wire [31:0] Instr;
    wire [31:0] ReadData;
    wire opMul; //para multiply
    wire IsLongMul;         //new para Umul y Smul

    // nuevos visualizadores
    wire [31:0] SrcA;        // para ver SrcA
    wire [31:0] SrcB;        // para ver SrcB
    // utiles para el multiply:
    wire [3:0] Rn;           // Para ver Rn
    wire [3:0] Rm;           // Para ver Rm (DP) o Rd (Mem Inmediate)
    wire [3:0] Rd;           // Para ver escritura
    wire [3:0] Ra;           // Para ver Ra en el caso de SMULL; UMULL
    wire [31:0] ALUResult;    // Para ver el resultado de la ALU
    wire [31:0] ALUResult2;    // visualizar resultado mul 64:32
    wire [3:0] state;
    wire [3:0] ALUFlags;
    wire RegWrite;
    wire [3:0] ALUControl;      //se expandió a 4 bits
    wire [31:0] ALUOut;
    
    wire scl_clk;
    arm arm(
        .clk(scl_clk),
        .reset(reset),
        .Result(Result),
        .MemWrite(MemWrite),
        .Adr(Adr),
        .WriteData(WriteData),
        .ReadData(ReadData),
        .PC(PC),
        .Instr(Instr),
        .state(state),
        .opMul(opMul), //para multiply
        .IsLongMul(IsLongMul),         //new smull y umull

        // nuevos visualizadores
        .SrcA(SrcA),        // para ver SrcA
        .SrcB(SrcB),        // para ver SrcB
        // utiles para el multiply:
        .Rn(Rn),           // Para ver Rn
        .Rm(Rm),           // Para ver Rm (DP) o Rd (Mem Inmediate)
        .Rd(Rd),           // Para ver escritura
        .Ra(Ra),                  // Para ver Ra en el SMULL y UMULL
        .ALUResult(ALUResult),    // Para ver el resultado de la ALU
        .ALUResult2(ALUResult2),   // visualizar resultado mul 64:32
        .ALUFlags(ALUFlags),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl),
        .ALUOut(ALUOut)
    );
    CLKdivider sc(
        .in_clk(clk),
        .reset_clk(reset),
        .out_clk(scl_clk)
    );
    hex_display test(
        .clk(scl_clk), 
        .reset(reset), 
        //.PC(PC),
        //.Instr(Instr),
        .state(state),
        .data(ALUResult[15:0]),
        .anode(anode),
        .catode(catode)
        //.ALUResult(ALUResult),
        //.state(state)
    );
    mem mem(
        .clk(scl_clk),
        .we(MemWrite),
        .a(Adr),
        .wd(WriteData),
        .rd(ReadData)
    );
endmodule
