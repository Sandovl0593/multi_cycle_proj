module regfile (
    input wire clk,
    input wire we3,
    input wire [3:0] ra1,
    input wire [3:0] ra2,
    input wire [3:0] wa3,       // Rd
    input wire [31:0] wd3,      // Write data
    input wire [31:0] r15,      // PC + 8
    output wire [31:0] rd1,
    output wire [31:0] rd2
);
    reg [31:0] rf [14:0];
    
    // En posedge, se escribe el Rd
    always @(posedge clk)
        if (we3)
            rf[wa3] <= wd3;
    // En lectura, se asigna el valor de Rd1 y Rd2
    assign rd1 = (ra1 == 4'b1111 ? r15 : rf[ra1]);
    assign rd2 = (ra2 == 4'b1111 ? r15 : rf[ra2]);
endmodule
