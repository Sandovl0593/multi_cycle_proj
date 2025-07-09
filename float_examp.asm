MOV R4, #3.55
MOV R1, R4  // <- entra format 

MOV R3, #40
MOV R7, #3
DIV R6, R3, R7  // saldria floating 13.333

FPADD16 R6, R6, R3    // no posible float = float + int
FPADD16 R6, R6, R4   // otro floating