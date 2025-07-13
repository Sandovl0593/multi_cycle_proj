# THIS CODE IS PROVIDED ON THE SUBJECT AND ADAPTED FOR THE PROJECT
import re
import sys
import struct
from encoding import *

TOKEN_SPEC = {
    "LABEL": r"[A-Za-z_][A-Za-z0-9_]*:",        # <name>:
    "REG": r"R(?:1[0-5]|[0-9])",                # R0, R1, ..., R15
    "POINTER": r"[A-Za-z_][A-Za-z0-9_]*",       # keyword instruction
    # "OP": r'[A-Z]{1,5}(EQ|NE|CS|CC|MI|PL|VS|VC|HI|LS|GE|LT|GT|LE|AL)?S?',
    "IMM_HEX": r"#0x[0-9a-fA-F]+",   # Immediate hex value
    "IMM_DEC": r"#[-]?[0-9]+(\.[0-9]+)?",  # Immediate decimal value
    "COMMA": r",",                              # Comma
    "S_COLON": r";",                            # Statement terminator
    "L_BRACKET": r"\[",                         # Left bracket
    "R_BRACKET": r"\]",                        # Right bracket
    "SPACE":r" ",                              # Space
    "UNKOWN": r"."                             # Unknown
}

def ror(value, shift):
    """Rotate right 32-bit"""
    shift %= 32
    return ((value >> shift) | (value << (32 - shift))) & 0xFFFFFFFF

def reg_val(r):
    val = int(r[1:])
    if not (0 <= val <= 15):
        raise ValueError(f"Registro fuera de rango (0-15): {r}")
    return val

def imm_val(type, s):
    val = 0
    if type == "IMM_HEX":
        val = int(s[3:], 16)

    elif type == "IMM_DEC":
        if '.' in s:
            # e.g. "#-123.45" o "#67.89" int(float()) ya trunca hacia cero
            val = -float(s[1:]) if s.startswith("#-") else float(s[1:])
        else:
            # int(s[1:], 0) respeta prefijos 0x, 0o, etc; pero aquí son decimales
            raw = int(s[1:], 10)
            val = -raw if s.startswith("#-") else raw
    else:
        raise ValueError(f"Formato de inmediato no reconocido: {s}")

    return val

def rot_format(val):
    uimm = val & 0xFFFFFFFF
    # Caso simple: cabe en 8 bits
    if uimm <= 0xFF:
        return uimm

    # Intentamos cada rotación posible
    for rot in range(16):
        # Para que imm = ROR(imm8, rot*2), inmovilizamos:
        #   imm8 = ROL(imm, rot*2) & 0xFF
        sh = (rot * 2) % 32
        imm8 = ((uimm << sh) | (uimm >> (32 - sh))) & 0xFF

        # Comprobamos que reconstruye idéntico
        if ror(imm8, sh) == uimm:
            return (rot << 8) | imm8
    raise ValueError(f"Valor inmediato no convertible a formato rotado: {val:#010x}")

