module mainfsm (
    input wire clk,
    input wire reset,
    input wire [1:0] Op,
    input wire [5:0] Funct,
    output wire IRWrite,
    output wire AdrSrc,
    output wire ALUSrcA,
    output wire [1:0] ALUSrcB,
    output wire [1:0] ResultSrc,
    output wire NextPC,
    output wire RegW,
    output wire MemW,
    output wire Branch,
    output wire ALUOp,
    input wire opMul, // MUL
    output reg [3:0] state,        // para ver los estados
    output wire IsLongMul   //para tipo UMULL y SMULL
);
    reg [3:0] nextstate;
    reg [12:0] controls;
    
    // Nomenclauta de los estados
    localparam [3:0] FETCH = 0;
    localparam [3:0] DECODE = 1;
    localparam [3:0] MEMADR = 2;
    localparam [3:0] MEMRD = 3;
    localparam [3:0] MEMWB = 4;
    localparam [3:0] MEMWR = 5;
    localparam [3:0] EXECUTER = 6;
    localparam [3:0] EXECUTEI = 7;
    localparam [3:0] ALUWB = 8;
    localparam [3:0] BRANCH = 9;
    localparam [3:0] ALUWB2 = 10;
    localparam [3:0] UNKNOWN = 11;

    // state register
    always @(posedge clk or posedge reset)
        if (reset)
            state <= FETCH;
        else
            state <= nextstate;
    //
    // next state logic
    always @(*)
        casex (state)
            FETCH:  nextstate = DECODE; 
            DECODE: begin case (Op)  // dependiendo de Op
                2'b00: nextstate = (Funct[5]) ? EXECUTEI : EXECUTER; // R-type/I-type dependiendo de 'I'
                2'b01: nextstate = MEMADR;                           // Memoria
                2'b10: nextstate = BRANCH;                           // Branch
                default: nextstate = UNKNOWN;
            endcase end
            EXECUTER: nextstate = ALUWB;
            EXECUTEI: nextstate = ALUWB;
            MEMADR: nextstate = (Funct[0]) ? MEMRD : MEMWR;  // Load/Store dependiendo de 'L'
            MEMWR: nextstate = FETCH;                       // After Store
            MEMRD: nextstate = MEMWB;
            MEMWB: nextstate = FETCH;                       // After Load
            BRANCH: nextstate = FETCH;                      // After Branch
            ALUWB: nextstate = (Funct[4:1]!= 4'b0000 && opMul) ? ALUWB2 : FETCH;    // After ALU Write Back
            ALUWB2: nextstate = FETCH; // After ALU Write Back
            default: nextstate = FETCH;
        endcase

    // output logic
    always @(*)
        case (state)
        FETCH:      controls = 13'b100010_10_1_10_0_0;
            // NextPC= 1;     Branch= 0;   MemW= 0;     RegW= 0; IRWrite= 1; AdrSrc= 0
            // ResultSrc= 10; ALUSrcA= 1;  ALUSrcB= 10; ALUOp= 0; IsLongMul= 0;
        
        DECODE:     controls = 13'b000000_10_1_10_0_0;
            // NextPC= 0;     Branch= 0;   MemW= 0;     RegW= 0; IRWrite= 0; AdrSrc= 0
            // ResultSrc= 10; ALUSrcA= 1;  ALUSrcB= 10; ALUOp= 0; IsLongMul= 0;
        
        EXECUTER:   controls = 13'b000000_00_0_00_1_0;
            // NextPC= 0;     Branch= 0;   MemW= 0;     RegW= 0; IRWrite= 0; AdrSrc= 0
            // ResultSrc= 00; ALUSrcA= 0;  ALUSrcB= 00; ALUOp= 1; IsLongMul= 0;
        
        EXECUTEI:   controls = 13'b000000_00_0_01_1_0;
            // NextPC= 0;     Branch= 0;   MemW= 0;     RegW= 0; IRWrite= 0; AdrSrc= 0
            // ResultSrc= 00; ALUSrcA= 0;  ALUSrcB= 01; ALUOp= 1; IsLongMul= 0;
        
        MEMADR:     controls = 13'b000000_00_0_01_0_0; 
            // NextPC= 0;     Branch= 0;   MemW= 0;     RegW= 0; IRWrite= 0; AdrSrc= 0
            // ResultSrc= 00; ALUSrcA= 0;  ALUSrcB= 01; ALUOp= 0; IsLongMul= 0;
        
        MEMRD:      controls = 13'b000001_00_0_00_0_0;
            // NextPC= 0;     Branch= 0;   MemW= 0;     RegW= 0; IRWrite= 0; AdrSrc= 1
            // ResultSrc= 00; ALUSrcA= 0;  ALUSrcB= 00; ALUOp= 0; IsLongMul= 0;
        
        MEMWR:      controls = 13'b001001_00_0_00_0_0;
            // NextPC= 0;     Branch= 0;   MemW= 1;     RegW= 0; IRWrite= 0; AdrSrc= 1
            // ResultSrc= 00; ALUSrcA= 0;  ALUSrcB= 00; ALUOp= 0; IsLongMul= 0;
        
        MEMWB:      controls = 13'b000100_01_0_00_0_0;
            // NextPC= 0;     Branch= 0;   MemW= 0;     RegW= 1; IRWrite= 0; AdrSrc= 0
            // ResultSrc= 01; ALUSrcA= 0;  ALUSrcB= 00; ALUOp= 0; IsLongMul= 0;
        
        ALUWB:      controls = 13'b000100_00_0_00_0_0; 
            // NextPC= 0;     Branch= 0;   MemW= 0;     RegW= 1; IRWrite= 0; AdrSrc= 0
            // ResultSrc= 00; ALUSrcA= 0;  ALUSrcB= 00; ALUOp= 0; IsLongMul= 0;
        
        BRANCH:     controls = 13'b010000_10_0_01_0_0;
            // NextPC= 0;     Branch= 1;   MemW= 0;     RegW= 0; IRWrite= 0; AdrSrc= 0
            // ResultSrc= 10; ALUSrcA= 0;  ALUSrcB= 01; ALUOp= 0; IsLongMul= 0;
        ALUWB2:     controls = 13'b000100_00_0_00_0_1; 
            // NextPC= 0;     Branch= 0;   MemW= 0;     RegW= 1; IRWrite= 0; AdrSrc= 0
            // ResultSrc= 00; ALUSrcA= 0;  ALUSrcB= 00; ALUOp= 0; IsLongMul= 1;
        
        
        default:    controls = 13'bxxxxxx_xx_x_xx_x_x;
        endcase
    assign {NextPC, Branch, MemW, RegW, IRWrite, AdrSrc, ResultSrc, ALUSrcA, ALUSrcB, ALUOp, IsLongMul} = controls;
endmodule
