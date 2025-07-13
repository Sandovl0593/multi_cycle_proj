module CLKdivider(
    input wire clk, 
    input wire reset,
    output reg out_clk
);
    reg [17:0] counter = 0;
    localparam MAX_COUNT = 18'd208333;  // 100e6 / 480 -> 208333
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            out_clk <= 0;
            counter <= 0;
        end
        else if (counter == MAX_COUNT - 1) begin
            counter <= 0;
            out_clk <= ~out_clk;
        end else begin
            counter <= counter + 1;
        end
    end

endmodule