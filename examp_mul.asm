SUB     R1, R15, R15   // R1 = 0
ADD     R2, R1, #0x33 // R2 = 51
ADD     R3, R1, #0x5 //R3 = 5

MUL   R4, R2, R3 //R4 = 255 o 0xFF
MUL   R5, R4, R3  // R5 = 255*5= 1275
MUL   R7, R4, R4 //R7 = R4*R4 = 65025

UMULL   R6, R7, R4, R8 //R6 = R7 * 255
UMULL   R6, R6, R4, R8 //R6 = R6 * 255
UMULL   R6, R6, R4, R8 //R6 = R6 * 255

DIV R10, R7, R4   // R10 = 65025 / 255 = 255 o 0xff

ADD  R9, R1, #-5
SMULL  R10, R7, R9, R11 //R10 = R7 * -5 = -325125 o 0x-4f605
SMULL  R10, R10, R4, R11 // R10 = R10 * 255 = 0x-1fa05fe
SMULL  R10, R10, R4, R11 // R10 = R10 * 255 = 0x-1f80bf802
