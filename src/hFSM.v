module hFSM(
    input clk,
    input reset,
    input [15:0] data,      // value
    input wire [3:0] stateProg, // current state
    output reg [3:0] digit, // from 16bits -> nibble i ∈ 3-0
    output reg [3:0] anode  // anode i
);
    reg [15:0] dataInstr; // para ver la data resultante para MultiCycle

    localparam [1:0] D0 = 2'b00;
    localparam [1:0] D1 = 2'b01;
    localparam [1:0] D2 = 2'b10;
    localparam [1:0] D3 = 2'b11;

    reg [1:0] state, nextstate;

    // state register
    always @(posedge clk or posedge reset) begin
        if (reset) state <= D0; // reset to initial state
        else begin
            state <= nextstate;
        end
    end

    // next state logic
    always @(*) begin
        case (state)
            D0:      nextstate = D1;
            D1:      nextstate = D2;
            D2:      nextstate = D3;
            D3:      nextstate = D0;
            default: nextstate = D0;
        endcase
    end
    
    // Output logic (digit and anode)
    always @(*) begin
        dataInstr = (stateProg == 4'd6 || stateProg == 4'd7) ? data :
                        (stateProg == 4'd9) ? 16'hbbbb : dataInstr;
        case (state)
            D0: begin
                digit = dataInstr[15:12]; // first digit
                anode = 4'b1000;  // AN3
            end
            D1: begin
                digit = dataInstr[11:8]; // second digit
                anode = 4'b0100;  // AN2
            end
            D2: begin
                digit = dataInstr[7:4]; // third digit
                anode = 4'b0010;  // AN1
            end
            D3: begin
                digit = dataInstr[3:0]; // fourth digit
                anode = 4'b0001;  // AN0
            end
       default: begin
                digit = dataInstr[15:12]; // first digit
                anode = 4'b1000;  // AN3
            end
        endcase
        // anode active, inverted logic
        anode = ~anode;
    end

endmodule