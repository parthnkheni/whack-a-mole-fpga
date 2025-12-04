module difficulty_timer #(
    parameter integer LED_TICKS_EASY = 10,
    parameter integer LED_TICKS_MED  = 7,
    parameter integer LED_TICKS_HARD = 4
)(
    input  wire       clk_game,
    input  wire       rst_n,
    input  wire       enable, //=1w when the game is running,=0 will disable the timer and no timeout output
    input  wire       start, // when a new mole is generated, a one cycle pulse will generate(which means this will resets the timer)
    input  wire [1:0] level,
    output reg        timeout_pulse, 
    output reg        active //we use this to determine whether there is currently a mole exist or not; =1 means one mole exist, timer is in progress
                             //=0 means no active mole and timer is not running.
                             
);

endmodule

