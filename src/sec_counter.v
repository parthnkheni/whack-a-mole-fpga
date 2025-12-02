module sec_counter(
    input  wire clk_1hz,
    input  wire rst_n,
    input  wire enable,
    input  wire clear,
    output reg  [5:0] sec
);

    always @(posedge clk_1hz or negedge rst_n) begin
        if (!rst_n) begin
            sec <= 6'd0;
        end else begin
            if (clear) begin
                sec <= 6'd0;
            end else if (enable) begin
                sec <= sec + 6'd1;
            end
        end
    end

endmodule
