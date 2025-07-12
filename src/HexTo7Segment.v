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
            //                8'bABCDEFGP
            4'h0:    catode = 8'b11111100; // 0
            4'h1:    catode = 8'b01100000; // 1
            4'h2:    catode = 8'b11011010; // 2
            4'h3:    catode = 8'b11110010; // 3
            4'h4:    catode = 8'b01100110; // 4
            4'h5:    catode = 8'b10110110; // 5
            4'h6:    catode = 8'b10111110; // 6
            4'h7:    catode = 8'b11100000; // 7
            4'h8:    catode = 8'b11111110; // 8
            4'h9:    catode = 8'b11110110; // 9
            4'hA:    catode = 8'b11101110; // A
            4'hB:    catode = 8'b00111110; // B
            4'hC:    catode = 8'b10011100; // C
            4'hD:    catode = 8'b01111010; // D
            4'hE:    catode = 8'b10011110; // E
            4'hF:    catode = 8'b10001110; // F
            default: catode = 8'b00000000; // Default case (off)
        endcase
        // Display logica negada
        catode = ~catode;
    end

endmodule