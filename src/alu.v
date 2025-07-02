module alu (
    input [31:0] a, b,
    input [2:0] ALUControl,
    output reg [31:0] Result,
    output reg [31:0] Result2,//el resultado de la mitad menos significativa del mul de 64bits
    output wire [3:0] ALUFlags
);
  
    wire N, _Z, C, V;
    wire [31:0] condinvb;
    wire [32:0] sum;
    reg [64:0] mul; //variable que almacena la multiplicacion de 64bits
    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum = a + condinvb + ALUControl[0];

    always @(*)
        casex (ALUControl[2:0])
            3'b00?: Result = sum;
            3'b010: Result = a & b;
            3'b011: Result = a | b;
            3'b100: Result = a * b;//MUL
            3'b101: //UMULL
            begin
                mul = a * b;
                Result = mul[31:0];
                Result2 = mul[63:32];          
            end
            3'b110: //SMULL
            begin
                mul = $signed(a) * $signed(b);
                Result = mul[31:0];
                Result2 = mul[63:32]; 
            end
            3'b111: Result = a / b;  //DIV
            default: Result2 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        endcase
  
    assign N = Result[31];
    assign _Z = (Result == 32'b0);
    assign C = (ALUControl[1]==1'b0) &              // es operaci�n aritm�tica
                sum[32];                            // tiene carry out
    assign V = (ALUControl[1]==1'b0) &              // es operaci�n aritm�tica
                ~(a[31] ^ b[31] ^ ALUControl[0]) &  // ambos operandos tienen el mismo signo
                (a[31] ^ sum[31]);                  // el resultado tiene signo diferente

    assign ALUFlags = {N, _Z, C, V};

endmodule