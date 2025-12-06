module mole_led_ctrl(
    input  wire        clk_game,
    input  wire        rst_n,
    input  wire        enable,
    input  wire [2:0]  rand_idx,
    input  wire        timeout_pulse,
    input  wire [4:0]  btn_hit_pulse,
    output reg  [4:0]  mole_led,
    output reg         hit_pulse,
    output reg         start_timer
);

    reg [2:0] curr_idx;
    reg       has_mole;

    always @(posedge clk_game or negedge rst_n) begin
        if (!rst_n) begin
            mole_led    <= 5'b00000;
            curr_idx    <= 3'd0;
            hit_pulse   <= 1'b0;
            start_timer <= 1'b0;
            has_mole    <= 1'b0;
        end else begin
            hit_pulse   <= 1'b0;
            start_timer <= 1'b0;

            if (!enable) begin
                mole_led <= 5'b00000;
                has_mole <= 1'b0;
            end else begin
                if (!has_mole) begin
                    curr_idx    <= rand_idx;
                    mole_led    <= 5'b00001 << rand_idx;
                    has_mole    <= 1'b1;
                    start_timer <= 1'b1;
                end else begin
                    if (btn_hit_pulse[curr_idx]) begin
                        hit_pulse <= 1'b1;
                        mole_led  <= 5'b00000;
                        has_mole  <= 1'b0;
                    end else if (timeout_pulse) begin
                        mole_led <= 5'b00000;
                        has_mole <= 1'b0;
                    end
                end
            end
        end
    end

endmodule
