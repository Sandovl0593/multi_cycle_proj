`timescale 1ns / 1ps

module FloatingPointMul32(
    input [31:0] a,
    input [31:0] b,
    output wire [31:0] mul32,
    output wire [3:0] flags // [overflow, zero, carry (no usado), negative]
);

    // Salidas del clasificador para a y b
    wire Asnan, Aqnan, Ainf, Azero, Asubnormal, Anormal, Anegative, Aoverflow, Acarry;
    wire Bsnan, Bqnan, Binf, Bzero, Bsubnormal, Bnormal, Bnegative, Boverflow, Bcarry;

    reg [31:0] productoTemp;
    reg [47:0] partialResult;
    reg [7:0] expa;
    reg [7:0] expb;
    reg [8:0] exponent;
    reg Signo;
    reg [3:0] flags_reg; // [overflow, zero, carry (sin usar), negative]

    // Constante bias para punto flotante IEEE 754
    parameter bias = 127;

    // Instancias del clasificador
    Fp_clasifier32 A (
        .inputfloat(a),
        .snan(Asnan), .qnan(Aqnan), .inf(Ainf), .zero(Azero),
        .subnormal(Asubnormal), .normal(Anormal),
        .negative(Anegative), .overflow(Aoverflow), .carry(Acarry)
    );

    Fp_clasifier32 B (
        .inputfloat(b),
        .snan(Bsnan), .qnan(Bqnan), .inf(Binf), .zero(Bzero),
        .subnormal(Bsubnormal), .normal(Bnormal),
        .negative(Bnegative), .overflow(Boverflow), .carry(Bcarry)
    );

    // Lógica de multiplicación
    always @(*) begin
        productoTemp = 0;
        flags_reg = 4'b0000;
        Signo = a[31] ^ b[31]; // XOR entre los signos de a y b

        // Caso 1: signaling NaN
        if (Asnan | Bsnan) begin
            productoTemp = Asnan ? a : b;
            flags_reg = 4'b0000;
        end

        // Caso 2: quiet NaN
        else if (Aqnan | Bqnan) begin
            productoTemp = Aqnan ? a : b;
            flags_reg = 4'b0000;
        end

        // Caso 3: alguno es infinito
        else if (Ainf | Binf) begin
            if (Azero | Bzero) begin
                // inf * 0 → NaN
                productoTemp = {Signo, 8'b11111111, 1'b1, 22'b1};
                flags_reg = 4'b0000;
            end else begin
                // inf * normal → inf
                productoTemp = {Signo, 8'b11111111, 23'b0};
                flags_reg = 4'b0000;
            end
        end

        // Caso 4: cero o ambos subnormales → resultado cero
        else if (Azero | Bzero || (Asubnormal & Bsubnormal)) begin
            productoTemp = {Signo, 31'b0};
            flags_reg[1] = 1; // Flag de cero
        end

        // Caso 5: multiplicación normal
        else begin
            // Se extraen exponentes sin sesgo
            expa = a[30:23] - bias;
            expb = b[30:23] - bias;

            // Se calcula el nuevo exponente con sesgo reaplicado
            exponent = expa + expb + bias;

            // Multiplicación de mantisas (con 1 implícito)
            partialResult = {1'b1, a[22:0]} * {1'b1, b[22:0]};

            // Normalización si hay overflow en la multiplicación (bit 47 activo)
            if (partialResult[47]) begin
                partialResult = partialResult >> 1;
                exponent = exponent + 1;
            end

            // Caso: overflow de exponente → infinito
            if (exponent > 254) begin
                productoTemp = {Signo, 8'b11111111, 23'b0}; // inf
                flags_reg[0] = 1; // Flag de overflow
            end

            // Caso: exponente muy bajo → underflow → resultado cero
            else if (exponent < 1) begin
                productoTemp = {Signo, 31'b0};
                flags_reg[1] = 1; // Flag de cero
            end

            // Caso: resultado normal
            else begin
                productoTemp = {Signo, exponent[7:0], partialResult[45:23]};
                flags_reg = 4'b0000;
            end
        end

        // Flag de negativo si el bit de signo es 1
        if (productoTemp[31] == 1)
            flags_reg[3] = 1;
    end

    // Asignación final a las salidas
    assign mul32 = productoTemp;
    assign flags = flags_reg;

endmodule