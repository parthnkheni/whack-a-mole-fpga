module scan_counter(
    input  wire clk_scan,
    input  wire rst_n,
    output reg  [1:0] sel
);
    always @(posedge clk_scan or negedge rst_n) begin
        if (!rst_n) begin
            sel <= 2'd0;
        end else begin
            sel <= sel + 2'd1;
        end
    end
endmodule
