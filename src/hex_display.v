module hex_display(
    input wire clk, 
    input wire reset, 
    input [15:0] data,
    output wire [3:0] anode,
    output wire [7:0] catode
);
    wire [3:0] digit;
    wire scl_clk;
    
    CLKdivider sc(
        .clk(clk),
        .reset(reset),
        .out_clk(scl_clk)
    );
    hFSM m(
        .clk(scl_clk),
        .reset(reset),
        .data(data), // libera resultado
        .digit(digit),
        .anode(anode)
    );
    HexTo7Segment decoder (
        .digit(digit),
        .catode(catode)
    );
endmodule