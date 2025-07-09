Test - FP


// EULER INTEGRATION - TEST CODE
// 2nd order ODE integrator PROGRAM

//MAKE A SIMPLE FOOR LOOP
MOV R0, #128; // ITERATIONS

// Encuentra una manera de CARGAR los siguentes FLOAT de 32 BITS
// FLOAT VARIABLES  
//MOV R1, 0.0f;   // X VALUE 
//MOV R2, 3.0f;   // DX VALUE
//MOV R3, 0.1f;  // DT
//// FLOAT CONSTANTS
//MOV R4, -0.4f;   // A
//MOV R5, 0.1f;   // B
FOR:
    // COMPUTE DF(X,DX) => DT * DX
    MOV R6, R2;
    FMUL R6, R3;
    // COMPUTE DF(V,DT) = DT * (A * X + B * DX)
    MOV R7,R1;
    FMUL R7, R4; // A * X
    MOV R8,R2;
    FMUL R8, R5; // B * DX

    FADD R7, R8; // A * X + B * DX
    FMUL R7, R3; // DT * (A * X + B * DX)

    // UPDATE X AND DX
    FADD R1, R6; // X = X + DF(X,DX)
    FADD R2, R7; // DX = DX + DF(V,DT)
    BEQ END_FOR;
    B FOR;

END_FOR:
    // DISPLAY THE RESULT USING THE 7 SEGMENT DISPLAY. (Pueden usar esto para probar con la placa / opcional)
// El resultado final es 11.4 en 16bits