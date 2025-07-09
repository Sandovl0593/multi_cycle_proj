module alu (
    input [31:0] a, b,
    input [3:0] ALUControl, //se extendió a 4 bits por el FP(add y mul)
    output reg [31:0] Result,
    output reg [31:0] Result2,//el resultado de la mitad menos significativa del mul de 64bits
    output wire [3:0] ALUFlags
);
  
    wire N, _Z, C, V;
    wire [31:0] condinvb;
    wire [32:0] sum;
    reg [64:0] mul; //variable que almacena la multiplicacion de 64bits
    
    // variables que almacenan los resultados de floating point
    wire [31:0] fpadd;
    wire [31:0] fpmul;
    
    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum = a + condinvb + ALUControl[0];
    
    FloatingPointAdd32(
    .a(a),
    .b(b),
    .Result(add32),
    .ALUFlags(flags)
    );
    
    FloatingPointAdd16(
    .a(a),
    .b(b),
    .Result(add16),
    .ALUFlags(flags)
    );
    
    FloatingPointMul32(
    .a(a),
    .b(b),
    .Result(mul32),
    .ALUFlags(flags)
    );
    
    FloatingPointMul16(
    .a(a),
    .b(b),
    .Result(mul16),
    .ALUFlags(flags)
    );

    always @(*)
        casex (ALUControl[3:0])//se extendió a 4 bits por el FP(add y mul)
            4'b000?: Result = sum;
            4'b0010: Result = a & b;
            4'b0011: Result = a | b;
            4'b0100: Result = a * b;//MUL
            4'b0101: //UMULL
            begin
                mul = a * b;
                Result = mul[31:0];
                Result2 = mul[63:32];          
            end
            4'b0110: //SMULL
            begin
                mul = $signed(a) * $signed(b);
                Result = mul[31:0];
                Result2 = mul[63:32]; 
            end
            4'b0111: Result = a / b;     //DIV
            4'b1000: Result = fpadd;    //FPADD32
            4'b1001: Result = fpadd;    //FPADD16
            4'b1010: Result = fpmul;    //FPMUL32
            4'b1011: Result = fpmul;    //FPMUL16
            4'b1100: Result = b;        //MOV
            default: Result2 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        endcase
  
    assign N = Result[31];
    assign _Z = (Result == 32'b0);
    assign C = (ALUControl[1]==1'b0) &              // es operación aritmética
                sum[32];                            // tiene carry out
    assign V = (ALUControl[1]==1'b0) &              // es operación aritmética
                ~(a[31] ^ b[31] ^ ALUControl[0]) &  // ambos operandos tienen el mismo signo
                (a[31] ^ sum[31]);                  // el resultado tiene signo diferente

    assign ALUFlags = {N, _Z, C, V};

endmodule