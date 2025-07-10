`timescale 1ns / 1ps


module Fp_clasifier16 (
    input [15:0] float,  // Número en punto flotante de 16 bits
    output snan, qnan, inf, zero, subnormal, normal,
    output negative, overflow, carry
);

    wire expOnes, expZeroes, sigZeroes;

    assign expOnes    = &float[14:10];       // Exponente todo en 1 -> 11111
    assign expZeroes  = ~|float[14:10];      // Exponente todo en 0 -> 00000
    assign sigZeroes  = ~|float[9:0];        // Mantisa todo en 0

    assign snan       = expOnes & ~sigZeroes & ~float[9]; // signaling NaN (MSB mantisa = 0)
    assign qnan       = expOnes & float[9];               // quiet NaN (MSB mantisa = 1)
    assign inf        = expOnes & sigZeroes;              // infinito (exponente 11111, mantisa 0)
    assign zero       = expZeroes & sigZeroes;            // cero (exp = 0, mantisa = 0)
    assign subnormal  = expZeroes & ~sigZeroes;           // subnormal (exp = 0, mantisa ≠ 0)
    assign normal     = ~expOnes & ~expZeroes;            // número normal (exp entre 1 y 30)

endmodule