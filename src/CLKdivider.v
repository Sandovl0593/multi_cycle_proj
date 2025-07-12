module CLKdivider(
    input wire in_clk, 
    input wire reset_clk,
    output reg out_clk
);
    reg [17:0] counter = 0;
    localparam MAX_COUNT = 18'd208333;  // 100e6 / 480 -> 208333
    always @(posedge in_clk or posedge reset_clk) begin
        if(reset_clk) begin
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