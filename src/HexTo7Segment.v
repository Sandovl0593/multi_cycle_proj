module HexTo7Segment (
    input [3:0] digit,       // nibble (hex digit)
    output reg [7:0] catode
);
    //  -     -> catode    A      -> catode[7]
    // | |    -> catodes F,  B    -> catode[2], catode[6]
    //  -     -> catode    G      -> catode[1]
    // | |    -> catodes E,  C    -> catode[3], catode[5]
    //  -  .  -> catodes   D,   P -> catode[4], catode[0]
    
    // A nibble -> 7-segment display Hexadecimal digit
    always @(*) begin
        case (digit)
            //                8'bA_B_C_D_E_F_G_P
            4'h0:    catode = 8'b1_1_1_1_1_1_0_0; // 0
            4'h1:    catode = 8'b0_1_1_0_0_0_0_0; // 1
            4'h2:    catode = 8'b1_1_0_1_1_0_1_0; // 2
            4'h3:    catode = 8'b1_1_1_1_0_0_1_0; // 3
            4'h4:    catode = 8'b0_1_1_0_0_1_1_0; // 4
            4'h5:    catode = 8'b1_0_1_1_0_1_1_0; // 5
            4'h6:    catode = 8'b1_0_1_1_1_1_1_0; // 6
            4'h7:    catode = 8'b1_1_1_0_0_0_0_0; // 7
            4'h8:    catode = 8'b1_1_1_1_1_1_1_0; // 8
            4'h9:    catode = 8'b1_1_1_1_0_1_1_0; // 9
            4'hA:    catode = 8'b1_1_1_0_1_1_1_0; // A
            4'hB:    catode = 8'b0_0_1_1_1_1_1_0; // B
            4'hC:    catode = 8'b1_0_0_1_1_1_0_0; // C
            4'hD:    catode = 8'b0_1_1_1_1_0_1_0; // D
            4'hE:    catode = 8'b1_0_0_1_1_1_1_0; // E
            4'hF:    catode = 8'b1_0_0_0_1_1_1_0; // F
            default: catode = 8'b0_0_0_0_0_0_0_0; // Default case (off)
        endcase
        // Display logica negada
        catode = ~catode;
    end

endmodule