module regfile (
    input wire clk,
    input wire we3,
    input wire we4,             //IsLongMul entrará a condicionar el SMULL, UMULL
    input wire [3:0] ra1,
    input wire [3:0] ra2,
    input wire [3:0] wa3,       // Rd
    input wire [3:0] wa4,       // Ra funcionará para el caso de SMULL, UMULL
    input wire [31:0] wd3,      // Write data
    input wire [31:0] r15,      // PC + 8
    output wire [31:0] rd1,
    output wire [31:0] rd2,
    output wire [15:0] rdisplay    // display a value on visualizer (basys3)
);
    reg [31:0] rf [14:0];
    
    // En posedge, se escribe el Rd
    always @(posedge clk)
        if (we3)
            if (we4) //IsLongMul
                rf[wa4] <= wd3; //o sea Ra tiene valor
            else
                rf[wa3] <= wd3;
    // En lectura, se asigna el valor de Rd1 y Rd2
    assign rd1 = (ra1 == 4'b1111 ? r15 : rf[ra1]);
    assign rd2 = (ra2 == 4'b1111 ? r15 : rf[ra2]);
    
    assign rdisplay = rf[4'b0100][15:0];
endmodule
