module FloatingPointAdd16(
    input wire [15:0] a,
    input wire [15:0] b,
    output reg [15:0] add16,     // Resultado final en formato 16-bit
    output wire [3:0] flags
);

    reg negative, zero, carry, overflow; //los flags respectivos

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

        // Extraemos campos de entrada, signos , exponentes y mantissa por cada input
        sign_a = a[15];
        sign_b = b[15];
        expA = a[14:10];
        expB = b[14:10];
        mantissaA = {1'b1, a[9:0]};   // Agregamos bit implícito
        mantissaB = {1'b1, b[9:0]};   // mantissa de B (el bit más significativo es para detectar si hay carry o no)

        if (expA > expB) begin
            expResul[4:0] = expA; //Al ser A mayor que B, se asigna el expA a expResul
            signResul = sign_a;
            //Suma o resta mantissas alineadas segun signos
            if (sign_a == sign_b)
                mantissaResul = mantissaA + (mantissaB >> (expA - expB));
            else
                mantissaResul = mantissaA - (mantissaB >> (expA - expB));

            if (expA >= 5'b11110 && mantissaResul[9:0] == 10'b1111111111)
                overflow = 1; // Verificamos si se está acercando al valor máximo representable en formato IEEE 754
        end else if (expA < expB) begin
            expResul[4:0] = expB; //Al ser B mayor que A, se asigna el expB a expResul
            signResul = sign_b;   //Se le asigna el signo de B al signo resultado
            if (sign_a == sign_b)
                mantissaResul = mantissaB + (mantissaA >> (expB - expA));
            else
                mantissaResul = mantissaB - (mantissaA >> (expB - expA));

            if (expB >= 5'b11110 && mantissaResul[9:0] == 10'b1111111111)
                overflow = 1;
        end else begin
            expResul[4:0] = expA;// o sea si( expB == expA )
            if (sign_a == sign_b) begin // Como los exponentes ya están alineados, se suman directamente las mantissas si tienen el mismo signo
                mantissaResul = mantissaA + mantissaB;
                signResul = sign_a;
            end else begin // Si los signos son distintos, el signo del resultado será del mayor en magnitud
                if (mantissaA > mantissaB) begin
                    mantissaResul = mantissaA - mantissaB;
                    signResul = sign_a;
                end 
                else begin
                    mantissaResul = mantissaB - mantissaA;
                    signResul = sign_b;
                end
            end
        end

        // Verificar carry con el bit más significativo
        carry = mantissaResul[11];

        // Normalización
        if (sign_a == sign_b) begin
            if (mantissaResul[11] == 1) begin
                expResul = expResul + 1;
                add16 = {signResul, expResul[4:0], mantissaResul[10:1]};
            end else begin
                add16 = {signResul, expResul[4:0], mantissaResul[9:0]};
            end
            
        end 
        /*else begin
            while (mantissaResul[10] == 0 && expResul != 0) begin
                mantissaResul = mantissaResul << 1; // mantissa resultante se normaliza
                expResul = expResul - 1;
            end
            add16 = {signResul, expResul[4:0], mantissaResul[9:0]};
        end*/
         
        else begin // Normalización si los signos eran distintos
            for (i = 0; i < 11; i = i + 1) begin
                if (mantissaResul[10] == 0 && expResul != 0) begin
                    mantissaResul = mantissaResul << 1;
                    expResul = expResul - 1;
                end
            end
            add16 = {signResul, expResul[4:0], mantissaResul[9:0]};
        end 

        // Verificamos resultado cero
        if (add16[14:0] == 15'b0) begin
            add16[15] = 1'b0;
            zero = 1;
            carry = 0;
            overflow = 0;
            negative = 0;
        end

        if (add16[15] == 1) negative = 1; //verificar si es negativo
        if (expResul[4:0] == 5'b11111) overflow = 1; //verificar el overflow
    end

    assign flags = {negative, zero, carry, overflow};

endmodule


