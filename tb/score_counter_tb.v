`timescale 1ns / 1ps

module score_counter_tb;

    reg clk;
    reg rst_n;
    reg enable;
    reg clear;
    reg hit_pulse;
    
    wire [7:0] score;
    
    score_counter #(
        .WIDTH(8),
        .MAX_SCORE(99)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .clear(clear),
        .hit_pulse(hit_pulse),
        .score(score)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        $dumpfile("score_counter_tb.vcd");
        $dumpvars(0, score_counter_tb);
        
        rst_n = 0;
        enable = 0;
        clear = 0;
        hit_pulse = 0;
        #20;
        
        $display("\n=== Test 1: Reset Function ===");
        @(posedge clk);
        #2;
        if (score == 0) begin
            $display("PASS: score=0 after reset");
        end else begin
            $display("FAIL: Reset failed, score=%0d", score);
        end
        
        $display("\n=== Test 2: Normal Counting (enable=1, hit_pulse=1) ===");
        rst_n = 1;
        enable = 1;
        clear = 0;
        repeat(10) begin
            hit_pulse = 1;
            @(posedge clk);
            #2;
            hit_pulse = 0;
            @(posedge clk);
            #2;
            $display("Time: %0t ns, score=%0d", $time, score);
        end
        if (score == 10) begin
            $display("PASS: Counted to 10");
        end else begin
            $display("FAIL: Counting error, expected 10, got %0d", score);
        end
        
        $display("\n=== Test 3: Stop Counting when enable=0 ===");
        enable = 0;
        hit_pulse = 1;
        repeat(3) @(posedge clk);
        #2;
        $display("Time: %0t ns, score=%0d (should remain 10)", $time, score);
        if (score == 10) begin
            $display("PASS: Counting stopped when enable=0");
        end else begin
            $display("FAIL: Still counting when enable=0, score=%0d", score);
        end
        
        $display("\n=== Test 4: Stop Counting when hit_pulse=0 ===");
        enable = 1;
        hit_pulse = 0;
        repeat(3) @(posedge clk);
        #2;
        $display("Time: %0t ns, score=%0d (should remain 10)", $time, score);
        if (score == 10) begin
            $display("PASS: Counting stopped when hit_pulse=0");
        end else begin
            $display("FAIL: Still counting when hit_pulse=0, score=%0d", score);
        end
        
        $display("\n=== Test 5: Clear Function ===");
        enable = 1;
        hit_pulse = 1;
        @(posedge clk);
        #2;
        $display("Before clear: score=%0d", score);
        clear = 1;
        @(posedge clk);
        #2;
        $display("After clear: score=%0d", score);
        if (score == 0) begin
            $display("PASS: Clear function works");
        end else begin
            $display("FAIL: Clear failed, score=%0d", score);
        end
        clear = 0;
        
        $display("\n=== Test 6: Continue Counting after Clear ===");
        repeat(5) begin
            hit_pulse = 1;
            @(posedge clk);
            #2;
            hit_pulse = 0;
            @(posedge clk);
            #2;
            $display("Time: %0t ns, score=%0d", $time, score);
        end
        if (score == 5) begin
            $display("PASS: Counting normal after clear");
        end else begin
            $display("FAIL: Counting error after clear, expected 5, got %0d", score);
        end
        
        $display("\n=== Test 7: Count to Maximum (99) ===");
        clear = 1;
        @(posedge clk);
        #2;
        clear = 0;
        repeat(99) begin
            hit_pulse = 1;
            @(posedge clk);
            #2;
            hit_pulse = 0;
            @(posedge clk);
            #2;
        end
        $display("Counted to 99: score=%0d", score);
        if (score == 99) begin
            $display("PASS: Counted to 99");
        end else begin
            $display("FAIL: Counting error, expected 99, got %0d", score);
        end
        
        $display("\n=== Test 8: Exceed Maximum Test (continue from 99) ===");
        hit_pulse = 1;
        @(posedge clk);
        #2;
        hit_pulse = 0;
        @(posedge clk);
        #2;
        $display("After exceeding 99: score=%0d (should remain 99)", score);
        if (score == 99) begin
            $display("PASS: Remains at 99 after exceeding maximum");
        end else begin
            $display("FAIL: Maximum handling error, score=%0d", score);
        end
        
        $display("\n=== All Tests Completed ===");
        #200;
        $finish;
    end
    
    initial begin
        $monitor("Time=%0t ns, rst_n=%b, enable=%b, clear=%b, hit_pulse=%b, score=%0d",
                 $time, rst_n, enable, clear, hit_pulse, score);
    end

endmodule