class ARM_Assembler:
    def __init__(self):
        pattern = "|".join(f"(?P<{name}>{regex})" for name, regex in TOKEN_SPEC.items())
        self.regex = re.compile(pattern, re.IGNORECASE)

        self.labels = {}
        self.valid_ops = (
            list(DP_INS.keys())
            + list(MEM_INS.keys())
            + list(B_INS.keys())
            + list(TWOREG_INS.keys())
        )

    # Only for tokenization purposes
    # return: list of tuples (kind, value)
    def tokenize_instruction(self, instr: str) -> list[tuple[str, str]]:
        tokens = []
        for match in self.regex.finditer(instr):
            kind = match.lastgroup
            value = match.group()
            if kind == "POINTER":
                possible_instr, cond, S = self.decode_mnemonic(value)
                # validate if the instruction is valid
                if possible_instr in self.valid_ops and cond in CONDS:
                    kind = "OP"
            tokens.append((kind, value))
        return tokens

    # Decode the mnemonic and return the instruction, condition, and flags
    # return: (ASM instr, cond suffix, flags boolean)
    def decode_mnemonic(self, instr: str) -> tuple[str, str, bool]:
        instr = instr.upper()
        flags = instr.endswith("S")
        if flags:
            instr = instr[:-1]
        cond = "AL"
        for suffix in CONDS:
            if instr.endswith(suffix):
                cond = suffix
                instr = instr[: -len(suffix)]
                break
        return instr, cond, flags
    
    #
    # MAIN INSTRUCTION ENCODER
    # return: instruction encoded like a 32-bit integer
    def assemble_instruction(self, tokens: list[tuple[str, str]], pc) -> int:
        it = iter(tokens)
        w = next(it)

        # IGNORE LABEL
        while w[0] == "LABEL":
            if len(tokens) > 1:
                w = next(it)
            else:
                return -1

        if w[0] != "OP":
            raise RuntimeError(f"Function not implemented: {instr}")


        instr, cond, S = self.decode_mnemonic(w[1])
        
        regs = [reg_val(v) for (k, v) in tokens if k == "REG"]
        imms = [imm_val(k, v) for (k, v) in tokens if "IMM" in k]
        neg = imms[0] < 0 if imms else False
        # OP == DP
        if instr in TWOREG_INS:
            if len(regs) == 4:
                Rd, Rn, Rm, Ra = regs
                I = 0
            else:
                raise RuntimeError("Invalid DP format")
            
            cmd = TWOREG_INS[instr]

            # format [mulOp] Rd, Rn, Rm, Ra
            return (
                (CONDS[cond] << 28)                 # cond
                                                    # op = 00
                | (cmd << 21)                       # cmd
                | (S << 20)                         # S
                | (Rd << 16)                        # Rn
                | (Ra << 12)                        # Rd
                | (Rm << 8)                         # Rm
                | (0b1001 << 4)                     # 0b1001
                | Rn                                # Rn
            )

        if instr in DP_INS:
            # Custom DP exceptions
            if instr == "CMP":
                S = 1
                cmd = DP_INS[instr]
                if len(regs) == 1 and len(imms) == 1:
                    # CMP Rd, #imm
                    Rn = regs[0]
                    operand2 = rot_format(imms[0])
                    I = 1
                elif len(regs) == 2 and len(imms) == 0:
                    # CMP Rd, Rm
                    Rn, Rm = regs
                    I = 0
                    operand2 = Rm
                else:
                    raise RuntimeError(
                        f"Invalid CMP format: should be CMP Rd, Rm or CMP Rd, #imm"
                    )
               

                # Format CMP Rd, Rm or CMP Rd, #imm
                return (
                    (CONDS[cond] << 28)             # cond
                                                    # op = 00
                    | (I << 25)                     # I
                    | (cmd << 21)                   # cmd
                    | (S << 20)                     # S
                    | (Rn << 16)                    # Rn
                    | operand2                      # Src2
                )

            if instr == "MOV":
                S = 0
                Rn = 0
                cmd = DP_INS[instr]

                if len(regs) == 1 and len(imms) == 1:
                    # MOV Rd, #imm
                    Rd = regs[0]
                    operand2 = rot_format(imms[0])
                    I = 1
                elif len(regs) == 2 and len(imms) == 0:
                    # MOV Rd, Rm
                    Rd, Rm = regs
                    I = 0
                    operand2 = Rm
                else:
                    raise RuntimeError(
                        f"Invalid MOV format: shoulb be MOV Rd, Rm or MOV Rd, #imm"
                    )

                # Format MOV Rd, Rm or MOV Rd, #imm
                return (
                    (CONDS[cond] << 28)             # cond
                                                    # op = 00
                    | (I << 25)                     # I
                    | (cmd << 21)                   # cmd
                    | (S << 20)                     # S
                    | (Rn << 16)                    # Rn
                    | (Rd << 12)                    # Rd
                    | operand2                      # Src2
                )

            #
            # If you are not using the standard CPU-lator encoding for 'MUL' remove the following condicional
            #
            if instr == "MUL":
                if len(regs) != 3 and (len(imms) == 0):
                    raise RuntimeError(
                        f" {instr} format invalid. Should be : {instr} Rd, Rn, Rm"
                    )
                Rd, Rn, Rm = regs
                # format MUL Rd, Rn, Rm
                return (
                    (CONDS[cond] << 28)             # cond
                                                    # op = 00
                    | (S << 20)                     # S
                    | (Rd << 16)                    # Rd
                                                    # Ra = 0
                    | (Rm << 8)                     # Rm
                    | (0b1001 << 4)                 # 0b1001
                    | Rn                            # Rn
                )

            shift_instrs = ["LSL", "LSR", "ASR", "ROR"]
            if instr in shift_instrs:
                if len(regs) != 2 or not imms:
                    raise RuntimeError(
                        f" {instr} format invalid. Should be : {instr} Rd, Rm, #imm"
                    )
                Rd, Rm = regs
                shift_imm = imms[0]
                shift_type = shift_instrs.index(instr)             # index <-> encoding
                shift = (shift_imm << 7) | (shift_type << 5) | Rm  # [shamt sh 0 Rm]
                cmd = DP_INS[instr]
                
                # format [SH] Rd, Rm, #imm
                return (
                    (CONDS[cond] << 28)             # cond
                    | (0 << 25)                     # I
                    | (cmd << 21)                   # cmd
                    | (S << 20)                     # S
                                                    # Rn = 0
                    | (Rd << 12)                    # Rd
                    | shift                         # Shift
                )

            # General purpose encoding (eor, add, sub, etc)
            if len(regs) == 3:
                Rd, Rn, Rm = regs
                I = 0
                operand2 = Rm
            elif len(regs) == 2 and imms:
                Rd, Rn = regs
                I = 1
                operand2 = rot_format(imms[0])
            else:
                raise RuntimeError("Invalid DP format")
            cmd = DP_INS[instr]

            if (cmd == 0b0100 and neg):
                cmd = 0b0010  # Change ADD to SUB
            elif (cmd == 0b0010 and neg):
                cmd = 0b0100  # Change SUB to ADD

            # format [DPop] Rd, Rn, Rm  ;  [DPop] Rd, Rn, #imm
            return (
                (CONDS[cond] << 28)                 # cond
                                                    # op = 00
                | (I << 25)                         # I
                | (cmd << 21)                       # cmd
                | (S << 20)                         # S
                | (Rn << 16)                        # Rn
                | (Rd << 12)                        # Rd
                | operand2                          # Src2
            )

        # OP == MEM
        if instr in MEM_INS:
            #Check if MEM R1, [REG,REG] or [REG,IMM]
            Rd, Rn = regs[:2]
            code = MEM_INS[instr]
            L = code & 1
            B = (code >> 1) & 1
            
            if len(regs) == 3:
                #is reg reg reg
                I = 1
                operand2 = (regs[2])
            elif len(regs) == 2 and len(imms) == 1:
                #is reg reg imm
                I = 0
                operand2 = imms[0]
            else: 
                raise RuntimeError("Invalid MEM type format")
            
            # format [MEM] Rd, [Rn, Rm]  ;  [MEM] Rd, [Rn, #imm]
            return (
                (CONDS[cond] << 28)                 # cond
                | (1 << 26)                         # op = 01
                | (I << 25)                         # I
                | (0b11 << 23)                      # PU = 11
                | (B << 22)                         # B
                                                    # W = 0
                | (L << 20)                         # L
                | (Rn << 16)                        # Rn
                | (Rd << 12)                        # Rd
                | operand2                          # Src2
            )

        # OP == B
        if instr in B_INS:
            label_tok = next((v for (k, v) in tokens if k == "POINTER"), None)
            if label_tok is None:
                raise RuntimeError("Falta label en B")
            if label_tok not in self.labels:
                raise RuntimeError(f"Label no definido: {label_tok}")
            offset = self.labels[label_tok] - (pc + 2)
            return ((CONDS[cond] << 28)             # cond
                   | (0b101 << 25)                  # op = 10
                   | (offset & 0xFFFFFF))           # offset

        return 

    # Assemble the program from a string of instructions
    # return: list of integers (instructions) and list of original ASM lines
    def assemble_program(self, program: str) -> list[int]:
        lines = program.strip().splitlines()
        lines = [l.split('//', 1)[0].strip() for l in lines]
        lines = [l for l in lines if l != ""]

        extract = []
        token_lines = []
        pc = 0  
        for i,line in enumerate(lines):
            tokens = self.tokenize_instruction(line)
            if not tokens:
                continue

            if tokens[0][0] == "LABEL":
                label_name = tokens[0][1][:-1]
                self.labels[label_name] = pc  # No se incrementa el PC
                # ¿Hay una instrucción en esta línea?
                if len(tokens) > 1:
                    instr_tokens = tokens[1:]
                    extract.append(line)
                    token_lines.append((i+1,pc, instr_tokens))
                    pc += 1  # Ahora sí hay instrucción
            else:
                extract.append(line)
                token_lines.append((i+1,pc, tokens))
                pc += 1  # Instrucción normal

        result = []
        i = 0
        for l,pc_val, tokens in token_lines:
            try:
                #CHECK SYNTAX
                kinds = [k for k,_ in tokens]
                if "UNKOWN" in kinds:
                    raise RuntimeError("Bad instruction formation.")
                result.append(self.assemble_instruction(tokens, pc_val))
                i += 1
            except Exception as e:
                print("\nERROR:", e)
                print("AT LINE:", i, ",WITH:", extract[i])
                print("FAILURE.")
                quit()
        return result, extract



