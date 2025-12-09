module four_digit_7seg(
    input clk_1k,
    input rst_n,
    input [7:0] left_value,
    input [7:0] right_value,
    output reg [6:0] seg,
    output reg [3:0] an
);

    wire [1:0] digit_sel;
    
    wire [3:0] left_ones = left_value[3:0];
    wire [3:0] left_tens = left_value[7:4];
    wire [3:0] right_ones = right_value[3:0];
    wire [3:0] right_tens = right_value[7:4];

    wire [6:0] seg_left_tens;
    wire [6:0] seg_left_ones;
    wire [6:0] seg_right_tens;
    wire [6:0] seg_right_ones;

    seven_seg_decoder D1 (.digit(left_tens),  .segs(seg_left_tens));
    seven_seg_decoder D2 (.digit(left_ones),  .segs(seg_left_ones));
    seven_seg_decoder D3 (.digit(right_tens), .segs(seg_right_tens));
    seven_seg_decoder D4 (.digit(right_ones), .segs(seg_right_ones));

    // Use scan_counter to cycle through digits (0, 1, 2, 3)
    scan_counter u_scan_counter (
        .clk_scan (clk_1k),
        .rst_n    (rst_n),
        .sel      (digit_sel)
    );

    // Combinational logic for segment and anode selection
    // an is active low: an[0]=0 selects digit 0, an[1]=0 selects digit 1, etc.
    // digit_sel cycles 0, 1, 2, 3 for 4-digit display
    always @(*) begin
        case (digit_sel)
            2'b00: begin
                an  = 4'b1110;
                seg = seg_left_ones;
            end
            2'b01: begin
                an  = 4'b1101;
                seg = seg_left_tens;
            end
            2'b10: begin
                an  = 4'b1011;
                seg = seg_right_ones;
            end
            2'b11: begin
                an  = 4'b0111;
                seg = seg_right_tens;
            end
            default: begin
                an  = 4'b1111;  // All off
                seg = 7'b1111111;
            end
        endcase
    end

endmodule

