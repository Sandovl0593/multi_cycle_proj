module FloatingPointMul16(
    input [15:0] a,
    input [15:0] b,
    output wire [15:0] mul16,
    output wire [3:0] flags // Flags: [overflow, zero, carry, negative]
);

    // Salidas del clasificador para cada operando
    wire Asnan, Aqnan, Ainf, Azero, Asubnormal, Anormal, Anegative, Aoverflow, Acarry;
    wire Bsnan, Bqnan, Binf, Bzero, Bsubnormal, Bnormal, Bnegative, Boverflow, Bcarry;

    reg [15:0] resultadoTemp;
    reg [21:0] partialResult;
    reg [4:0] expa;
    reg [4:0] expb;
    reg [5:0] exponent;
    reg Signo;
    reg [3:0] flags_reg;

    parameter bias = 15; // Sesgo para half-precision

    // Clasificación de operandos
    Fp_clasifier16 A (
        .float(a),
        .snan(Asnan), .qnan(Aqnan), .inf(Ainf), .zero(Azero),
        .subnormal(Asubnormal), .normal(Anormal),
        .negative(Anegative), .overflow(Aoverflow), .carry(Acarry)
    );

    Fp_clasifier16 B (
        .float(b),
        .snan(Bsnan), .qnan(Bqnan), .inf(Binf), .zero(Bzero),
        .subnormal(Bsubnormal), .normal(Bnormal),
        .negative(Bnegative), .overflow(Boverflow), .carry(Bcarry)
    );

    // Lógica principal de multiplicación
    always @(*) begin
        resultadoTemp = 0;
        flags_reg = 4'b0000;
        Signo = a[15] ^ b[15]; // XOR de signos

        // Caso 1: signaling NaN
        if (Asnan | Bsnan) begin
            resultadoTemp = Asnan ? a : b;
            flags_reg = 4'b0000;
        end

        // Caso 2: quiet NaN
        else if (Aqnan | Bqnan) begin
            resultadoTemp = Aqnan ? a : b;
            flags_reg = 4'b0000;
        end

        // Caso 3: Infinito
        else if (Ainf | Binf) begin
            if (Azero | Bzero) begin
                resultadoTemp = {Signo, 5'b11111, 1'b1, 9'b1}; // NaN
                flags_reg = 4'b0000;
            end else begin
                resultadoTemp = {Signo, 5'b11111, 10'b0}; // Inf
                flags_reg = 4'b0000;
            end
        end

        // Caso 4: cero o ambos subnormales
        else if (Azero | Bzero || (Asubnormal & Bsubnormal)) begin
            resultadoTemp = {Signo, 15'b0}; // Resultado cero
            flags_reg[1] = 1; // Activar flag de cero
        end

        // Caso 5: Multiplicación normal
        else begin
            expa = a[14:10] - bias;
            expb = b[14:10] - bias;
            exponent = expa + expb + bias;

            // Multiplicación de mantisas con 1 implícito
            partialResult = {1'b1, a[9:0]} * {1'b1, b[9:0]};

            // Normalización si el bit más alto está encendido
            if (partialResult[21]) begin
                partialResult = partialResult >> 1;
                exponent = exponent + 1;
            end

            // Caso: overflow de exponente
            if (exponent > 30) begin
                resultadoTemp = {Signo, 5'b11111, 10'b0}; // Inf
                flags_reg[0] = 1; // Flag de overflow
            end

            // Caso: underflow (exponente < 1)
            else if (exponent < 1) begin
                resultadoTemp = {Signo, 15'b0}; // Resultado cero
                flags_reg[1] = 1; // Flag de cero
            end

            // Resultado normal
            else begin
                resultadoTemp = {Signo, exponent[4:0], partialResult[19:10]};
                flags_reg = 4'b0000;
            end
        end

        // Flag negativo si MSB del resultado es 1
        if (resultadoTemp[15] == 1)
            flags_reg[3] = 1;
    end

    // Asignación final a las salidas
    assign mul16 = resultadoTemp;
    assign flags = flags_reg;

endmodule