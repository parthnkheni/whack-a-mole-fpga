`timescale 1ns/1ps

module tb_seven_seg_decoder;

    reg [3:0] digit;
    wire [6:0] segs;

    seven_seg_decoder uut(
        .digit(digit),
        .segs(segs)
    );

    integer i;

    initial begin
        for (i = 0; i < 10; i = i + 1) begin
            digit = i;
            #10;
        end
        $finish;
    end

endmodule