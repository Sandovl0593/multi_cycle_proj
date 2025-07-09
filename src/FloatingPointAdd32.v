`timescale 1ns / 1ps

module FloatingPointAdd32(
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] add32,    // Almacena el resultado del floating point ADD
    output wire [3:0] flags
    );
    
    reg negative , zero , carry , overflow ; // los flags
    
    reg sign_a;            // signo de A
    reg sign_b;            // signo de B
    reg [7:0] expA;        // exponente de A
    reg [7:0] expB;        // exponente de B
    reg [23:0] mantissaA;  // mantissa de A ( considera 1. mantissa )
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
    
    mantissaA = {1'b1, a[22:0]};    //mantissa de A (el bit más significativo es para detectar si hay carry o no)
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
           overflow = 1;
        
            
    end
    
    
endmodule
