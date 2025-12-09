module top (
    input        clk,
    input        reset,
    input        button_start,
    input        button_clear,
    input        button_difficulity,
    input        button_hammer,
    input  [4:0] swith,          // 5 switches under the 5 LEDs
    output [4:0] LED,
    output [6:0] seg,
    output [3:0] digit_select
);

    wire rst_n;
    assign rst_n = ~reset;

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
        .clk              (clk),
        .rst_n            (rst_n),
        .btn_start        (button_start),
        .btn_difficulty   (button_difficulity),
        .btn_clear        (button_clear),
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

    clock_divider u_clk_divider (
        .clk      (clk),
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
    // Hammer button (button_hammer) debounce
    // ---------------------------------------------------------
    wire hit_btn_level;
    wire hit_btn_pulse;

    debounce_one_pulse #(
        .CNTR_WIDTH(20)
    ) u_hit_button (
        .clk       (clk),
        .rst_n     (rst_n),
        .btn_raw   (button_hammer),
        .btn_level (hit_btn_level),
        .btn_pulse (hit_btn_pulse)
    );

    // ---------------------------------------------------------
    // Declare mole_led early (will be assigned later)
    // ---------------------------------------------------------
    wire [4:0] mole_led;

    // ---------------------------------------------------------
    // Hit vector: when hammer is pressed, check for switch state change
    // Each bit of swith corresponds to the LED above it.
    // Only score when: LED is on AND switch state changed (0->1 or 1->0) AND button is pressed
    // When LED turns on at a position, record the initial switch state.
    // If switch changes from initial state AND switch is currently 1, score is valid.
    // ---------------------------------------------------------
    reg [4:0] btn_hit_pulse_vec;
    reg [4:0] swith_prev;              // Previous state of switches for edge detection
    reg [4:0] switch_initial_state;    // Initial switch state when LED turns on
    reg [4:0] switch_changed;          // Switch state changed flag
    reg [4:0] mole_led_prev;           // Previous LED state to detect LED turning on

    // Track switch state changes and LED state
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            swith_prev          <= 5'b00000;
            switch_initial_state <= 5'b00000;
            switch_changed      <= 5'b00000;
            mole_led_prev       <= 5'b00000;
        end else begin
            swith_prev <= swith;
            mole_led_prev <= mole_led;
            
            // Detect when LED turns on at a position (rising edge of LED)
            // When LED turns on, record the initial switch state for that position
            // led_rising_edge = mole_led & ~mole_led_prev
            if ((mole_led & ~mole_led_prev) != 5'b00000) begin
                // LED just turned on at these positions, record initial switch state
                // For positions where LED just turned on, update initial state
                switch_initial_state <= (switch_initial_state & ~(mole_led & ~mole_led_prev)) | 
                                        (swith & (mole_led & ~mole_led_prev));
                // Clear changed flag for positions where LED just turned on
                switch_changed <= switch_changed & ~(mole_led & ~mole_led_prev);
            end
            
            // Detect switch state change: compare current state with initial state
            // Only detect changes when corresponding LED is on
            if (mole_led != 5'b00000) begin
                // Check if switch state differs from initial state (change detected)
                // state_diff = (mole_led & swith) ^ (mole_led & switch_initial_state)
                // Set changed flag if switch state is different from initial state
                switch_changed <= switch_changed | ((mole_led & swith) ^ (mole_led & switch_initial_state));
            end else begin
                // No LED is on, clear all changed flags
                switch_changed <= 5'b00000;
            end
            
            // Clear the changed flag when button is pressed (after it's been used)
            if (hit_btn_pulse) begin
                switch_changed <= 5'b00000;
            end
        end
    end

    // Generate hit pulse vector: only when switch state changed AND button is pressed AND switch is currently 1
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_hit_pulse_vec <= 5'b00000;
        end else begin
            if (hit_btn_pulse) begin
                // Check if switch state changed from initial state
                // Only set bits where: changed flag is set AND LED is on AND switch is currently 1
                btn_hit_pulse_vec <= switch_changed & mole_led & swith;
            end else begin
                btn_hit_pulse_vec <= 5'b00000;
            end
        end
    end

    // ---------------------------------------------------------
    // Mole + random + difficulty timer
    // ---------------------------------------------------------
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
        .clk_game      (clk),
        .rst_n         (rst_n),
        .enable        (enable_mole_ctrl),
        .level         (difficulty_level_fsm),  // level from FSM (controlled by state machine)
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
        .clk       (clk),
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

    game_control_fsm u_game_control_fsm (
        .clk                   (clk),
        .rst_n                 (rst_n),

        .btn_start             (start_pulse),
        .btn_clear_score       (clear_pulse),
        .btn_difficulty_pulse  (difficulty_pulse),
        .difficulty_level_input(difficulty_level_btn),

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
        .difficulty_level      (difficulty_level_fsm),

        .display_value         (display_value)
    );


    // ---------------------------------------------------------
    // 7-segment display: show display_value from FSM
    // ---------------------------------------------------------
    wire [1:0] an_digit_select2;

    two_digit_7seg u_two_digit_7seg (
        .clk_1k (clk_scan),
        .rst_n  (rst_n),
        .score  (display_value),
        .seg    (seg),
        .an     (an_digit_select2)
    );

    // Only lower 2 digits used (rightmost two); upper two off
    // an is active low, so 1'b1 means off
    assign digit_select = {2'b11, an_digit_select2};

endmodule
