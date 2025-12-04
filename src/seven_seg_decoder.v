module seven_seg_decoder(
    input  [3:0] digit,
    output reg [6:0] segs
);

    always @(*) begin
        case (digit)
            4'd0: segs = 7'b1000000;
            4'd1: segs = 7'b1111001;
            4'd2: segs = 7'b0100100;
            4'd3: segs = 7'b0110000;
            4'd4: segs = 7'b0011001;
            4'd5: segs = 7'b0010010;
            4'd6: segs = 7'b0000010;
            4'd7: segs = 7'b1111000;
            4'd8: segs = 7'b0000000;
            4'd9: segs = 7'b0010000;
            default: segs = 7'b1111111;
        endcase
    end

endmodule