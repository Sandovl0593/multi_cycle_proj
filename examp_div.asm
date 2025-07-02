SUB     R1, R15, R15   // R1 = 0
ADD     R2, R1, #0x32 // R2 = 50
ADD     R7, R1, #3   // R7 = 3
ADD     R3, R1, #0x5 //R3 = 5

DIV     R4, R2, R3   // R4 = R2/R3 = 10
DIV     R5, R4, R7   // R5 = R4/R7 = 3 (trunc)
