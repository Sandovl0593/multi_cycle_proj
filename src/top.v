module top (
    input wire clk,
    input wire reset,
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

    wire isRegWrite; // para el regfile
    wire [31:0] rdisplay; // para el display
    reg [15:0] displayData;      // display a value on visualizer

    arm arm(
        .clk(clk),
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
        .ALUOut(ALUOut),
        .rdisplay(rdisplay)         // display a value on visualizer (basys3
    );
    
    //reg [15:0] displayData = 16'hff;
    
    mem mem(
        .clk(clk),
        .we(MemWrite),
        .a(Adr),
        .wd(WriteData),
        .rd(ReadData)
    );
    
    assign isRegWrite = RegWrite && (Rd == 4'b0011); // R3

    always @(posedge clk or posedge reset) begin
        if (reset) displayData <= 16'd0; // reset display data
        else if (isRegWrite) displayData <= rdisplay[15:0]; // update display data
    end
    
    hex_display hex(
        .clk(clk),
        .reset(reset),
        .data(displayData), // display value
        .anode(anode),
        .catode(catode)
    );
endmodule
