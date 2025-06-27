module testbench;
    reg clk;
    reg reset;
    wire [31:0] PC;
    wire [31:0] Instr;
    wire [31:0] Adr;
    wire [3:0] ALUFlags;
    wire [2:0] ALUControl;
    wire opMul;
    wire [3:0] Rn;           // Para ver Rn
    wire [31:0] SrcA;        // para ver SrcA
    wire [3:0] Rm;           // Para ver Rm (DP) o Rd (Mem Inmediate)
    wire [31:0] SrcB;        // para ver SrcB
    wire [3:0] Rd;           // Para ver escritura
    wire [31:0] ALUResult;   // Para ver el resultado de la ALU
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
        // nuevos visualizadores
        .SrcA(SrcA),        // para ver SrcA
        .SrcB(SrcB),        // para ver SrcB
        .Rn(Rn),           // Para ver Rn
        .Rm(Rm),           // Para ver Rm (DP) o Rd (Mem Inmediate)
        .Rd(Rd),           // Para ver escritura
        .ALUResult(ALUResult), // Para ver el resultado de la ALU
        .ALUFlags(ALUFlags),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl)
    );

    initial begin
        reset <= 1; #(22) ;
        reset <= 0;
    end
    always begin
        clk <= 1; #(5) ;
        clk <= 0; #(5) ;
    end
    // always @(negedge clk)
    //     if (MemWrite)
    //         if ((Adr === 100) & (WriteData === 7)) begin
    //             $display("Simulation succeeded");
    //             $stop;
    //         end
    //         else if (Adr !== 96) begin
    //             $display("Simulation failed");
    //             $stop;
    //         end
            
    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars;
    end
endmodule