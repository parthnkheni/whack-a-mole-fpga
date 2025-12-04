module two_digit_7seg(
    input clk_1k,
    input [7:0] score,
    output reg [6:0] seg,
    output reg [1:0] an
);

    reg active_digit = 0;
    wire [3:0] ones = score[3:0];
    wire [3:0] tens = score[7:4];

    wire [6:0] seg_ones;
    wire [6:0] seg_tens;

    seven_seg_decoder D1 (.digit(ones), .segs(seg_ones));
    seven_seg_decoder D2 (.digit(tens), .segs(seg_tens));

    always @(posedge clk_1k) begin
        active_digit <= ~active_digit;
    end

    always @(*) begin
        if (active_digit == 1'b0) begin
            an  = 2'b10;
            seg = seg_ones;
        end else begin
            an  = 2'b01;
            seg = seg_tens;
        end
    end

endmodule