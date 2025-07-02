module condlogic (
    input wire clk,
    input wire reset,
    input wire [3:0] Cond,
    input wire [3:0] ALUFlags,
    
    // From [ decode ] -/->
    input wire [1:0] FlagW,
    input wire PCS,
    input wire NextPC,
    input wire RegW,
    input wire MemW,

    output wire PCWrite,        // -> update PC?
    output wire RegWrite,       // -> load en registro?
    output wire MemWrite        // -> write en memoria?
);
    
    wire [1:0] FlagWrite;
    wire [3:0] Flags;
    wire CondEx, CondExNextInstr;
    
    // Registros de flags
    flopenr #(2) flagreg1(
        .clk(clk),
        .reset(reset),
        .en(FlagWrite[1]),
        .d(ALUFlags[3:2]),
        .q(Flags[3:2])
    );
    flopenr #(2) flagreg0( 
        .clk(clk),
        .reset(reset),
        .en(FlagWrite[0]),
        .d(ALUFlags[1:0]),
        .q(Flags[1:0])
    );

    // Evalua si la condición se cumple
    condcheck cc(
        .Cond(Cond), 
        .Flags(Flags), 
        .CondEx(CondEx)
    );

    // Registro de condicion
    flopr #(1) condreg(
        .clk(clk), 
        .reset(reset), 
        .d(CondEx), 
        .q(CondExNextInstr)
    );

    assign FlagWrite = FlagW & {2{CondEx}};             // Set Flags si cumple la condición
    assign RegWrite = RegW & CondExNextInstr;
    assign MemWrite = MemW & CondExNextInstr;
    assign PCWrite = (PCS & CondExNextInstr) | NextPC;

endmodule
