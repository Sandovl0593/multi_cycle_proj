// EULER INTEGRATION - TEST CODE
// 2nd order ODE integrator PROGRAM
MOV R0, #128 // ITERATIONS

// Encuentra una manera de CARGAR los siguentes FLOAT de 32 BITS

// (32bits en simulacion, 16bits en placa)

// FLOAT VARIABLES  
MOV R1, #0                 // R1 = 0   // X VALUE 
MOV R2,     #0x40000000
ORR R2, R2, #0x00400000    // R2 = 3.0 // DX VALUE

MOV R3,     #0x3D000000
ORR R3, R3, #0x00CC0000
ORR R3, R3, #0x0000CC00
ORR R3, R3, #0x000000CD    // R3 = 0.1 // DT

//// FLOAT CONSTANTS
MOV R4,     #0xBE000000
ORR R4, R4, #0x00CC0000
ORR R4, R4, #0x0000CC00
ORR R4, R4, #0x000000CD    // R4 = 0.4 // DT
MOV R5, R3                 // R5 = 0.1  // B 

FOR:
    // COMPUTE DF(X,DX) => DT * DX
    MOV R6, R2                                  // R6 = 3.0               -> 3.0
    FPMUL32 R6, R6, R3                          // R6 = 3.0 * 0.1 = 0.3   -> 3.0 + 0.1 = 0.3
    
    // COMPUTE DF(V,DT) = DT * (A * X + B * DX)
    MOV R7, R1                                  // R7 = 0                 -> 0.03
    FPMUL32 R7, R7, R4 // A * X                 // R7 = 0 * -0.4 = 0       -> 0.03 * -0.4 = -0.012
    
    MOV R8,R2                                   // R8 = 3.0               -> 0.3
    FPMUL32 R8, R8, R5 // B * DX                // R8 = 3.0 * 0.1 = 0.3   -> 0.3 + 0.1 = 0.003

    FPADD32 R7, R7, R8 // A * X + B * DX        // R7 = 0 + 0.3 = 0.3     -> -0.012 + 0.3 = 0.288
    FPMUL32 R7, R7, R3 // DT * (A * X + B * DX) // R7 = 0.3 * 0.1 = 0.03  -> 0.33 * 0.1 = 0.033

    // UPDATE X AND DX
    FPADD32 R1, R1, R6 // X = X + DF(X,DX)      // R1 = 0 + 0.3 = 0.3     -> 0.3 + 0.3 = 0.6
    FPADD32 R2, R2, R7 // DX = DX + DF(V,DT)    // R2 = 3.0 + 0 = 3.0     -> 3.0 + 0.03 = 3.03
    
    SUBS R0, R0, #1
    BEQ END_FOR
    B FOR

END_FOR:
    // DISPLAY THE RESULT USING THE 7 SEGMENT DISPLAY. (Pueden usar esto para probar con la placa / opcional)
// El resultado final es 11.4 en (32bits en simulacion, 16bits en placa)