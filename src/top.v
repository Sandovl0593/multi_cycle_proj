module top (
    input wire clk,
    input wire reset,
    // Outputs de visualización en Testbench
    output wire [31:0] WriteData,
    output wire [31:0] Adr,
    output wire MemWrite,
    output wire [31:0] PC,
    output wire [31:0] Instr,
    output wire [31:0] ReadData,
    output wire [3:0] state,
    output wire opMul //para multiply
);

    arm arm(
        .clk(clk),
        .reset(reset),
        .MemWrite(MemWrite),
        .Adr(Adr),
        .WriteData(WriteData),
        .ReadData(ReadData),
        .PC(PC),
        .Instr(Instr),
        .state(state),
        .opMul(opMul) //para multiply
    );
    mem mem(
        .clk(clk),
        .we(MemWrite),
        .a(Adr),
        .wd(WriteData),
        .rd(ReadData)
    );
endmodule
