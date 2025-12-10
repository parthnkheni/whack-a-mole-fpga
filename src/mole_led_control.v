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
                // When no mole exists, generate a new one using random index
                // This happens:
                // 1. Initially when game starts
                // 2. After a mole is hit
                // 3. After a timeout (immediately in the same cycle if timeout_pulse is high)
                if (!has_mole || timeout_pulse) begin
                    // Generate new mole:
                    // - When has_mole is false (initial, after hit, or after timeout)
                    // - Or immediately when timeout occurs (to avoid one cycle delay)
                    if (timeout_pulse) begin
                        // Timeout occurred - clear current and generate new immediately
                        curr_idx    <= rand_idx;              // Store new random index (0-4)
                        mole_led    <= 5'b00001 << rand_idx; // Set corresponding LED immediately
                        has_mole    <= 1'b1;                  // Mark that a mole exists
                        start_timer <= 1'b1;                  // Start difficulty timer
                    end else begin
                        // Normal case: no mole exists, generate new one
                        curr_idx    <= rand_idx;              // Store random index (0-4)
                        mole_led    <= 5'b00001 << rand_idx; // Set corresponding LED
                        has_mole    <= 1'b1;                  // Mark that a mole exists
                        start_timer <= 1'b1;                  // Start difficulty timer
                    end
                end else begin
                    // Mole exists - check for hit
                    if (btn_hit_pulse[curr_idx]) begin
                        // Player hit the mole - clear it and generate new one next cycle
                        hit_pulse <= 1'b1;
                        mole_led  <= 5'b00000;
                        has_mole  <= 1'b0;
                    end
                    // Note: timeout_pulse is handled in the if condition above
                end
            end
        end
    end

endmodule
