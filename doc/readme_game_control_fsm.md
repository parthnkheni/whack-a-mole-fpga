# Game Control FSM Module Documentation

## Overview

The `game_control_fsm` module is the core finite state machine (FSM) controller for the Whack-a-Mole game. It manages the overall game flow, coordinates all sub-modules, handles button inputs, and controls the display output. The FSM implements a complete game cycle: idle state, 5-second countdown, 30-second gameplay, and game over state.

## State Machine

The FSM has four states:

- **STATE_IDLE (2'b00)**: Initial state, waiting for reset button to start the game
- **STATE_COUNTDOWN (2'b01)**: 5-second countdown before game starts
- **STATE_PLAYING (2'b10)**: Active gameplay state (30 seconds)
- **STATE_GAME_OVER (2'b11)**: Game ended, displaying final score

## Input Ports

### Clock and Reset
- `clk`: System clock input
- `clk_1hz`: 1Hz clock input (for second-based timing)
- `rst_n`: Asynchronous reset signal (active low)

### Button Inputs
- `btn_reset`: Reset button input (pulse signal, debounced). Completely resets the game including difficulty level
- `btn_reset_score`: Independent reset button (pulse signal, debounced). Resets only score and game timer, preserves difficulty level
- `btn_difficulty[1:0]`: Difficulty selection button input (2-bit)
  - `2'b01`: Easy difficulty
  - `2'b10`: Medium difficulty
  - `2'b11`: Hard difficulty
  - `2'b00`: No selection

### Status Inputs from Sub-modules
- `timeout_pulse`: Timeout pulse from difficulty_timer module (indicates LED timeout)
- `hit_pulse`: Hit pulse from mole_led_ctrl module (indicates successful mole hit)
- `countdown_sec[5:0]`: Countdown counter value (from sec_counter)
- `game_time_sec[5:0]`: Game time counter value (from sec_counter)
- `score[7:0]`: Current score value (from score_counter)

## Output Ports

### Counter Control Signals
- `enable_countdown`: Enable signal for countdown counter
- `clear_countdown`: Clear signal for countdown counter (pulse)
- `enable_game_timer`: Enable signal for game time counter
- `clear_game_timer`: Clear signal for game time counter (pulse)
- `enable_score`: Enable signal for score counter
- `clear_score`: Clear signal for score counter (pulse)

### Game Module Control Signals
- `enable_mole_ctrl`: Enable signal for mole_led_ctrl module
- `enable_difficulty_timer`: Enable signal for difficulty_timer module
- `difficulty_level[1:0]`: Difficulty level output
  - `2'b00`: Easy
  - `2'b01`: Medium
  - `2'b10`: Hard

### Display Outputs
- `display_value[7:0]`: Value to be displayed on 7-segment display
  - In COUNTDOWN state: Shows countdown value (5 to 0)
  - In PLAYING/GAME_OVER state: Shows current/final score
- `display_mode`: Display mode selection
  - `1'b0`: Countdown mode
  - `1'b1`: Score mode

### Debug Output
- `game_state[1:0]`: Current FSM state (for debugging)

## Functionality

### State Transitions

1. **IDLE → COUNTDOWN**: Triggered by `btn_reset` button press
2. **COUNTDOWN → PLAYING**: Automatically transitions when `countdown_sec >= 5`
3. **PLAYING → GAME_OVER**: Automatically transitions when `game_time_sec >= 30`
4. **GAME_OVER → COUNTDOWN**: Triggered by `btn_reset` button press
5. **Any state → COUNTDOWN**: Can be triggered by `btn_reset` during any state

### Button Edge Detection

The module implements edge detection for `btn_reset` and `btn_reset_score` to convert button pulses into single-cycle signals, ensuring proper state transitions.

### Difficulty Selection

- Difficulty can be changed only in IDLE or GAME_OVER states
- Difficulty level is stored in an internal register and persists across `btn_reset_score` operations
- Only `btn_reset` (full reset) will reset the difficulty to default (Easy)

### Display Control

- **COUNTDOWN state**: Displays `5 - countdown_sec` (countdown from 5 to 0)
- **PLAYING state**: Displays current score
- **GAME_OVER state**: Displays final score
- **IDLE state**: Displays 0

### Module Coordination

The FSM coordinates all sub-modules by:
- Enabling/disabling counters and game modules based on current state
- Generating clear pulses to reset counters at appropriate times
- Providing difficulty level to difficulty_timer module
- Managing display data and mode selection

## Usage Notes

1. All button inputs should be debounced before connecting to this module
2. The module expects `countdown_sec` and `game_time_sec` to increment from 0
3. The countdown display calculation: `display_value = 5 - countdown_sec` (when `countdown_sec <= 5`)
4. `btn_reset_score` provides a way to reset game progress without changing difficulty settings
5. The module uses synchronous logic with asynchronous reset

