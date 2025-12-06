module top (
    input        CLK100MHZ,
    input        BTNC,
    input        BTNU,
    input        BTNL,
    input        BTNR,
    input        BTND,
    input  [4:0] SW,          // 5 switches under the 5 LEDs
    output [4:0] LED,
    output [6:0] seg,
    output [3:0] an
);

    wire rst_n;
    assign rst_n = ~BTNC;

    // ---------------------------------------------------------
    // Button IO (start / difficulty / clear)
    // ---------------------------------------------------------
    wire start_pulse;
    wire difficulty_pulse;
    wire clear_pulse;
    wire [1:0] difficulty_level_btn;

    button_io #(
        .DEBOUNCE_CNTR_WIDTH(20),
        .NUM_LEVELS(3),
        .LEVEL_BITS(2)
    ) u_button_io (
        .clk              (CLK100MHZ),
        .rst_n            (rst_n),
        .btn_start        (BTNU),
        .btn_difficulty   (BTNR),
        .btn_clear        (BTNL),
        .start_pulse      (start_pulse),
        .difficulty_pulse (difficulty_pulse),
        .clear_pulse      (clear_pulse),
        .difficulty_level (difficulty_level_btn)
    );

    // ---------------------------------------------------------
    // Clock divider: 1 Hz and scan clock (~1 kHz)
    // ---------------------------------------------------------
    wire clk_1hz;
    wire clk_scan;

    clk_divider u_clk_divider (
        .clk      (CLK100MHZ),
        .rst_n    (rst_n),
        .clk_1hz  (clk_1hz),
        .clk_scan (clk_scan)
    );

    // ---------------------------------------------------------
    // Second counters: countdown and game timer
    // ---------------------------------------------------------
    wire [5:0] countdown_sec;
    wire [5:0] game_time_sec;

    wire enable_countdown;
    wire clear_countdown;
    wire enable_game_timer;
    wire clear_game_timer;

    sec_counter u_countdown (
        .clk_1hz (clk_1hz),
        .rst_n   (rst_n),
        .enable  (enable_countdown),
        .clear   (clear_countdown),
        .sec     (countdown_sec)
    );

    sec_counter u_game_timer (
        .clk_1hz (clk_1hz),
        .rst_n   (rst_n),
        .enable  (enable_game_timer),
        .clear   (clear_game_timer),
        .sec     (game_time_sec)
    );

    // ---------------------------------------------------------
    // Hammer button (BTND) debounce
    // ---------------------------------------------------------
    wire hit_btn_level;
    wire hit_btn_pulse;

    debounce_one_pulse #(
        .CNTR_WIDTH(20)
    ) u_hit_button (
        .clk       (CLK100MHZ),
        .rst_n     (rst_n),
        .btn_raw   (BTND),
        .btn_level (hit_btn_level),
        .btn_pulse (hit_btn_pulse)
    );

    // ---------------------------------------------------------
    // Hit vector: when hammer is pressed, sample SW[4:0]
    // Each bit of SW corresponds to the LED above it.
    // ---------------------------------------------------------
    reg [4:0] btn_hit_pulse_vec;

    always @(posedge CLK100MHZ or negedge rst_n) begin
        if (!rst_n) begin
            btn_hit_pulse_vec <= 5'b00000;
        end else begin
            if (hit_btn_pulse)
                btn_hit_pulse_vec <= SW;      // pulse on those switches when hammer is hit
            else
                btn_hit_pulse_vec <= 5'b00000;
        end
    end

    // ---------------------------------------------------------
    // Mole + random + difficulty timer
    // ---------------------------------------------------------
    wire [4:0] mole_led;
    wire       hit_pulse;
    wire       timeout_pulse;

    wire enable_mole_ctrl;
    wire enable_difficulty_timer;
    wire [1:0] difficulty_level_fsm;

    mole_led_and_random #(
        .LED_TICKS_EASY(300_000_000),  // ~3 s
        .LED_TICKS_MED (200_000_000),  // ~2 s
        .LED_TICKS_HARD(100_000_000)   // ~1 s
    ) u_mole_led_and_random (
        .clk_game      (CLK100MHZ),
        .rst_n         (rst_n),
        .enable        (enable_mole_ctrl),
        .level         (difficulty_level_btn),  // level from button_io
        .btn_hit_pulse (btn_hit_pulse_vec),
        .mole_led      (mole_led),
        .hit_pulse     (hit_pulse),
        .timeout_pulse (timeout_pulse)
    );

    assign LED = mole_led;

    // ---------------------------------------------------------
    // Score counter
    // ---------------------------------------------------------
    wire enable_score;
    wire clear_score;
    wire [7:0] score;

    score_counter #(
        .WIDTH(8),
        .MAX_SCORE(99)
    ) u_score_counter (
        .clk       (CLK100MHZ),
        .rst_n     (rst_n),
        .enable    (enable_score),
        .clear     (clear_score),
        .hit_pulse (hit_pulse),
        .score     (score)
    );

    // ---------------------------------------------------------
    // Game control FSM
    // ---------------------------------------------------------
    wire [7:0] display_value;
    wire       display_mode;
    wire [1:0] game_state;

    game_control_fsm u_game_control_fsm (
        .clk                   (CLK100MHZ),
        .clk_1hz               (clk_1hz),
        .rst_n                 (rst_n),

        .btn_reset             (start_pulse),
        .btn_reset_score       (clear_pulse),
        .btn_difficulty        (difficulty_level_btn),

        .timeout_pulse         (timeout_pulse),
        .hit_pulse             (hit_pulse),
        .countdown_sec         (countdown_sec),
        .game_time_sec         (game_time_sec),
        .score                 (score),

        .enable_countdown      (enable_countdown),
        .clear_countdown       (clear_countdown),
        .enable_game_timer     (enable_game_timer),
        .clear_game_timer      (clear_game_timer),
        .enable_score          (enable_score),
        .clear_score           (clear_score),
        .enable_mole_ctrl      (enable_mole_ctrl),
        .enable_difficulty_timer(enable_difficulty_timer),
        .difficulty_level      (difficulty_level_fsm),

        .display_value         (display_value),
        .display_mode          (display_mode),
        .game_state            (game_state)
    );

    // ---------------------------------------------------------
    // 7-segment display: show display_value from FSM
    // ---------------------------------------------------------
    wire [1:0] an2;

    two_digit_7seg u_two_digit_7seg (
        .clk_1k (clk_scan),
        .score  (display_value),
        .seg    (seg),
        .an     (an2)
    );

    // Only lower 2 digits used (rightmost two); upper two off
    assign an = {2'b11, an2};

endmodule
