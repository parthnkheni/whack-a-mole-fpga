module game_control_fsm(
    input  wire        clk,
    input  wire        clk_1hz,
    input  wire        rst_n,
    
    input  wire        btn_reset,
    input  wire        btn_reset_score,
    input  wire [1:0]  btn_difficulty,
    
    input  wire        timeout_pulse,
    input  wire        hit_pulse,
    input  wire [5:0]  countdown_sec,
    input  wire [5:0]  game_time_sec,
    input  wire [7:0]  score,
    
    output reg         enable_countdown,
    output reg         clear_countdown,
    output reg         enable_game_timer,
    output reg         clear_game_timer,
    output reg         enable_score,
    output reg         clear_score,
    output reg         enable_mole_ctrl,
    output reg         enable_difficulty_timer,
    output reg [1:0]   difficulty_level,
    
    output reg [7:0]   display_value,
    output reg         display_mode,
    output reg [1:0]   game_state
);

    localparam [1:0] STATE_IDLE      = 2'b00;
    localparam [1:0] STATE_COUNTDOWN = 2'b01;
    localparam [1:0] STATE_PLAYING   = 2'b10;
    localparam [1:0] STATE_GAME_OVER = 2'b11;
    
    localparam [5:0] COUNTDOWN_MAX = 6'd5;
    localparam [5:0] GAME_TIME_MAX = 6'd30;
    
    reg [1:0] state, next_state;
    reg [1:0] difficulty_reg;
    
    reg btn_reset_prev, btn_reset_score_prev;
    wire btn_reset_edge, btn_reset_score_edge;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_reset_prev <= 1'b0;
            btn_reset_score_prev <= 1'b0;
        end else begin
            btn_reset_prev <= btn_reset;
            btn_reset_score_prev <= btn_reset_score;
        end
    end
    
    assign btn_reset_edge = btn_reset && !btn_reset_prev;
    assign btn_reset_score_edge = btn_reset_score && !btn_reset_score_prev;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
            difficulty_reg <= 2'b00;
        end else begin
            state <= next_state;
            
            if ((state == STATE_IDLE || state == STATE_GAME_OVER) && btn_difficulty != 2'b00) begin
                if (btn_difficulty == 2'b01)
                    difficulty_reg <= 2'b00;
                else if (btn_difficulty == 2'b10)
                    difficulty_reg <= 2'b01;
                else if (btn_difficulty == 2'b11)
                    difficulty_reg <= 2'b10;
            end
        end
    end
    
    always @(*) begin
        next_state = state;
        
        case (state)
            STATE_IDLE: begin
                if (btn_reset_edge)
                    next_state = STATE_COUNTDOWN;
            end
            
            STATE_COUNTDOWN: begin
                if (countdown_sec >= COUNTDOWN_MAX)
                    next_state = STATE_PLAYING;
                else if (btn_reset_edge)
                    next_state = STATE_COUNTDOWN;
            end
            
            STATE_PLAYING: begin
                if (game_time_sec >= GAME_TIME_MAX)
                    next_state = STATE_GAME_OVER;
                else if (btn_reset_edge)
                    next_state = STATE_COUNTDOWN;
            end
            
            STATE_GAME_OVER: begin
                if (btn_reset_edge)
                    next_state = STATE_COUNTDOWN;
            end
            
            default: next_state = STATE_IDLE;
        endcase
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            enable_countdown <= 1'b0;
            clear_countdown <= 1'b1;
            enable_game_timer <= 1'b0;
            clear_game_timer <= 1'b1;
            enable_score <= 1'b0;
            clear_score <= 1'b1;
            enable_mole_ctrl <= 1'b0;
            enable_difficulty_timer <= 1'b0;
            difficulty_level <= 2'b00;
            display_value <= 8'd0;
            display_mode <= 1'b0;
            game_state <= STATE_IDLE;
        end else begin
            clear_countdown <= 1'b0;
            clear_game_timer <= 1'b0;
            clear_score <= 1'b0;
            
            game_state <= state;
            difficulty_level <= difficulty_reg;
            
            case (state)
                STATE_IDLE: begin
                    enable_countdown <= 1'b0;
                    enable_game_timer <= 1'b0;
                    enable_score <= 1'b0;
                    enable_mole_ctrl <= 1'b0;
                    enable_difficulty_timer <= 1'b0;
                    
                    clear_countdown <= 1'b1;
                    clear_game_timer <= 1'b1;
                    clear_score <= 1'b1;
                    
                    display_value <= 8'd0;
                    display_mode <= 1'b1;
                    
                    if (btn_reset_score_edge) begin
                        clear_score <= 1'b1;
                        clear_game_timer <= 1'b1;
                    end
                end
                
                STATE_COUNTDOWN: begin
                    enable_countdown <= 1'b1;
                    enable_game_timer <= 1'b0;
                    enable_score <= 1'b0;
                    enable_mole_ctrl <= 1'b0;
                    enable_difficulty_timer <= 1'b0;
                    
                    clear_game_timer <= 1'b1;
                    clear_score <= 1'b1;
                    
                    if (countdown_sec <= COUNTDOWN_MAX) begin
                        display_value <= {2'b00, (COUNTDOWN_MAX - countdown_sec)};
                    end else begin
                        display_value <= 8'd0;
                    end
                    display_mode <= 1'b0;
                    
                    if (btn_reset_score_edge) begin
                        clear_score <= 1'b1;
                        clear_game_timer <= 1'b1;
                    end
                    
                    if (btn_reset_edge) begin
                        clear_countdown <= 1'b1;
                    end
                end
                
                STATE_PLAYING: begin
                    enable_countdown <= 1'b0;
                    enable_game_timer <= 1'b1;
                    enable_score <= 1'b1;
                    enable_mole_ctrl <= 1'b1;
                    enable_difficulty_timer <= 1'b1;
                    
                    display_value <= score;
                    display_mode <= 1'b1;
                    
                    if (btn_reset_score_edge) begin
                        clear_score <= 1'b1;
                        clear_game_timer <= 1'b1;
                    end
                    
                    if (btn_reset_edge) begin
                        clear_countdown <= 1'b1;
                        clear_game_timer <= 1'b1;
                        clear_score <= 1'b1;
                    end
                end
                
                STATE_GAME_OVER: begin
                    enable_countdown <= 1'b0;
                    enable_game_timer <= 1'b0;
                    enable_score <= 1'b0;
                    enable_mole_ctrl <= 1'b0;
                    enable_difficulty_timer <= 1'b0;
                    
                    display_value <= score;
                    display_mode <= 1'b1;
                    
                    if (btn_reset_score_edge) begin
                        clear_score <= 1'b1;
                        clear_game_timer <= 1'b1;
                    end
                end
                
                default: begin
                    enable_countdown <= 1'b0;
                    enable_game_timer <= 1'b0;
                    enable_score <= 1'b0;
                    enable_mole_ctrl <= 1'b0;
                    enable_difficulty_timer <= 1'b0;
                    display_value <= 8'd0;
                    display_mode <= 1'b0;
                end
            endcase
        end
    end

endmodule
