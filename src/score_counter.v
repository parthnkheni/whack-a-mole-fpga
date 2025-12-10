module score_counter #(
    parameter WIDTH = 8,
    parameter MAX_SCORE = 99
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire             enable,
    input  wire             clear,
    input  wire             hit_pulse,
    output reg  [WIDTH-1:0] score  // BCD format: [7:4] = tens, [3:0] = ones
);

    // BCD counter: each 4-bit nibble represents a decimal digit (0-9)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            score <= {WIDTH{1'b0}};
        end else begin
            if (clear) begin
                score <= {WIDTH{1'b0}};
            end else if (enable && hit_pulse) begin
                // Check if we've reached max score (99 in BCD = 8'b10011001)
                if (score[7:4] < 4'd9 || (score[7:4] == 4'd9 && score[3:0] < 4'd9)) begin
                    // Increment ones digit
                    if (score[3:0] < 4'd9) begin
                        score[3:0] <= score[3:0] + 4'd1;
                    end else begin
                        // Ones digit overflow: reset to 0 and increment tens
                        score[3:0] <= 4'd0;
                        score[7:4] <= score[7:4] + 4'd1;
                    end
                end
                // If score >= 99, don't increment
            end
        end
    end

endmodule
