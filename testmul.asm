MOV R1, #0
SUB R1, R1, #1              // --> MOV, R1, #0xFFFFFFFF

MOV R2, #0x00000002         // R2 = 2

UMULL R4, R1,R2, R3         // (uns) 0xFFFFFFFF * 2 = 0x 00 00 00 01 FF FF FF FE
                            // --> R4 = 0xFFFFFFFE, R3 = 1

SMULL R6, R1,R2, R5         // (sig) 0xFFFF...F * 2 = 0x FF FF FF FF FF FF FF FE
                            // R6 = 0xFFFFFFFE, R5 = 0xFFFFFFFF

SUB R7, R4, R6              // R7 = 0xFFFFFFFE - 0xFFFFFFFE = 0
ADD R8, R5, R3              // R8 = 0xFFFFFFFF + 1 = 0
        
CMP R7, R8

// 1er test
BEQ CHECKPOINT1             // if R7 = R8 = 0
B ERROR

CHECKPOINT1:
SMULLS R5, R1, R2, R6       // (prev) R5 = 0xFFFFFFFE, R6 = 0xFFFFFFFF
                            // NZCV (activated in R6) -> 1000

// 2do test
BLT CHECKPOINT2             // if LT cond -> N xor V = 1
B ERROR 

CHECKPOINT2:  
MOV R1, #0x80000000
UMULLS R3, R1,R2, R10       // (uns) 0x80000000 * 2 = 0x 00 00 00 01 00 00 00 00
                            // --> [ R10 = 1 ], R3 = 0
                            // NZCV (activated in R3) -> 0000

UMULLEQ R3, R3, R10, R10    // execute if Z = 1 -> (no happen)
                            // --> finally R10 = 1

B END

ERROR:
MOV R10, #0
END:

MOV R10, R10                // visualizar R10 (ALUResult)