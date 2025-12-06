`timescale 1ns/1ps

module tb_two_digit_7seg;

    reg clk_1k = 0;
    reg [7:0] score = 8'h23;
    wire [6:0] seg;
    wire [1:0] an;

    always #500 clk_1k = ~clk_1k;

    two_digit_7seg uut(
        .clk_1k(clk_1k),
        .score(score),
        .seg(seg),
        .an(an)
    );

    initial begin
        #5000;
        score = 8'h59;
        #5000;
        $finish;
    end

endmodule
