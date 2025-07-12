`timescale 1ns / 1ps

module testbench;
    reg clk;
    reg reset;
    wire [31:0] PC;
    wire [31:0] Instr;
    wire [31:0] Adr;
    wire [3:0] ALUFlags;
    wire [3:0] ALUControl;   // Se expandió a 4 bits
    wire opMul;
    wire IsLongMul;
    wire [3:0] Rn;           // Para ver Rn
    wire [31:0] SrcA;        // para ver SrcA
    wire [3:0] Rm;           // Para ver Rm (DP) o Rd (Mem Inmediate)
    wire [31:0] SrcB;        // para ver SrcB
    wire [3:0] Rd;           // Para ver escritura
    wire [3:0] Ra;           // Para ver Ra en el caso de SMULL, UMULL
    wire [31:0] ALUResult;   // Para ver el resultado de la ALU
    wire [31:0] ALUResult2;    // visualizar resultado mul 64:32
    wire [31:0] ALUOut;
    wire [31:0] Result;
    wire [3:0] state;

    wire MemWrite;
    wire RegWrite;
    wire [31:0] WriteData;
    wire [31:0] ReadData;

    top dut(
        .clk(clk),
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
        .IsLongMul(IsLongMul),         //new smull y umull
        // nuevos visualizadores
        .SrcA(SrcA),        // para ver SrcA
        .SrcB(SrcB),        // para ver SrcB
        .Rn(Rn),           // Para ver Rn
        .Rm(Rm),           // Para ver Rm (DP) o Rd (Mem Inmediate)
        .Rd(Rd),           // Para ver escritura
        .Ra(Ra),                  // Para ver Ra en el SMULL y UMULL
        .ALUResult(ALUResult), // Para ver el resultado de la ALU
        .ALUResult2(ALUResult2),    // visualizar resultado mul 64:32
        .ALUFlags(ALUFlags),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl),
        .ALUOut(ALUOut)
    );

    initial begin
        reset <= 1; #(10) ;
        reset <= 0;
    end
    always begin
        clk <= 1; #(2) ;
        clk <= 0; #(2) ;
    end
            
    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars;
    end
endmodule