#
# main entrypoint, reads asm and writes to file
#
if __name__ == "__main__":
    print("ARMv7 - Simple assembler. (Arch - CS2201) - 2025 - v2.0")
    if len(sys.argv) < 2:
        print("Execute as: python asm.py <input file> [<output file>]")
        sys.exit(1)

    input_file = sys.argv[1]
    name_file = input_file.split("/")[-1].split(".")[0]
    output_file = f"{name_file}.dat"

    assembler = ARM_Assembler()
    with open(input_file, "r") as infile:
        source_code = infile.read()

    lines = source_code.strip().splitlines()
    lines = [l for l in lines if l != ""]
    instrs, extract = assembler.assemble_program(source_code)

    print("\n== Instructions ==")
    for i, instr in enumerate(instrs):
        text = extract[i].lstrip().ljust(18)
        print(f"{i:02d} {text} : 0x{instr:08X}")

    with open(output_file, "w") as f:
        for i in range(len(instrs)):
            f.write(f"{instrs[i]:08X}    // {extract[i]}\n")

    print(f"\nSUCCESS: Hex memory written to {output_file}")

    user_input = input("\n== Do you want to write directly to\nyour Vivado project? (y/n): ").strip().lower()
    if user_input == "y":
        # vivado_name_project = input("Write your Vivado project HEAD name: ").strip()
        vivado_name_project = "project_multicycle"  # Default project name

        import os
        home_dir = os.path.expanduser("~").replace("\\", "/")
        vivado_path = f"{vivado_name_project}/{vivado_name_project}.srcs/sim_1/imports/src"
        complete_vivado_path = vivado_path + "/memfile.dat"
        
        get = os.path.exists(complete_vivado_path)
        if not get:
            print(f"\nmemfile.dat not found in your project.")
            sys.exit(1)

        with open(complete_vivado_path, "w") as f:
            for i in range(len(instrs)):
                f.write(f"{instrs[i]:08X} // {extract[i]}\n")

        print(f"\nSUCCESS: Hex memory written to {complete_vivado_path}")