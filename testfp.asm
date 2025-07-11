// EULER INTEGRATION - TEST CODE
// 2nd order ODE integrator PROGRAM

MOV R0, #128; // ITERATIONS
MOV R10, #0x10               // R10 = 16

// Encuentra una manera de CARGAR los siguentes FLOAT de 32 BITS

// (32bits en simulacion, 16bits en placa)

// FLOAT VARIABLES  
MOV R1, #0                 // X VALUE 
MOV R2,     #0x40000000
ORR R2, R2, #0x00400000    // #3.0 // DX VALUE

MOV R3,     #0x3D000000
ORR R3, R3, #0x00CC0000
ORR R3, R3, #0x0000CC00
ORR R3, R3, #0x000000CD    // #0.1 // DT

//// FLOAT CONSTANTS
MOV R4,     #0xBE000000
ORR R4, R4, #0x00CC0000
ORR R4, R4, #0x0000CC00
ORR R4, R4, #0x000000CD    // #-0.4 // DT
MOV R5, R3                 // B

FOR:
    // COMPUTE DF(X,DX) => DT * DX
    MOV R6, R2
    FPMUL32 R6, R6, R3
    
    // COMPUTE DF(V,DT) = DT * (A * X + B * DX)
    MOV R7, R1
    FPMUL32 R7, R7, R4 // A * X
    
    MOV R8,R2
    FPMUL32 R8, R8, R5 // B * DX

    FPADD32 R7, R7, R8 // A * X + B * DX
    FPMUL32 R7, R7, R3 // DT * (A * X + B * DX)

    // UPDATE X AND DX
    FPADD32 R1, R1, R6 // X = X + DF(X,DX)
    FPADD32 R2, R2, R7 // DX = DX + DF(V,DT)
    
    SUB R0, R0, #1
    BEQ END_FOR
    B FOR

END_FOR:
    // DISPLAY THE RESULT USING THE 7 SEGMENT DISPLAY. (Pueden usar esto para probar con la placa / opcional)
// El resultado final es 11.4 en (32bits en simulacion, 16bits en placa)