module alu (
    input [31:0] a, b,
    input [3:0] ALUControl, //se extendió a 4 bits por el FP(add y mul)
    output reg [31:0] Result,
    output reg [31:0] Result2,//el resultado de la mitad menos significativa del mul de 64bits
    output reg [3:0] ALUFlags
);
  
    wire N, _Z, C, V;
    wire [31:0] condinvb;
    wire [32:0] sum;
    reg [64:0] mul; //variable que almacena la multiplicacion de 64bits
    
    //outputs que pronto serán condicionados:
    wire [31:0] ResultAdd32, ResultAdd16, ResultMul32, ResultMul16;
    wire [3:0] ALUFlagsAdd32, ALUFlagsAdd16, ALUFlagsMul32, ALUFlagsMul16;
    
    
    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum = a + condinvb + ALUControl[0];
    
    /*FloatingPointAdd32 FPADD32(
    .a(a),
    .b(b),
    .add32(ResultAdd32),
    .flags(ALUFlagsAdd32)
    );
    
    FloatingPointAdd16 FPADD16(
    .a(a),
    .b(b),
    .add16(ResultAdd16),
    .flags(ALUFlagsAdd16)
    );
    FloatingPointMul32 FPMUL32(
    .a(a),
    .b(b),
    .mul32(ResultMul32),
    .flags(ALUFlagsMul32)
    );
    
    FloatingPointMul16 FPMUL16(
    .a(a),
    .b(b),
    .mul16(ResultMul16),
    .flags(ALUFlagsMul16)
    );*/

    always @(*)
        casex (ALUControl[3:0])//se extendió a 4 bits por el FP(add y mul)
            4'b000?: Result = sum;
            4'b0010: Result = a & b;
            4'b0011: Result = a | b;
            4'b0100: Result = a * b;//MUL
            4'b0101: //UMULL
            begin
                mul = a * b;
                Result2 = mul[31:0];
                Result = mul[63:32];          
            end
            4'b0110: //SMULL
            begin
                mul = $signed(a) * $signed(b);
                Result2 = mul[31:0];
                Result = mul[63:32]; 
            end
            4'b0111: Result = a / b;     //DIV
            4'b1000: Result = ResultAdd32;    //FPADD32
            4'b1001: Result = ResultAdd16;    //FPADD16
            //4'b1010: Result = ResultMul32;    //FPMUL32
            //4'b1011: Result = ResultMul16;    //FPMUL16
            4'b1100: Result = b;              //MOV
            default: Result2 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        endcase
  
    assign res2 = (ALUControl == 3'b110 | ALUControl == 3'b101); // es UMULL o SMULL

    assign N = Result[31];

    assign _Z = (Result == 32'b0 & (~res2 | (res2 & Result2 == 32'b0)));
    
    assign C = (ALUControl[1]==1'b0) &              // es operación aritmética
                sum[32];                            // tiene carry out
    assign V = (ALUControl[1]==1'b0) &              // es operación aritmética
                ~(a[31] ^ b[31] ^ ALUControl[0]) &  // ambos operandos tienen el mismo signo
                (a[31] ^ sum[31]);                  // el resultado tiene signo diferente
    
    always @(*) begin
        case (ALUControl)
            4'b1000: ALUFlags = ALUFlagsAdd32;     //FPADD32
            4'b1001: ALUFlags = ALUFlagsAdd16;     //FPADD16
            4'b1010: ALUFlags = ALUFlagsMul32;     //FPMUL32
            4'b1011: ALUFlags = ALUFlagsMul16;     //FPMUL16
            default: ALUFlags = {N, _Z, C, V};
        endcase
    end   
    //assign ALUFlags = {N, _Z, C, V};
endmodule