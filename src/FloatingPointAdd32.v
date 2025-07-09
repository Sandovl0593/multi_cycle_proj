`timescale 1ns / 1ps

module FloatingPointAdd32(
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] add32,    // Almacena el resultado del floating point ADD32
    output wire [3:0] flags
    );
    
    reg negative , zero , carry , overflow ; // los flags respectivos
    
    reg sign_a;            // signo de A -> bit 31
    reg sign_b;            // signo de B
    reg [7:0] expA;        // exponente de A -> 30:23
    reg [7:0] expB;        // exponente de B
    reg [23:0] mantissaA;  // mantissa de A ( considera 1. mantissa ) -> 22:0
    reg [23:0] mantissaB;  // mantissa de B ( considera 1. mantissa )
    
    reg signResul;         // signo del resultado
    reg [8:0] expResul;    // signo del resultado (el bit más significativo es para detectar si hay overflow o no)
    reg [24:0] mantissaResul;   //mantissa del resultado (el bit más significativo es para detectar si hay carry o no)
    
    always @(*)begin
        //inicializamos los flags con 0
        zero = 0;
        negative = 0;
        carry = 0;
        overflow = 0 ;
        expResul[8] = 1'b0;
        
        //define signos, exponentes y mantisa por cada input 
        sign_a = a[31]; //signo de A 
        sign_b = b[31]; //signo de B
        //exponentes
        expA = a[30:23];  //exponente de A (el bit más significativo es para detectar si hay overflow o no)
        expB = b[30:23];  //exponente de B (el bit más significativo es para detectar si hay overflow o no)
        
        mantissaA = {1'b1, a[22:0]};   //mantissa de A (el bit más significativo es para detectar si hay carry o no)
        mantissaB = {1'b1, b[22:0]};   //mantissa de B (el bit más significativo es para detectar si hay carry o no)
        
        if (expA > expB) begin 
            expResul[7:0] = expA;  //Al ser A mayor que B, se asigna el expA a expResul
            signResul = sign_a;    //Se le asigna el signo de A al signo resultado
            //Suma o resta mantissas alineadas segun signos
            if (sign_a == sign_b)  //Comparamos el signo de a con el signo de b
               mantissaResul = mantissaA + (mantissaB >> (expA - expB));
            else
               mantissaResul = mantissaA - (mantissaB >> (expA - expB));
            if (expA >= 8'b11111110 & mantissaResul[22:0]== 23'b11111111111111111111111) 
               overflow = 1; // Verificamos si se está acercando al valor máximo representable en formato IEEE 754      
        end
        else if (expA < expB) begin  
            expResul[7:0] = expB;  //Al ser B mayor que A, se asigna el expB a expResul
            signResul = sign_b;    //Se le asigna el signo de B al signo resultado
            if (sign_a == sign_b)
                mantissaResul = mantissaB + (mantissaA >> (expB - expA));
            else 
                mantissaResul = mantissaB - (mantissaA >> (expB - expA));
            if (expB >= 8'b11111110 & mantissaResul[22:0]== 23'b11111111111111111111111) 
               overflow = 1; // Verificamos si se está acercando al valor máximo representable en formato IEEE 754       
        end
        else begin
            expResul[7:0] = expA;// o sea si( expB == expA )
            if (sign_a == sign_b) begin // Como los exponentes ya están alineados, se suman directamente las mantissas si tienen el mismo signo
                mantissaResul = mantissaA + mantissaB;
                signResul = sign_a;
            end 
            else begin // Si los signos son distintos, el signo del resultado será del mayor en magnitud
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
        // Para verificar si la suma de mantissas generó carry en el bit más significativo
        carry = mantissaResul[24];
        
        if ( sign_a == sign_b ) begin // Normalización si los signos eran iguales
            if (mantissaResul[24] == 1) begin // Si hubo carry, se incrementa el exponente y se desplaza la mantissa una posición a la derecha
                expResul = expResul + 1;
                add32 = {signResul, expResul[7:0] , mantissaResul[23:1]};
            end
            else begin // Si no, se guarda directamente
                add32 = {signResul, expResul[7:0] , mantissaResul[22:0]};
            end
        end
        else begin // Normalización si los signos eran distintos
            while (mantissaResul[23] == 0 && expResul != 0) begin
                mantissaResul = mantissaResul << 1; // mantissa resultante se normaliza
                expResul =  expResul - 1;
            end
            add32 = {signResul, expResul[7:0] , mantissaResul[22:0]};
        end
        // Si el resultado es exactamente cero, se limpia el signo y todos los flags, y se activa zero
        if (add32[30:0] == 31'b0) begin
            add32[31] = 1'b0;
            zero = 1;
            carry = 0;
            overflow = 0;
            negative = 0;
        end
        if (add32[31] == 1) // Verifica si es negativo
            negative = 1;
        if ( expResul[7:0] == 8'b1) // Verifica si el exponente alcanzó el valor máximo representable, o sea verificar el overflow
            overflow = 1;
    end
    
    assign flags = {negative, zero, carry, overflow};
    
endmodule
