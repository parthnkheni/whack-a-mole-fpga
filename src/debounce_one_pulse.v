module debounce_one_pulse #(
    parameter CNTR_WIDTH = 20
)(
    input  clk,
    input  rst_n,
    input  btn_raw,
    output reg btn_level,
    output reg btn_pulse
);

    reg sync_0, sync_1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_0 <= 1'b0;
            sync_1 <= 1'b0;
        end else begin
            sync_0 <= btn_raw;
            sync_1 <= sync_0;
        end
    end

    reg [CNTR_WIDTH-1:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt       <= {CNTR_WIDTH{1'b0}};
            btn_level <= 1'b0;
        end else if (sync_1 == btn_level) begin
            cnt <= {CNTR_WIDTH{1'b0}};
        end else begin
            cnt <= cnt + 1'b1;
            if (&cnt) begin
                btn_level <= sync_1;
                cnt       <= {CNTR_WIDTH{1'b0}};
            end
        end
    end

    reg btn_level_d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_level_d <= 1'b0;
            btn_pulse   <= 1'b0;
        end else begin
            btn_level_d <= btn_level;
            btn_pulse   <= btn_level & ~btn_level_d;
        end
    end

endmodule

