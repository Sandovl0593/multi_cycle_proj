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
    //input wire opMul, // MUL
    output reg [3:0] state        // para ver los estados
    
);
    reg [3:0] nextstate;
    reg [11:0] controls;

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
    localparam [3:0] UNKNOWN = 10;

    // state register
    always @(posedge clk or posedge reset)
        if (reset)
            state <= FETCH;
        else
            state <= nextstate;
    
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
            ALUWB: nextstate = FETCH;                       // After ALU Write Back
            default: nextstate = FETCH;
        endcase

    // output logic
    always @(*)
        case (state)
        FETCH:      controls = 12'b100010_10_1_10_0;
            // NextPC= 1;     Branch= 0;   MemW= 0;     RegW= 0; IRWrite= 1; AdrSrc= 0
            // ResultSrc= 10; ALUSrcA= 1;  ALUSrcB= 10; ALUOp= 0
        
        DECODE:     controls = 12'b000000_10_1_10_0;
            // NextPC= 0;     Branch= 0;   MemW= 0;     RegW= 0; IRWrite= 0; AdrSrc= 0
            // ResultSrc= 10; ALUSrcA= 1;  ALUSrcB= 10; ALUOp= 0
        
        EXECUTER:   controls = 12'b000000_00_0_00_1;
            // NextPC= 0;     Branch= 0;   MemW= 0;     RegW= 0; IRWrite= 0; AdrSrc= 0
            // ResultSrc= 00; ALUSrcA= 0;  ALUSrcB= 00; ALUOp= 1
        
        EXECUTEI:   controls = 12'b000000_00_0_01_1;
            // NextPC= 0;     Branch= 0;   MemW= 0;     RegW= 0; IRWrite= 0; AdrSrc= 0
            // ResultSrc= 00; ALUSrcA= 0;  ALUSrcB= 01; ALUOp= 1
        
        MEMADR:     controls = 12'b000000_00_0_01_0; 
            // NextPC= 0;     Branch= 0;   MemW= 0;     RegW= 0; IRWrite= 0; AdrSrc= 0
            // ResultSrc= 00; ALUSrcA= 0;  ALUSrcB= 01; ALUOp= 0
        
        MEMRD:      controls = 12'b000001_00_0_00_0;
            // NextPC= 0;     Branch= 0;   MemW= 0;     RegW= 0; IRWrite= 0; AdrSrc= 1
            // ResultSrc= 00; ALUSrcA= 0;  ALUSrcB= 00; ALUOp= 0
        
        MEMWR:      controls = 12'b001001_00_0_00_0;
            // NextPC= 0;     Branch= 0;   MemW= 1;     RegW= 0; IRWrite= 0; AdrSrc= 1
            // ResultSrc= 00; ALUSrcA= 0;  ALUSrcB= 00; ALUOp= 0
        
        MEMWB:      controls = 12'b000100_01_0_00_0;
            // NextPC= 0;     Branch= 0;   MemW= 0;     RegW= 1; IRWrite= 0; AdrSrc= 0
            // ResultSrc= 01; ALUSrcA= 0;  ALUSrcB= 00; ALUOp= 0
        
        ALUWB:      controls = 12'b000100_00_0_00_0; 
            // NextPC= 0;     Branch= 0;   MemW= 0;     RegW= 1; IRWrite= 0; AdrSrc= 0
            // ResultSrc= 00; ALUSrcA= 0;  ALUSrcB= 00; ALUOp= 0
        
        BRANCH:     controls = 12'b010000_10_0_01_0;
            // NextPC= 0;     Branch= 1;   MemW= 0;     RegW= 0; IRWrite= 0; AdrSrc= 0
            // ResultSrc= 10; ALUSrcA= 0;  ALUSrcB= 01; ALUOp= 0
        
        default:    controls = 12'bxxxxxx_xx_x_xx_x;
        endcase
    assign {NextPC, Branch, MemW, RegW, IRWrite, AdrSrc, ResultSrc, ALUSrcA, ALUSrcB, ALUOp} = controls;
endmodule
