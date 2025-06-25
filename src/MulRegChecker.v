module MulRegChecker(
    input wire [31:0] Instr,
    input wire opMul,
    output reg [3:0] Rn,
    output reg [3:0] Rm,
    output reg [3:0] Ra,      // para el mul esto es 0000
    output reg [3:0] Rd
);
    
    always @(*)
        if (opMul) begin
            Rn = Instr[3:0];
            Rm = Instr[11:8];
            Ra = Instr[15:12]; // MUL cable suelto
            Rd = Instr[19:16];
        end else begin
            Rn = Instr[19:16];
            Rm = Instr[3:0];
            Ra = 4'b0000;//cable suelto
            Rd = Instr[15:12];
            
        end   
    
endmodule
