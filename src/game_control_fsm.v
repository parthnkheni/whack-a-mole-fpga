module game_control_fsm(
    input  wire        clk,
    input  wire        rst_n,

    // These are expected to be ONE-CYCLE PULSES (from button_io)
    input  wire        btn_start,             // start / reset game
    input  wire        btn_clear_score,       // clear score (optional feature)
    input  wire        btn_difficulty_pulse,  // cycle difficulty
    input  wire [1:0]  difficulty_level_input,

    // Timers and score from other modules
    input  wire [5:0]  countdown_sec,         // seconds since countdown started
    input  wire [5:0]  game_time_sec,         // seconds since game started
    input  wire [7:0]  score,                 // current score

    // Control signals to submodules
    output reg         enable_countdown,
    output reg         clear_countdown,
    output reg         enable_game_timer,
    output reg         clear_game_timer,
    output reg         enable_score,
    output reg         clear_score,
    output reg         enable_mole_ctrl,
    output reg [1:0]   difficulty_level,

    // Value to show on 7-seg (you decide in top how many digits)
    output reg [7:0]   display_value
);

    // ---------------------------------------------------------
    // State encoding
    // ---------------------------------------------------------
    localparam [1:0] STATE_IDLE      = 2'b00;
    localparam [1:0] STATE_COUNTDOWN = 2'b01;
    localparam [1:0] STATE_PLAYING   = 2'b10;
    localparam [1:0] STATE_GAME_OVER = 2'b11;

    localparam [5:0] COUNTDOWN_MAX = 6'd5;    // 5-second countdown
    localparam [5:0] GAME_TIME_MAX = 6'd30;   // 30-second game

    reg [1:0] state, next_state;
    reg [1:0] difficulty_reg;
    reg [1:0] prev_state;  // Track previous state to detect transitions

    // ---------------------------------------------------------
    // State register + difficulty register
    // ---------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= STATE_IDLE;
            prev_state     <= STATE_IDLE;
            difficulty_reg <= 2'b00;
        end else begin
            prev_state <= state;  // Save current state before update
            state <= next_state;

            // Only allow difficulty changes in IDLE or GAME_OVER
            if ((state == STATE_IDLE || state == STATE_GAME_OVER) &&
                btn_difficulty_pulse) begin
                difficulty_reg <= difficulty_level_input;
            end
        end
    end

    // ---------------------------------------------------------
    // Next-state logic
    // ---------------------------------------------------------
    always @(*) begin
        next_state = state;

        case (state)
            // ---------------------------------------------
            // IDLE: wait for start button
            // ---------------------------------------------
            STATE_IDLE: begin
                if (btn_start)
                    next_state = STATE_COUNTDOWN;
            end

            // ---------------------------------------------
            // COUNTDOWN: show 5 -> 1, then start playing
            // ---------------------------------------------
            STATE_COUNTDOWN: begin
                if (countdown_sec >= COUNTDOWN_MAX)
                    next_state = STATE_PLAYING;
                else if (btn_start)
                    // pressing start again during countdown restarts countdown
                    next_state = STATE_COUNTDOWN;
            end

            // ---------------------------------------------
            // PLAYING: run for GAME_TIME_MAX seconds
            // ---------------------------------------------
            STATE_PLAYING: begin
                if (game_time_sec >= GAME_TIME_MAX)
                    next_state = STATE_GAME_OVER;
                else if (btn_start)
                    // restart game: go back to countdown
                    next_state = STATE_COUNTDOWN;
            end

            // ---------------------------------------------
            // GAME_OVER: show final score, wait for restart
            // ---------------------------------------------
            STATE_GAME_OVER: begin
                if (btn_start)
                    next_state = STATE_COUNTDOWN;
            end

            default: begin
                next_state = STATE_IDLE;
            end
        endcase
    end

    // ---------------------------------------------------------
    // Output logic (registered)
    // ---------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Global reset: safe defaults
            enable_countdown   <= 1'b0;
            clear_countdown    <= 1'b1;
            enable_game_timer  <= 1'b0;
            clear_game_timer   <= 1'b1;
            enable_score       <= 1'b0;
            clear_score        <= 1'b1;
            enable_mole_ctrl   <= 1'b0;

            difficulty_level   <= 2'b00;
            display_value      <= 8'd0;
        end else begin
            // Default each cycle
            enable_countdown   <= 1'b0;
            enable_game_timer  <= 1'b0;
            enable_score       <= 1'b0;
            enable_mole_ctrl   <= 1'b0;

            clear_countdown    <= 1'b0;
            clear_game_timer   <= 1'b0;
            clear_score        <= 1'b0;

            difficulty_level   <= difficulty_reg;
            display_value      <= 8'd0;

            case (state)
                // -----------------------------------------
                // IDLE: everything cleared, display 0
                // -----------------------------------------
                STATE_IDLE: begin
                    clear_countdown  <= 1'b1;
                    clear_game_timer <= 1'b1;
                    clear_score      <= 1'b1;

                    display_value    <= 8'd0;

                    // clear-score button here is basically redundant,
                    // but we keep for safety/consistency.
                    if (btn_clear_score) begin
                        clear_score      <= 1'b1;
                        clear_game_timer <= 1'b1;
                    end
                end

                // -----------------------------------------
                // COUNTDOWN: enable countdown, show remaining time
                // -----------------------------------------
                STATE_COUNTDOWN: begin
                    // Clear countdown when first entering COUNTDOWN state
                    // (transitioning from IDLE or GAME_OVER)
                    if (prev_state != STATE_COUNTDOWN) begin
                        clear_countdown <= 1'b1;
                    end
                    
                    enable_countdown  <= 1'b1;
                    // make sure game timer & score are reset before play
                    clear_game_timer  <= 1'b1;
                    clear_score       <= 1'b1;

                    // Display countdown: 5, 4, 3, 2, 1
                    // countdown_sec starts at 0, so we show (5-0)=5, then (5-1)=4, etc.
                    // When countdown_sec >= COUNTDOWN_MAX, we're transitioning to PLAYING
                    if (countdown_sec < COUNTDOWN_MAX) begin
                        // Convert to BCD format: [7:4] = tens, [3:0] = ones
                        // COUNTDOWN_MAX - countdown_sec gives value 5, 4, 3, 2, 1
                        // Since all values are < 10, tens = 0, ones = value
                        display_value <= {4'd0, (COUNTDOWN_MAX - countdown_sec)};
                    end else begin
                        display_value <= 8'd0;
                    end

                    if (btn_clear_score) begin
                        clear_score      <= 1'b1;
                        clear_game_timer <= 1'b1;
                    end

                    if (btn_start) begin
                        // pressing start during countdown: restart countdown
                        clear_countdown <= 1'b1;
                    end
                end

                // -----------------------------------------
                // PLAYING: enable game timer, scoring and mole control
                // -----------------------------------------
                STATE_PLAYING: begin
                    enable_game_timer <= 1'b1;
                    enable_score      <= 1'b1;
                    enable_mole_ctrl  <= 1'b1;

                    display_value     <= score;

                    // clear-score button: reset score + timer
                    if (btn_clear_score) begin
                        clear_score      <= 1'b1;
                        clear_game_timer <= 1'b1;
                    end

                    // start button: full reset for a new round
                    if (btn_start) begin
                        clear_countdown  <= 1'b1;
                        clear_game_timer <= 1'b1;
                        clear_score      <= 1'b1;
                    end
                end

                // -----------------------------------------
                // GAME_OVER: freeze game, show final score
                // -----------------------------------------
                STATE_GAME_OVER: begin
                    display_value <= score;

                    if (btn_clear_score) begin
                        clear_score      <= 1'b1;
                        clear_game_timer <= 1'b1;
                    end
                end

                default: begin
                    // stay with safe defaults
                end
            endcase
        end
    end

endmodule

