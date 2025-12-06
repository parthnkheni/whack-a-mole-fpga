module button_io #(
    parameter DEBOUNCE_CNTR_WIDTH = 20,
    parameter NUM_LEVELS          = 3,
    parameter LEVEL_BITS          = 2
)(
    input  clk,
    input  rst_n,
    input  btn_start,
    input  btn_difficulty,
    input  btn_clear,
    output start_pulse,
    output difficulty_pulse,
    output clear_pulse,
    output [LEVEL_BITS-1:0] difficulty_level
);

    wire start_level;
    wire diff_level_raw;
    wire clear_level;

    reg [LEVEL_BITS-1:0] difficulty_level_reg;

    assign difficulty_level = difficulty_level_reg;

    debounce_one_pulse #(
        .CNTR_WIDTH(DEBOUNCE_CNTR_WIDTH)
    ) u_start_button (
        .clk       (clk),
        .rst_n     (rst_n),
        .btn_raw   (btn_start),
        .btn_level (start_level),
        .btn_pulse (start_pulse)
    );

    debounce_one_pulse #(
        .CNTR_WIDTH(DEBOUNCE_CNTR_WIDTH)
    ) u_diff_button (
        .clk       (clk),
        .rst_n     (rst_n),
        .btn_raw   (btn_difficulty),
        .btn_level (diff_level_raw),
        .btn_pulse (difficulty_pulse)
    );

    debounce_one_pulse #(
        .CNTR_WIDTH(DEBOUNCE_CNTR_WIDTH)
    ) u_clear_button (
        .clk       (clk),
        .rst_n     (rst_n),
        .btn_raw   (btn_clear),
        .btn_level (clear_level),
        .btn_pulse (clear_pulse)
    );

    localparam [LEVEL_BITS-1:0] MAX_LEVEL = NUM_LEVELS - 1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            difficulty_level_reg <= {LEVEL_BITS{1'b0}};
        end else if (difficulty_pulse) begin
            if (difficulty_level_reg == MAX_LEVEL)
                difficulty_level_reg <= {LEVEL_BITS{1'b0}};
            else
                difficulty_level_reg <= difficulty_level_reg + 1'b1;
        end
    end

endmodule

