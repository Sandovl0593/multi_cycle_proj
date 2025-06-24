module alu (
    input [31:0] a, b,
    input [2:0] ALUControl,
    output reg [31:0] Result,
    output wire [3:0] ALUFlags
);
  
    wire N, _Z, C, V;
    wire [31:0] condinvb;
    wire [32:0] sum;
    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum = a + condinvb + ALUControl[0];

    always @(*)
        casex (ALUControl[2:0])
            3'b00?: Result = sum;
            3'b010: Result = a & b;
            3'b011: Result = a | b;
            3'b100: Result = a * b;//MUL
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