module two_digit_7seg(
    input clk_1k,
    input rst_n,
    input [7:0] score,
    output reg [6:0] seg,
    output reg [1:0] an
);

    wire [1:0] digit_sel;
    wire [3:0] ones = score[3:0];
    wire [3:0] tens = score[7:4];

    wire [6:0] seg_ones;
    wire [6:0] seg_tens;

    seven_seg_decoder D1 (.digit(ones), .segs(seg_ones));
    seven_seg_decoder D2 (.digit(tens), .segs(seg_tens));

    // Use scan_counter to cycle through digits
    scan_counter u_scan_counter (
        .clk_scan (clk_1k),
        .rst_n    (rst_n),
        .sel      (digit_sel)
    );

    // Combinational logic for segment and anode selection
    // an is active low: an[0]=0 selects digit 0 (ones), an[1]=0 selects digit 1 (tens)
    // digit_sel cycles 0, 1, 2, 3, but we only use 0 and 1 for 2-digit display
    always @(*) begin
        case (digit_sel[0])  // Only use LSB to select between 2 digits
            1'b0: begin
                an  = 2'b10;  // an[0]=0, select ones digit
                seg = seg_ones;
            end
            1'b1: begin
                an  = 2'b01;  // an[1]=0, select tens digit
                seg = seg_tens;
            end
            default: begin
                an  = 2'b11;  // Both off
                seg = 7'b1111111;
            end
        endcase
    end

endmodule