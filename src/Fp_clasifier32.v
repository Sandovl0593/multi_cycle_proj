`timescale 1ns / 1ps

module Fp_clasifier32(
    input [31:0] inputfloat,   // Número en formato IEEE 754 de 32 bits
    output snan, qnan, inf, zero, subnormal, normal,
    output negative, overflow, carry
);  

    // Señales auxiliares
    wire expOne;       // Exponente = 11111111 (255) -> todos los bits del exponente en 1
    wire expZero;      // Exponente = 00000000 (0)   -> todos los bits del exponente en 0
    wire MantiZero;    // Mantisa = 000...000        -> todos los bits de la mantisa en 0

    // Detectores de exponente y mantisa
    assign expOne    = &inputfloat[30:23];    // Exponente todo en 1
    assign expZero   = ~|inputfloat[30:23];   // Exponente todo en 0
    assign MantiZero = ~|inputfloat[22:0];    // Mantisa todo en 0

    // Clasificaciones
    assign snan      = expOne & ~MantiZero & ~inputfloat[22]; // Signaling NaN (MSB mantisa = 0)
    assign qnan      = expOne & inputfloat[22];                // Quiet NaN (MSB mantisa = 1)
    assign inf       = expOne & MantiZero;                     // Infinito
    assign zero      = expZero & MantiZero;                    // Cero
    assign subnormal = expZero & ~MantiZero;                   // Subnormal (exp = 0, mantisa ≠ 0)
    assign normal    = ~expOne & ~expZero;                     // Número normal (exp entre 1 y 254)

endmodule