# Whack-a-Mole on FPGA (Nexys4 DDR, Verilog)

Real-time Whack-a-Mole reaction game implemented on a Nexys4 DDR FPGA (Artix-7 xc7a100t) as a final project for BU EC311 – Introduction to Logic Design.  
The FPGA acts as the game controller: handling timing, random mole selection, debounced inputs, scoring, and 7-segment display output entirely in hardware.

---

## Features

- 30-second Whack-a-Mole game loop
- 5 LED “moles” driven directly from the FPGA
- 5 corresponding switches (one under each LED) for intuitive input  
- Multiple difficulty levels (easy/medium/hard) with different mole display times
- 5-second countdown before each round starts
- Live score display on the 7-segment display
- Fully synchronous Verilog design with debounced button inputs and clean one-pulse signals

---

## Controls & Gameplay

**Board:** Digilent Nexys4 DDR (Artix-7 xc7a100tcsg324-1)  

**Physical layout:**

- **LEDs:** `LED[4:0]` – 5 mole positions
- **Switches:** `SW[4:0]` – 5 switches directly under the LEDs  
- **Buttons:**
  - **BTNC (center):** global reset
  - **BTNU (up):** start game / start 5-second countdown
  - **BTNR (right):** change difficulty (cycles easy → medium → hard)
  - **BTNL (left):** clear score
  - **BTND (down):** “hammer” button to whack the selected mole

**How to play:**

1. **Reset** the board with **BTNC**.
2. (Optional) **Select difficulty** by pressing **BTNR** one or more times.
3. Press **BTNU** to start the **5-second countdown** on the 7-segment display.
4. After the countdown, **one LED** in `LED[4:0]` lights up as the mole.
5. Flip the **switch directly under that LED** (`SW[0]`–`SW[4]`), then press **BTND** to “hammer” it.
   - If the switch matches the lit LED when BTND is pressed → **score +1**.
   - Otherwise the mole times out with no score.
6. Moles continue to appear for **30 seconds**. Final score is shown on the 7-segment display.
7. Press **BTNL** to clear score, or **BTNU** again to start a new round.

---

## Top-Level Architecture

The design is split into small, focused Verilog modules that are instantiated in `top.v`:

- **`button_io.v`**
  - Debounces start / difficulty / clear buttons
  - Generates one-cycle pulses and tracks difficulty level

- **`debounce_one_pulse.v`**
  - Generic debouncer and one-pulse generator used for all buttons (including the hammer)

- **`clock_divider.v`**
  - Takes the 100 MHz board clock and produces:
    - `clk_1hz` for second counters
    - `clk_scan` (≈1 kHz) for 7-segment multiplexing

- **`sec_counter.v`**
  - Second counters for:
    - 5-second pre-game countdown
    - 30-second game timer

- **`difficulty_timer.v`**
  - Counts 100 MHz clock cycles to control mole display time
  - Parameterized for easy/medium/hard durations (e.g., 3 s / 2 s / 1 s)

- **`random.v`**
  - 16-bit LFSR random generator
  - Produces a pseudo-random 3-bit index for the mole position

- **`mole_led_ctrl.v`**
  - Ensures exactly one mole LED is active at a time
  - Handles mole spawn, hit detection, and timeout

- **`mole_led_and_random.v`**
  - Wraps `random`, `mole_led_ctrl`, and `difficulty_timer`
  - Exposes a clean interface: `mole_led`, `hit_pulse`, `timeout_pulse`

- **`score_counter.v`**
  - Increments score on each `hit_pulse`
  - Clears on reset/clear

- **`seven_seg_decoder.v`**, **`two_digit_7seg.v`**
  - Convert score/countdown to segment patterns
  - Multiplex two digits on the Nexys4 DDR 7-segment display

- **`game_control_fsm.v`**
  - Main finite state machine:
    - IDLE → COUNTDOWN → PLAYING → GAME_OVER
  - Enables/disables countdown, game timer, score logic, and mole logic
  - Selects what the 7-segment display shows (countdown vs. score)

- **`top.v`**
  - Connects all modules together
  - Maps FPGA I/O to board pins (buttons, switches, LEDs, 7-segment display)

---

## Building & Running (Vivado)

1. **Open Vivado** (tested with Vivado 2024.x, Artix-7 xc7a100tcsg324-1).
2. **Create a new RTL project**, do **not** add sources at first.
3. **Add sources**:
   - Add all `.v` files in the `src/` directory (or repo root, depending on your layout).
4. **Add constraints**:
   - Add `Nexys4DDR_Master.xdc`.
5. **Set the top module** to `top`.
6. Run:
   - **Run Synthesis**
   - **Run Implementation**
   - **Generate Bitstream**
7. Open **Hardware Manager**, connect to the Nexys4 DDR, and **Program Device** with the generated bitstream.
8. Play Whack-a-Mole 🎯

---

## Repository Layout

Example layout (may vary slightly depending on how you organize it):

```text
.
├── src/
│   ├── top.v
│   ├── button_io.v
│   ├── debounce_one_pulse.v
│   ├── clock_divider.v
│   ├── sec_counter.v
│   ├── difficulty_timer.v
│   ├── random.v
│   ├── mole_led_ctrl.v
│   ├── mole_led_and_random.v
│   ├── score_counter.v
│   ├── seven_seg_decoder.v
│   ├── two_digit_7seg.v
│   ├── game_control_fsm.v
│   └── Nexys4DDR_Master.xdc
└── README.md
