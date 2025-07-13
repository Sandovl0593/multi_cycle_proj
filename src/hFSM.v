module hFSM(
    input wire clk,
    input wire reset,
    input [15:0] data,      // value
    output reg [3:0] digit, // from 16bits -> nibble i ∈ 3-0
    output reg [3:0] anode  // anode i
);
    reg [1:0] state = 0;

    // state register
    always @(posedge clk or posedge reset) begin
        if (reset) state <= 0; // reset to initial state
        else   state <= state + 1;
    end

    always @(*)
        case (state)
            2'b00: begin
                digit = data[15:12]; // first digit
                anode = 4'b0111;  // AN3
            end
            2'b01: begin
                digit = data[11:8]; // second digit
                anode = 4'b1011;  // AN2
            end
            2'b10: begin
                digit = data[7:4]; // third digit
                anode = 4'b1101;  // AN1
            end
            2'b11: begin
                digit = data[3:0]; // fourth digit
                anode = 4'b1110;  // AN0
            end
        default: begin
                digit = 4'b0000;
                anode = 4'b1111;
            end 
        endcase

endmodule