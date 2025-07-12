`timescale 1ns / 1ps

module FloatingPointAdd16(
    input wire [15:0] a,
    input wire [15:0] b,
    output reg [31:0] add16,     // Resultado final ahora de 32 bits (zero-extended)
    output wire [3:0] flags
    );

    reg negative, zero, carry, overflow; // los flags respectivos

    reg sign_a, sign_b;              // bit 15
    reg [4:0] expA, expB;            // 5 bits para exponente -> bits 14:10
    reg [10:0] mantissaA, mantissaB; // 1 bit implícito + 10 bits de la mantissa -> bits 9:0

    reg signResul;                   // signo resultante
    reg [5:0] expResul;              // 6 bits para detectar overflow
    reg [11:0] mantissaResul;        // 1 bit extra para carry

    integer i;
    always @(*) begin
        // Inicializamos flags
        zero = 0;
        negative = 0;
        carry = 0;
        overflow = 0;
        expResul[5] = 1'b0;

        // Extraemos campos de entrada
        sign_a = a[15];
        sign_b = b[15];
        expA = a[14:10];
        expB = b[14:10];
        mantissaA = {1'b1, a[9:0]};
        mantissaB = {1'b1, b[9:0]};

        if (expA > expB) begin
            expResul[4:0] = expA;
            signResul = sign_a;
            if (sign_a == sign_b)
                mantissaResul = mantissaA + (mantissaB >> (expA - expB));
            else
                mantissaResul = mantissaA - (mantissaB >> (expA - expB));

            if (expA >= 5'b11110 && mantissaResul[9:0] == 10'b1111111111)
                overflow = 1;
        end else if (expA < expB) begin
            expResul[4:0] = expB;
            signResul = sign_b;
            if (sign_a == sign_b)
                mantissaResul = mantissaB + (mantissaA >> (expB - expA));
            else
                mantissaResul = mantissaB - (mantissaA >> (expB - expA));

            if (expB >= 5'b11110 && mantissaResul[9:0] == 10'b1111111111)
                overflow = 1;
        end else begin
            expResul[4:0] = expA;
            if (sign_a == sign_b) begin
                mantissaResul = mantissaA + mantissaB;
                signResul = sign_a;
            end else begin
                if (mantissaA > mantissaB) begin
                    mantissaResul = mantissaA - mantissaB;
                    signResul = sign_a;
                end else begin
                    mantissaResul = mantissaB - mantissaA;
                    signResul = sign_b;
                end
            end
        end

        // Verificar carry
        carry = mantissaResul[11];

        // Normalización
        if (sign_a == sign_b) begin
            if (mantissaResul[11] == 1) begin
                expResul = expResul + 1;
                add16 = {16'b0, signResul, expResul[4:0], mantissaResul[10:1]};
            end else begin
                add16 = {16'b0, signResul, expResul[4:0], mantissaResul[9:0]};
            end
        end else begin
            for (i = 0; i < 11; i = i + 1) begin
                if (mantissaResul[10] == 0 && expResul != 0) begin
                    mantissaResul = mantissaResul << 1;
                    expResul = expResul - 1;
                end
            end
            add16 = {16'b0, signResul, expResul[4:0], mantissaResul[9:0]};
        end

        // Verificamos resultado cero
        if (add16[14:0] == 15'b0) begin
            add16[15] = 1'b0;
            zero = 1;
            carry = 0;
            overflow = 0;
            negative = 0;
        end

        if (add16[15] == 1) negative = 1;
        if (expResul[4:0] == 5'b11111) overflow = 1;
    end

    assign flags = {negative, zero, carry, overflow};

endmodule
