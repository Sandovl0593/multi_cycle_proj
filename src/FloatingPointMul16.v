module FloatingPointMul16(
    input  [15:0] a,
    input  [15:0] b,
    output wire [15:0] mul16,
    output wire [3:0] flags // [overflow, zero, carry (no usado), negative]
);

    parameter bias = 15; // para half-precision (5-bit exponent)

    // Extraer campos IEEE 754 half-precision (16 bits)
    wire signA = a[15];
    wire signB = b[15];
    wire [4:0] expA = a[14:10];
    wire [4:0] expB = b[14:10];
    wire [9:0] fracA = a[9:0];
    wire [9:0] fracB = b[9:0];

    // Agregar bit implícito
    wire [10:0] mantA = (expA == 0) ? {1'b0, fracA} : {1'b1, fracA};
    wire [10:0] mantB = (expB == 0) ? {1'b0, fracB} : {1'b1, fracB};

    // Multiplicación de mantisas (hasta 22 bits)
    wire [21:0] mantProd = mantA * mantB;

    // Exponentes sin bias
    wire signed [6:0] rawExpA = (expA == 0) ? 1 : expA;
    wire signed [6:0] rawExpB = (expB == 0) ? 1 : expB;
    reg   signed [7:0] exponent;

    reg [15:0] productoTemp;
    reg [3:0]  flags_reg;
    reg        Signo;
    reg [21:0] normMant;
    reg [9:0]  finalMant;
    reg [4:0]  finalExp;

    integer shift;

    always @(*) begin
        flags_reg = 4'b0000;
        productoTemp = 16'b0;
        Signo = signA ^ signB;

        exponent = rawExpA + rawExpB - bias;

        if (mantProd[21]) begin
            normMant = mantProd >> 1;
            exponent = exponent + 1;
        end else begin
            normMant = mantProd;
            shift = 0;
            while (normMant[20 - shift] == 0 && shift < 10) begin
                shift = shift + 1;
            end
            normMant = normMant << shift;
            exponent = exponent - shift;
        end

        finalMant = normMant[19:10];
        finalExp = exponent[4:0];

        if (expA == 5'b11111 || expB == 5'b11111) begin
            productoTemp = 16'h7E00; // NaN en half-precision
            flags_reg[2] = 1;
        end else if (exponent >= 31) begin
            productoTemp = {Signo, 5'b11111, 10'b0}; // Inf
            flags_reg[3] = 1; // overflow
        end else if (exponent <= 0) begin
            productoTemp = {Signo, 15'b0};
            flags_reg[2] = 1; // zero
        end else begin
            productoTemp = {Signo, finalExp, finalMant};
            if (productoTemp[14:0] == 0)
                flags_reg[2] = 1; // zero
        end

        if (productoTemp[15])
            flags_reg[0] = 1; // negative
    end

    assign mul16 = productoTemp;
    assign flags = flags_reg;

endmodule
