module top (
    input wire clk;
    input wire reset;
    // Outputs de visualización en Testbench
    output wire [31:0] WriteData;
    output wire [31:0] Adr;
    output wire MemWrite;
    output wire [31:0] PC;
    output wire [31:0] Instr;
    output wire [31:0] ReadData;
);

    arm arm(
        .clk(clk),
        .reset(reset),
        .MemWrite(MemWrite),
        .Adr(Adr),
        .WriteData(WriteData),
        .ReadData(ReadData)
    );
    mem mem(
        .clk(clk),
        .we(MemWrite),
        .a(Adr),
        .wd(WriteData),
        .rd(ReadData)
    );
endmodule
