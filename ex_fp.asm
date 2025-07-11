// Carga valores
MOV R2,     #0x40000000
ORR R2, R2, #0x00400000 // R2 = 0x40400000 = 3.0
MOV R3, #0x40           // R3 = 2.0
MOV R4, #0x3F
ORR R4, R4, #0xC0000000 // R4 = 0x3FC00000 = 1.5
// Multiplicación: R5 = R2 * R3 → 3.0 * 2.0 = 6.0
FPMUL32 R5, R2, R3
// Suma: R6 = R5 + R4 → 6.0 + 1.5 = 7.5
FPADD32 R6, R5, R4
MOV R6, R6