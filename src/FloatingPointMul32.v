module FloatingPointMul32(
    input [31:0] a,
    input [31:0] b,
    output wire [31:0] mul32,
    output wire [3:0] flags // [overflow, zero, carry (no usado), negative]
);

    parameter bias = 127;

    // Extraer campos IEEE 754
    wire signA = a[31];
    wire signB = b[31];
    wire [7:0] expA = a[30:23];
    wire [7:0] expB = b[30:23];
    wire [22:0] fracA = a[22:0];
    wire [22:0] fracB = b[22:0];

    // Agregar bit implícito si normal
    wire [23:0] mantA = (expA == 0) ? {1'b0, fracA} : {1'b1, fracA};
    wire [23:0] mantB = (expB == 0) ? {1'b0, fracB} : {1'b1, fracB};

    // Multiplicación de mantisas (hasta 48 bits)
    wire [47:0] mantProd = mantA * mantB;

    // Sumar exponentes sin bias, luego aplicar bias final
    wire signed [9:0] rawExpA = (expA == 0) ? 1 : expA;
    wire signed [9:0] rawExpB = (expB == 0) ? 1 : expB;
    reg   signed [9:0] exponent;

    reg [31:0] productoTemp;
    reg [3:0]  flags_reg;
    reg        Signo;
    reg [47:0] normMant;
    reg [22:0] finalMant;
    reg [7:0]  finalExp;

    integer shift;

    always @(*) begin
        flags_reg = 4'b0000;
        productoTemp = 32'b0;
        Signo = signA ^ signB;

        // Paso 1: Calcular exponente inicial
        exponent = rawExpA + rawExpB - bias;

        // Paso 2: Normalizar
        if (mantProd[47]) begin
            normMant = mantProd >> 1;
            exponent = exponent + 1;
        end else begin
            normMant = mantProd;
            // Normalización hacia la izquierda (cuando < 1.0)
            shift = 0;
            while (normMant[46 - shift] == 0 && shift < 23) begin
                shift = shift + 1;
            end
            normMant = normMant << shift;
            exponent = exponent - shift;
        end

        finalMant = normMant[45:23];
        finalExp = exponent[7:0];

        // Paso 3: Casos especiales
        if (expA == 8'hFF || expB == 8'hFF) begin
            productoTemp = 32'h7FC00000; // NaN
            flags_reg[2] = 1; // overflow
        end else if (exponent >= 255) begin
            productoTemp = {Signo, 8'hFF, 23'b0}; // Inf
            flags_reg[3] = 1; // overflow
        end else if (exponent <= 0) begin
            productoTemp = {Signo, 31'b0}; // 0
            flags_reg[2] = 1; // zero
        end else begin
            productoTemp = {Signo, finalExp, finalMant};
            if (productoTemp[30:0] == 0)
                flags_reg[2] = 1; // zero
        end

        // Bit negativo
        if (productoTemp[31])
            flags_reg[0] = 1; // negative
    end

    assign mul32 = productoTemp;
    assign flags = flags_reg;

endmodule
