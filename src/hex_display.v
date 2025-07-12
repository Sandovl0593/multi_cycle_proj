module hex_display(
    input clk, 
    input reset, 
    input [15:0] data,
    input wire [3:0] state,
    output wire [3:0] anode,
    output wire [7:0] catode
);
    wire [3:0] digit;
    
    hFSM m(
        .clk(clk),
        .reset(reset),
        .data(data), // libera resultado
        .stateProg(state),
        .digit(digit),
        .anode(anode)
    );
    HexTo7Segment decoder (
        .digit(digit),
        .catode(catode)
    );
endmodule