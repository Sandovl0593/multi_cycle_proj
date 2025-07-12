module FloatingPointMul32(
    input [31:0] a,
    input [31:0] b,
    output wire [31:0] mul32,
    output wire [3:0] flags // [overflow, zero, carry (no usado), negative]
);

    // Flags del clasificador
    wire Asnan, Aqnan, Ainf, Azero, Asubnormal, Anormal, Anegative, Aoverflow, Acarry;
    wire Bsnan, Bqnan, Binf, Bzero, Bsubnormal, Bnormal, Bnegative, Boverflow, Bcarry;

    reg [31:0] productoTemp;
    reg [47:0] partialResult;
    reg signed [8:0] expa;
    reg signed [8:0] expb;
    reg signed [9:0] exponent;
    reg Signo;
    reg [3:0] flags_reg;

    parameter bias = 127;

    // Clasificadores
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

    always @(*) begin
        productoTemp = 0;
        flags_reg = 4'b0000;
        Signo = a[31] ^ b[31];

        // Caso NaN
        if (Asnan | Bsnan) begin
            productoTemp = Asnan ? a : b;
        end else if (Aqnan | Bqnan) begin
            productoTemp = Aqnan ? a : b;
        end

        // Caso infinito
        else if (Ainf | Binf) begin
            if (Azero | Bzero) begin
                productoTemp = {Signo, 8'b11111111, 1'b1, 22'b1}; // NaN
            end else begin
                productoTemp = {Signo, 8'b11111111, 23'b0}; // Inf
            end
        end

        // Caso cero
        else if (Azero | Bzero || (Asubnormal & Bsubnormal)) begin
            productoTemp = {Signo, 31'b0};
            flags_reg[1] = 1; // zero flag
        end

        // Multiplicación normal
        else begin
            expa = $signed(a[30:23]) - bias;
            expb = $signed(b[30:23]) - bias;
            exponent = expa + expb + bias;

            // Multiplicación de mantisas
            partialResult = {1'b1, a[22:0]} * {1'b1, b[22:0]};

            // Normalización
            if (partialResult[47]) begin
                partialResult = partialResult >> 1;
                exponent = exponent + 1;
            end

            // Overflow
            if (exponent >= 255) begin
                productoTemp = {Signo, 8'b11111111, 23'b0}; // Inf
                flags_reg[0] = 1; // overflow
            end
            // Underflow
            else if (exponent <= 0) begin
                productoTemp = {Signo, 31'b0}; // Zero
                flags_reg[1] = 1;
            end
            // Resultado normal
            else begin
                productoTemp = {Signo, exponent[7:0], partialResult[45:23]};
            end
        end

        // Negativo
        if (productoTemp[31])
            flags_reg[3] = 1;
    end

    assign mul32 = productoTemp;
    assign flags = flags_reg;

endmodule