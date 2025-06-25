module testbench;
    reg clk;
    reg reset;
    wire [31:0] Result;
    wire [31:0] WriteData;
    wire [31:0] Adr;
    wire MemWrite;
    wire [31:0] PC;
    wire [31:0] Instr;
    wire [31:0] ReadData;
    wire [3:0] state;

    top dut(
        .clk(clk),
        .reset(reset),
        .Result(Result),
        .WriteData(WriteData),
        .Adr(Adr),
        .MemWrite(MemWrite),
        .PC(PC),
        .Instr(Instr),
        .ReadData(ReadData),
        .state(state)
    );

    initial begin
        reset <= 1; #(22) ;
        reset <= 0;
    end
    always begin
        clk <= 1; #(5) ;
        clk <= 0; #(5) ;
    end
    // always @(negedge clk)
    //     if (MemWrite)
    //         if ((Adr === 100) & (WriteData === 7)) begin
    //             $display("Simulation succeeded");
    //             $stop;
    //         end
    //         else if (Adr !== 96) begin
    //             $display("Simulation failed");
    //             $stop;
    //         end
            
    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars;
    end
endmodule
