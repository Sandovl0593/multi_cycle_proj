  MAIN: 
  SUB R1 , R15 , R15
  ADD R2 , R1 , #7
  ADDS R3 , R2 , #5
  MUL R11 , R2 , R3
  SUB R4 , R2 , #2
  AND R5 , R3 , R4
  ADDS R6 , R5 , #6
  BEQ GO
  SUB R7 , R6 , #10
  ANDS R7 , R7 , #1
  BEQ OPTN
  B END
  OPTN: 
  SUBS R8 , R1 , R4
  ANDLT R9 , R8 , #20
  GO:
  ADD R10 , R1 , #100
  STR R9 , [R0 , #40]
  LDR R6 , [R9 , #24]
  ADD R15 , R15 , R1
  SUBS R6 , R0 , #10
  B END
  ADD R12 , R0 , #99
  STR R12 , [R0 , #4]
  END: 
  ADD R0 , R0 , #1
  STR R6 , [R0 , #9]