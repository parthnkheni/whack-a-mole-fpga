module two_digit_7seg(
    input clk_1k,
    input rst_n,
    input [7:0] score,
    output reg [6:0] seg,
    output reg [1:0] an
);

    reg active_digit;
    wire [3:0] ones = score[3:0];
    wire [3:0] tens = score[7:4];

    wire [6:0] seg_ones;
    wire [6:0] seg_tens;

    seven_seg_decoder D1 (.digit(ones), .segs(seg_ones));
    seven_seg_decoder D2 (.digit(tens), .segs(seg_tens));

    // Initialize and toggle active_digit on clock edge
    always @(posedge clk_1k or negedge rst_n) begin
        if (!rst_n) begin
            active_digit <= 1'b0;
        end else begin
            active_digit <= ~active_digit;
        end
    end

    // Combinational logic for segment and anode selection
    // an is active low: an[0]=0 selects digit 0 (ones), an[1]=0 selects digit 1 (tens)
    always @(*) begin
        if (active_digit == 1'b0) begin
            an  = 2'b10;  // an[0]=0, select ones digit
            seg = seg_ones;
        end else begin
            an  = 2'b01;  // an[1]=0, select tens digit
            seg = seg_tens;
        end
    end

endmodule