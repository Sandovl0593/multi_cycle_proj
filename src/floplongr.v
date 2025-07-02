module floplongr(
    clk, reset, d, d2, mulEn, q
);
    input wire clk;
    input wire reset;
    input wire [31:0] d;
    input wire [31:0] d2;
    input wire mulEn;
    output reg [31:0] q;
    always @(posedge clk or posedge reset)
        if (reset)
            q <= 0;
        else if (mulEn)
            q <= d2;
        else
            q <= d;
endmodule
