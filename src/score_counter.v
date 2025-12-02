module score_counter #(
    parameter WIDTH = 8,
    parameter MAX_SCORE = 99
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire             enable,
    input  wire             clear,
    input  wire             hit_pulse,
    output reg  [WIDTH-1:0] score
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            score <= {WIDTH{1'b0}};
        end else begin
            if (clear) begin
                score <= {WIDTH{1'b0}};
            end else if (enable && hit_pulse) begin
                if (score < MAX_SCORE[WIDTH-1:0])
                    score <= score + {{(WIDTH-1){1'b0}},1'b1};
            end
        end
    end

endmodule
