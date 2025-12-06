`timescale 1ns/1ps

module tb_score_counter;

    reg clk = 0;
    reg reset = 0;
    reg hit = 0;
    reg enable_score = 1;
    wire [7:0] score;

    score_counter uut(
        .clk(clk),
        .reset(reset),
        .hit(hit),
        .enable_score(enable_score),
        .score(score)
    );

    always #5 clk = ~clk;

    initial begin
        reset = 1;
        #20 reset = 0;

        #20 hit = 1; #10 hit = 0;
        #20 hit = 1; #10 hit = 0;
        #20 hit = 1; #10 hit = 0;

        enable_score = 0;
        #20 hit = 1; #10 hit = 0;

        enable_score = 1;
        #20 hit = 1; #10 hit = 0;

        #100;
        $finish;
    end

endmodule