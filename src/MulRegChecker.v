`timescale 1ns / 1ps

module MulRegChecker(
    input wire [31:0] Instruccion,
    input wire opMul,
    output reg [3:0] Rn,
    output reg [3:0] Rm,
    output reg [3:0] Ra,//para el mul esto es 0000   
    output reg [3:0] Rd
);
    
    always @(*)
        if (opMul) begin
            Rn = Instruccion[3:0];
            Rm = Instruccion[11:8];
            Ra = Instruccion[15:12];//MUL cable suelto
            Rd = Instruccion[19:16];
        end else begin
            Rn = Instruccion[19:16];
            Rm = Instruccion[3:0];
            Ra = 4'b0000;//cable suelto
            Rd = Instruccion[15:12];
            
        end   
    
endmodule
