module mole_led_and_random #(
    parameter integer LED_TICKS_EASY = 10,
    parameter integer LED_TICKS_MED  = 7,
    parameter integer LED_TICKS_HARD = 4
)(
    input  wire        clk_game,
    input  wire        rst_n,
    input  wire        enable,
    input  wire [1:0]  level,
    input  wire [4:0]  btn_hit_pulse,
    output wire [4:0]  mole_led,
    output wire        hit_pulse,
    output wire        timeout_pulse
);

    wire [2:0] rand_num;
    wire       timer_start;
    wire       timer_active;

    random u_random(
        .clk        (clk_game),
        .rst_n      (rst_n),
        .enable     (enable),
        .random_num (rand_num)
    );

    mole_led_ctrl u_mole_led_ctrl(
        .clk_game      (clk_game),
        .rst_n         (rst_n),
        .enable        (enable),
        .rand_idx      (rand_num),
        .timeout_pulse (timeout_pulse),
        .btn_hit_pulse (btn_hit_pulse),
        .mole_led      (mole_led),
        .hit_pulse     (hit_pulse),
        .start_timer   (timer_start)
    );

    difficulty_timer #(
        .LED_TICKS_EASY (LED_TICKS_EASY),
        .LED_TICKS_MED  (LED_TICKS_MED),
        .LED_TICKS_HARD (LED_TICKS_HARD)
    ) u_difficulty_timer(
        .clk_game      (clk_game),
        .rst_n         (rst_n),
        .enable        (enable),
        .start         (timer_start),
        .level         (level),
        .timeout_pulse (timeout_pulse),
        .active        (timer_active)
    );

endmodule

