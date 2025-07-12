// EULER INTEGRATION - TEST CODE
// 2nd order ODE integrator PROGRAM

MOV R0, #128; // ITERATIONS

// Encuentra una manera de CARGAR los siguentes FLOAT de 32 BITS

// (32bits en simulacion, 16bits en placa)

// FLOAT VARIABLES  
MOV R1, #0                 // X VALUE 
MOV R2,     #0x4200        // #3.0 // DX VALUE
MOV R3,     #0x00002E00
ORR R3, R3, #0x00000066    // #0.1 // DT

//// FLOAT CONSTANTS
MOV R4,     #0x0000B600
ORR R4, R4, #0x00000066    // #-0.4 // DT
MOV R5, R3                 // B

FOR:
    // COMPUTE DF(X,DX) => DT * DX
    MOV R6, R2
    FPMUL16 R6, R6, R3
    
    // COMPUTE DF(V,DT) = DT * (A * X + B * DX)
    MOV R7, R1
    FPMUL16 R7, R7, R4 // A * X
    
    MOV R8,R2
    FPMUL16 R8, R8, R5 // B * DX

    FPADD16 R7, R7, R8 // A * X + B * DX
    FPMUL16 R7, R7, R3 // DT * (A * X + B * DX)

    // UPDATE X AND DX
    FPADD16 R1, R1, R6 // X = X + DF(X,DX)
    FPADD16 R2, R2, R7 // DX = DX + DF(V,DT)
    
    SUBS R0, R0, #1
    BEQ END_FOR
    B FOR

END_FOR:
    // DISPLAY THE RESULT USING THE 7 SEGMENT DISPLAY. (Pueden usar esto para probar con la placa / opcional)
// El resultado final es 11.4 en (32bits en simulacion, 16bits en placa)