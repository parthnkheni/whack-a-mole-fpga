module clock_divider #(
    parameter integer DIV_1HZ   = 50_000_000,
    parameter integer DIV_SCAN = 50_000
)(
    input  wire clk,
    input  wire rst_n,
    output reg  clk_1hz,
    output reg  clk_scan
);

    reg [31:0] cnt_1hz;
    reg [31:0] cnt_scan;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_1hz  <= 32'd0;
            clk_1hz  <= 1'b0;
            cnt_scan <= 32'd0;
            clk_scan <= 1'b0;
        end else begin
            if (cnt_1hz == (DIV_1HZ / 2) - 1) begin
                cnt_1hz <= 32'd0;
                clk_1hz <= ~clk_1hz;
            end else begin
                cnt_1hz <= cnt_1hz + 32'd1;
            end

            if (cnt_scan == (DIV_SCAN / 2) - 1) begin
                cnt_scan <= 32'd0;
                clk_scan <= ~clk_scan;
            end else begin
                cnt_scan <= cnt_scan + 32'd1;
            end
        end
    end

endmodule
