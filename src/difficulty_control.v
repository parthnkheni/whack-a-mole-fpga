module difficulty_timer #(
    parameter integer LED_TICKS_EASY = 10,
    parameter integer LED_TICKS_MED  = 7,
    parameter integer LED_TICKS_HARD = 4
)(
    input  wire       clk_game,
    input  wire       rst_n,
    input  wire       enable, //=1 when the game is running,=0 will disable the timer and no timeout output
    input  wire       start, // when a new mole is generated, a one cycle pulse will generate(which means this will resets the timer)
    input  wire [1:0] level,
    output reg        timeout_pulse, 
    output reg        active //we use this to determine whether there is currently a mole exist or not; =1 means one mole exist, timer is in progress
                             //=0 means no active mole and timer is not running.

);

    reg [31:0] tick_cnt;  // Changed to 32-bit to support large tick counts
    wire [31:0] tick_limit;

    assign tick_limit = (level == 2'd0) ? LED_TICKS_EASY :
                        (level == 2'd1) ? LED_TICKS_MED  :
                                          LED_TICKS_HARD;

    always @(posedge clk_game or negedge rst_n) begin
        if (!rst_n) begin
            tick_cnt      <= 32'd0;
            timeout_pulse <= 1'b0;
            active        <= 1'b0;
        end else begin
            timeout_pulse <= 1'b0;

            if (!enable) begin
                tick_cnt <= 32'd0;
                active   <= 1'b0;
            end else begin
                if (start) begin
                    // Start signal resets counter and activates timer
                    // This has priority over timeout check
                    tick_cnt <= 32'd0;
                    active   <= 1'b1;
                end else if (active) begin
                    // Timer is active - increment counter
                    tick_cnt <= tick_cnt + 32'd1;
                    if (tick_cnt >= tick_limit - 1) begin
                        // Timeout reached - generate pulse and deactivate
                        timeout_pulse <= 1'b1;
                        active        <= 1'b0;
                    end
                end
                // Note: If start and timeout_pulse occur in same cycle,
                // start takes priority and timer resets
            end
        end
    end

endmodule
