// EULER INTEGRATION - TEST CODE
// 2nd order ODE integrator PROGRAM

MOV R0, #128; // ITERATIONS
MOV R10, #0x10               // R10 = 16

// Encuentra una manera de CARGAR los siguentes FLOAT de 32 BITS
// FLOAT VARIABLES

// (32bits en simulacion, 16bits en placa)

MOV R1, #0            // 0.0f // X VALUE

MOV R2, #0x40
MUL R2, R3, R10       // R2 = 0x400
MUL R2, R2, R10       // R2 = 0x4000
MUL R2, R2, R10       // R2 = 0x40000
MUL R3, R2, R10       // R2 = 0x400000
MUL R2, R3, R10       // R2 = 0x4000000
MUL R2, R2, R10       // R2 = 0x40000000
ADD R2, R2, R3        // R2 = 0x40400000   // 3.0f // DX VALUE

MOV R3, #0x3D
MUL R3, R3, R10         // R3 = 0x3D0
MUL R3, R3, R10         // R3 = 0x3D00
MOV R4, #0xCC
ADD R3, R3, R4          // R3 = Ox3DCC
MUL R3, R3, R10         // R3 = 0x3DCC0
MUL R3, R3, R10         // R3 = 0x3DCC00
ADD R3, R3, R4          // R3 = Ox3DCCCC
MUL R3, R3, R10         // R3 = 0x3DCCCC0
MUL R3, R3, R10         // R3 = 0x3DCCCC00
MOV R4, #0xCD
ADD R3, R3, R4          // R3 = Ox3DCCCCCD // 0.1f // DT

//// FLOAT CONSTANTS
MOV R5, R3              // R5 = 0x3DCCCCCD // 0.1f // B

MOV R4, #0xBE
MUL R4, R4, R10         // R4 = 0xBE0
MUL R4, R4, R10         // R4 = 0xBE00
MOV R6, #0xCC
ADD R4, R4, R6          // R4 = OxBECC
MUL R4, R4, R10         // R4 = 0xBECC0
MUL R4, R4, R10         // R4 = 0xBECC00
ADD R4, R4, R6          // R4 = OxBECCCC
MUL R4, R4, R10         // R4 = 0xBECCCC0
MUL R4, R4, R10         // R4 = 0xBECCCC00
MOV R6, #0xCD
ADD R4, R4, R6          // R4 = #0xBECCCCCD // -0.4f // A

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