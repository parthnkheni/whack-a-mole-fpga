# Clock Divider and Counter Modules Documentation

## clk_divider (Clock Divider)

`clk_divider` divides the system clock into fast and slow clocks:
- `clk_scan`: Scan clock for 7-segment display (fast clock)
- `clk_1hz`: 1Hz clock for other modules such as counters (slow clock)

### Parameters
- `DIV_1HZ`: 1Hz clock division ratio, default 50_000_000
- `DIV_SCAN`: Scan clock division ratio, default 50_000

---

## Counter Modules

The system contains three independent counter modules:

### 1. sec_counter (Second Counter)

Used for second counting, implements positive counting (increments from 0).

**Ports:**
- `clk_1hz`: 1Hz clock input
- `rst_n`: Asynchronous reset (active low)
- `enable`: Count enable signal
- `clear`: Clear signal (resets the counter to zero)
- `sec[5:0]`: 6-bit second count output

**Usage Example:**
If you need a countdown (e.g., from 5 to 0), you can use `5 - sec_counter` to achieve this.

---

### 2. score_counter (Score Counter)

A parameterized score counter. When a hit pulse is detected, the score increments by 1.

**Parameters:**
- `WIDTH`: Counter bit width, default 8 bits
- `MAX_SCORE`: Maximum score, default 99

**Ports:**
- `clk`: Clock input
- `rst_n`: Asynchronous reset (active low)
- `enable`: Count enable signal
- `clear`: Clear signal (used to reset at the start of a new game)
- `hit_pulse`: Hit pulse input (ensures only one pulse per button click)
- `score[WIDTH-1:0]`: Score output

**Functionality:**
- `hit_pulse` ensures that each button click generates only one pulse, implementing "one click, one score" functionality
- `clear` is used for clearing operations in the game (starting a new game)
- `rst_n` is used for system reset (resets all states)
- When the score reaches `MAX_SCORE`, it will no longer increment

**Note:** `clear` and `rst_n` have slightly different functions. `clear` is mainly used for clearing in game logic, while `rst_n` is used for system-level reset. You may also consider combining these two into a single reset signal.

---

### 3. scan_counter (Scan Counter)

Generates scan selection signals for 7-segment display, similar to the lab code.

**Ports:**
- `clk_scan`: Scan clock input
- `rst_n`: Asynchronous reset (active low)
- `sel[1:0]`: 2-bit scan selection signal output (used to select the currently displayed digit)

**Functionality:**
- Under `clk_scan` clock drive, `sel` cycles from 0 to 3
- On reset, `sel` is cleared to 0
