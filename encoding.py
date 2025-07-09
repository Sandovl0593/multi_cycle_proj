#################################
# You can change encodings HERE #
#################################

DP_INS = {
    "AND": 0b0000,
    "SUB": 0b0010,
    "ADD": 0b0100,
    "ORR": 0b1100,
    "MOV": 0b1101,
    "LSL": 0b1101,
    "LSR": 0b1101,
    "ASR": 0b1101,
    "ROR": 0b1101,
    "MUL": 0b0000,
    "DIV": 0b1111,
    "FPADD32": 0b0001,
    "FPADD16": 0b0011,
    "FPMUL32": 0b0101,
    "FPMUL16": 0b0111
}

MEM_INS = {
    "STR": 0b00,
    "LDR": 0b01,
    "STRB": 0b10,
    "LDRB": 0b11,
}

B_INS = {"B": 0b0}
    
CONDS = {
    "EQ": 0b0000,
    "NE": 0b0001,
    "CS": 0b0010,
    "HS": 0b0010,
    "CC": 0b0011,
    "LO": 0b0011,
    "MI": 0b0100,
    "PL": 0b0101,
    "VS": 0b0110,
    "VC": 0b0111,
    "HI": 0b1000,
    "LS": 0b1001,
    "GE": 0b1010,
    "LT": 0b1011,
    "GT": 0b1100,
    "LE": 0b1101,
    "AL": 0b1110,
}

TWOREG_INS = {
    "UMULL": 0b0100,
    "SMULL": 0b0110,
}