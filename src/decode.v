module decode (
    input wire clk,
    input wire reset,
    input wire [1:0] Op,
    input wire [5:0] Funct,
    input wire [3:0] Rd,
    input wire [3:0] IsMul, // para verificar que sea Multiply (1001)

    // FSM signals
    // -----/-> [ condlogic ]
    output wire PCS,
    output wire NextPC,
    output wire RegW,
    output wire MemW,
    //  ----/-> [ datapath ]
    output wire IRWrite,
    output wire AdrSrc,
    output wire [1:0] ResultSrc,
    output wire ALUSrcA,
    output wire [1:0] ALUSrcB,
    
    // ALU Decoder signals 
    output reg [1:0] FlagW,         // -> [ condlogic ]
    output reg [2:0] ALUControl,    // -> [ datapath ]
    // Op Decoder signals
    output wire opMul,              // MUL
    output wire [1:0] ImmSrc,       // -> [ datapath ]
    output wire [1:0] RegSrc,       // -> [ datapath ]
    output wire [3:0] state         // para ver los estados
);
    wire Branch;
    wire ALUOp;
    //en el multiply el op es 00, los bits Instr[25:24] son 00 e IsMul == 4'b1001:
    assign opMul = (Op==2'b00)&(Funct[5:4]==2'b00)&(IsMul == 4'b1001);

    // Main FSM
    mainfsm fsm(
        .clk(clk),
        .reset(reset),
        .Op(Op),
        .Funct(Funct),
        .IRWrite(IRWrite),
        .AdrSrc(AdrSrc),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .ResultSrc(ResultSrc),
        .NextPC(NextPC),
        .RegW(RegW),
        .MemW(MemW),
        .Branch(Branch),
        .ALUOp(ALUOp),
        .state(state)
        //.opMul(opMul) pronto
    );

    // Add code for the ALU Decoder and PC Logic.    
    // ALU Decoder
    always @(*)
        if (ALUOp) begin
            case(Funct[4:1])
                4'b0100: ALUControl = 3'b000; // ADD
                4'b0010: ALUControl = 3'b001; // SUB
                4'b0000:
                if (opMul)
                    ALUControl = 3'b100; // MUL
                else 
                    ALUControl = 3'b010; // AND
                4'b1100: ALUControl = 3'b011; // ORR
                default: ALUControl = 3'bxxx;
            endcase
            
            FlagW[1] = Funct[0]; 
            FlagW[0] = Funct[0] & (ALUControl == 3'b000 | ALUControl == 3'b001 | ALUControl == 3'b100);
        end else begin
            ALUControl = 3'b000; 
            FlagW = 2'b00; 
        end

    // PC Logic
     assign PCS = ((Rd == 4'b1111) & RegW) | Branch;

    // Add code for the Instruction Decoder (Instr Decoder) below.
    // Recall that the input to Instr Decoder is Op, and the outputs are

    // Instr Decoder
    assign ImmSrc = Op;
    assign RegSrc[0] = (Op == 2'b10); // read PC on Branch
    assign RegSrc[1] = (Op == 2'b01); // read Rd on STR 
endmodule
