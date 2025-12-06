`timescale 1ns / 1ps

module game_control_fsm_tb;

    reg clk;
    reg clk_1hz;
    reg rst_n;
    
    reg btn_reset;
    reg btn_reset_score;
    reg [1:0] btn_difficulty;
    
    reg timeout_pulse;
    reg hit_pulse;
    reg [5:0] countdown_sec;
    reg [5:0] game_time_sec;
    reg [7:0] score;
    
    wire enable_countdown;
    wire clear_countdown;
    wire enable_game_timer;
    wire clear_game_timer;
    wire enable_score;
    wire clear_score;
    wire enable_mole_ctrl;
    wire enable_difficulty_timer;
    wire [1:0] difficulty_level;
    wire [7:0] display_value;
    wire display_mode;
    wire [1:0] game_state;
    
    game_control_fsm uut (
        .clk(clk),
        .clk_1hz(clk_1hz),
        .rst_n(rst_n),
        .btn_reset(btn_reset),
        .btn_reset_score(btn_reset_score),
        .btn_difficulty(btn_difficulty),
        .timeout_pulse(timeout_pulse),
        .hit_pulse(hit_pulse),
        .countdown_sec(countdown_sec),
        .game_time_sec(game_time_sec),
        .score(score),
        .enable_countdown(enable_countdown),
        .clear_countdown(clear_countdown),
        .enable_game_timer(enable_game_timer),
        .clear_game_timer(clear_game_timer),
        .enable_score(enable_score),
        .clear_score(clear_score),
        .enable_mole_ctrl(enable_mole_ctrl),
        .enable_difficulty_timer(enable_difficulty_timer),
        .difficulty_level(difficulty_level),
        .display_value(display_value),
        .display_mode(display_mode),
        .game_state(game_state)
    );
    
    parameter CLK_PERIOD = 20;
    parameter CLK_1HZ_PERIOD = 1000;
    
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    initial begin
        clk_1hz = 0;
        forever #(CLK_1HZ_PERIOD/2) clk_1hz = ~clk_1hz;
    end
    
    initial begin
        $dumpfile("game_control_fsm_tb.vcd");
        $dumpvars(0, game_control_fsm_tb);
        
        rst_n = 0;
        btn_reset = 0;
        btn_reset_score = 0;
        btn_difficulty = 2'b00;
        timeout_pulse = 0;
        hit_pulse = 0;
        countdown_sec = 6'd0;
        game_time_sec = 6'd0;
        score = 8'd0;
        
        #(CLK_PERIOD * 5);
        rst_n = 1;
        #(CLK_PERIOD * 2);
        
        $display("=== Test 1: Reset and Initial State ===");
        #(CLK_PERIOD * 2);
        if (game_state == 2'b00) $display("PASS: Initial state is IDLE");
        else $display("FAIL: Initial state is not IDLE");
        
        $display("\n=== Test 2: IDLE -> COUNTDOWN Transition ===");
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        btn_reset = 1;
        #(CLK_PERIOD * 3);
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        if (game_state == 2'b01) $display("PASS: State transitioned to COUNTDOWN");
        else $display("FAIL: State did not transition to COUNTDOWN");
        if (enable_countdown == 1'b1) $display("PASS: Countdown enabled");
        else $display("FAIL: Countdown not enabled");
        
        $display("\n=== Test 3: Countdown Display ===");
        countdown_sec = 6'd0;
        #(CLK_PERIOD * 2);
        if (display_value == 8'd5 && display_mode == 1'b0) 
            $display("PASS: Display shows countdown 5");
        else $display("FAIL: Display incorrect");
        
        countdown_sec = 6'd1;
        #(CLK_PERIOD * 2);
        if (display_value == 8'd4) 
            $display("PASS: Display shows countdown 4");
        else $display("FAIL: Display incorrect");
        
        countdown_sec = 6'd2;
        #(CLK_PERIOD * 2);
        if (display_value == 8'd3) 
            $display("PASS: Display shows countdown 3");
        else $display("FAIL: Display incorrect");
        
        countdown_sec = 6'd3;
        #(CLK_PERIOD * 2);
        if (display_value == 8'd2) 
            $display("PASS: Display shows countdown 2");
        else $display("FAIL: Display incorrect");
        
        countdown_sec = 6'd4;
        #(CLK_PERIOD * 2);
        if (display_value == 8'd1) 
            $display("PASS: Display shows countdown 1");
        else $display("FAIL: Display incorrect");
        
        $display("\n=== Test 4: COUNTDOWN -> PLAYING Transition ===");
        countdown_sec = 6'd5;
        #(CLK_PERIOD * 2);
        if (game_state == 2'b10) $display("PASS: State transitioned to PLAYING");
        else $display("FAIL: State did not transition to PLAYING");
        if (enable_game_timer == 1'b1 && enable_score == 1'b1 && enable_mole_ctrl == 1'b1) 
            $display("PASS: Game modules enabled");
        else $display("FAIL: Game modules not enabled");
        
        $display("\n=== Test 5: Playing State - Score Display ===");
        score = 8'd10;
        #(CLK_PERIOD * 2);
        if (display_value == 8'd10 && display_mode == 1'b1) 
            $display("PASS: Display shows score 10");
        else $display("FAIL: Display incorrect");
        
        score = 8'd25;
        #(CLK_PERIOD * 2);
        if (display_value == 8'd25) 
            $display("PASS: Display shows score 25");
        else $display("FAIL: Display incorrect");
        
        $display("\n=== Test 6: PLAYING -> GAME_OVER Transition ===");
        game_time_sec = 6'd30;
        #(CLK_PERIOD * 2);
        if (game_state == 2'b11) $display("PASS: State transitioned to GAME_OVER");
        else $display("FAIL: State did not transition to GAME_OVER");
        if (enable_game_timer == 1'b0 && enable_mole_ctrl == 1'b0) 
            $display("PASS: Game modules disabled");
        else $display("FAIL: Game modules not disabled");
        
        $display("\n=== Test 7: GAME_OVER -> COUNTDOWN (Reset Button) ===");
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        btn_reset = 1;
        #(CLK_PERIOD * 3);
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        if (game_state == 2'b01) $display("PASS: Reset button works");
        else $display("FAIL: Reset button does not work");
        
        $display("\n=== Test 8: Difficulty Selection ===");
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        btn_reset = 1;
        #(CLK_PERIOD * 3);
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        countdown_sec = 6'd5;
        #(CLK_PERIOD * 2);
        game_time_sec = 6'd30;
        #(CLK_PERIOD * 2);
        if (game_state == 2'b11) begin
            btn_difficulty = 2'b01;
            #(CLK_PERIOD * 2);
            if (difficulty_level == 2'b00) $display("PASS: Easy difficulty selected");
            else $display("FAIL: Easy difficulty not selected");
            
            btn_difficulty = 2'b10;
            #(CLK_PERIOD * 2);
            if (difficulty_level == 2'b01) $display("PASS: Medium difficulty selected");
            else $display("FAIL: Medium difficulty not selected");
            
            btn_difficulty = 2'b11;
            #(CLK_PERIOD * 2);
            if (difficulty_level == 2'b10) $display("PASS: Hard difficulty selected");
            else $display("FAIL: Hard difficulty not selected");
        end
        
        $display("\n=== Test 9: Reset Score Button ===");
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        btn_reset = 1;
        #(CLK_PERIOD * 3);
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        countdown_sec = 6'd5;
        #(CLK_PERIOD * 2);
        game_time_sec = 6'd15;
        score = 8'd20;
        #(CLK_PERIOD * 2);
        btn_reset_score = 0;
        #(CLK_PERIOD * 2);
        btn_reset_score = 1;
        #(CLK_PERIOD * 3);
        btn_reset_score = 0;
        #(CLK_PERIOD * 2);
        if (clear_score == 1'b1 && clear_game_timer == 1'b1) 
            $display("PASS: Reset score button clears score and timer");
        else $display("FAIL: Reset score button does not work");
        
        $display("\n=== Test 10: Reset During Countdown ===");
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        btn_reset = 1;
        #(CLK_PERIOD * 3);
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        countdown_sec = 6'd2;
        #(CLK_PERIOD * 2);
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        btn_reset = 1;
        #(CLK_PERIOD * 3);
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        if (clear_countdown == 1'b1) $display("PASS: Reset during countdown works");
        else $display("FAIL: Reset during countdown does not work");
        
        $display("\n=== Test 11: Reset During Playing ===");
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        btn_reset = 1;
        #(CLK_PERIOD * 3);
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        countdown_sec = 6'd5;
        #(CLK_PERIOD * 2);
        game_time_sec = 6'd10;
        #(CLK_PERIOD * 2);
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        btn_reset = 1;
        #(CLK_PERIOD * 3);
        btn_reset = 0;
        #(CLK_PERIOD * 2);
        if (game_state == 2'b01) $display("PASS: Reset during playing works");
        else $display("FAIL: Reset during playing does not work");
        
        $display("\n=== All Tests Completed ===");
        #(CLK_PERIOD * 10);
        $finish;
    end

endmodule

