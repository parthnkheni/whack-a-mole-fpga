clk_divider is dividing the clk into fast and slow clk, cnt_scan is the clk used for displaying the 
numbers(7 segments); cnt_1hz is used for others such as counters.

For the counter parts, I am considering dividing it to three independent counters.
sec_counter is used for seconds counting, I am writing it to a positive counting, eg. from 0 to 5
If you want to use it for counting for other modules, you can use "5-'sec_counter' like this.

For the other two counters, one is score_counter and one is scan_counter(for the 7 segments only)
 I will update this file after completing the other two counters.

