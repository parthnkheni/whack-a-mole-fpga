module score_counter(
    input clk,
    input reset,
    input hit,
    input enable_score,
    output reg [7:0] score
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            score <= 8'd0;
        end else if (enable_score) begin
            if (hit) begin
                if (score < 8'd99)
                    score <= score + 1'b1;
            end
        end
    end

endmodule