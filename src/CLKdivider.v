module CLKdivider(
    input in_clk, 
    input reset_clk,
    //input stop, // para detener el reloj
    output reg out_clk
);
    reg [22:0] counter = 1;
    always @(posedge in_clk or posedge reset_clk) begin
        if(reset_clk) out_clk <= 0;
        else begin
            counter <= counter + 1;
            if (counter == 0) out_clk <= ~out_clk;
        end
    end
endmodule