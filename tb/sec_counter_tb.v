`timescale 1ns / 1ps

module sec_counter_tb;

    reg clk_1hz;
    reg rst_n;
    reg enable;
    reg clear;
    
    wire [5:0] sec;
    
    sec_counter uut (
        .clk_1hz(clk_1hz),
        .rst_n(rst_n),
        .enable(enable),
        .clear(clear),
        .sec(sec)
    );
    
    initial begin
        clk_1hz = 0;
        forever #100 clk_1hz = ~clk_1hz;
    end
    
    initial begin
        $dumpfile("sec_counter_tb.vcd");
        $dumpvars(0, sec_counter_tb);
        
        rst_n = 0;
        enable = 0;
        clear = 0;
        #50;
        
        $display("\n=== Test 1: Reset Function ===");
        @(posedge clk_1hz);
        #10;
        if (sec == 0) begin
            $display("PASS: sec=0 after reset");
        end else begin
            $display("FAIL: Reset failed, sec=%0d", sec);
        end
        
        $display("\n=== Test 2: Normal Counting (enable=1) ===");
        rst_n = 1;
        enable = 1;
        clear = 0;
        repeat(10) begin
            @(posedge clk_1hz);
            #10;
            $display("Time: %0t ns, sec=%0d", $time, sec);
        end
        if (sec == 10) begin
            $display("PASS: Counted to 10");
        end else begin
            $display("FAIL: Counting error, expected 10, got %0d", sec);
        end
        
        $display("\n=== Test 3: Stop Counting when enable=0 ===");
        enable = 0;
        repeat(3) @(posedge clk_1hz);
        #10;
        $display("Time: %0t ns, sec=%0d (should remain 10)", $time, sec);
        if (sec == 10) begin
            $display("PASS: Counting stopped when enable=0");
        end else begin
            $display("FAIL: Still counting when enable=0, sec=%0d", sec);
        end
        
        $display("\n=== Test 4: Clear Function ===");
        enable = 1;
        @(posedge clk_1hz);
        #10;
        $display("Before clear: sec=%0d", sec);
        clear = 1;
        @(posedge clk_1hz);
        #10;
        $display("After clear: sec=%0d", sec);
        if (sec == 0) begin
            $display("PASS: Clear function works");
        end else begin
            $display("FAIL: Clear failed, sec=%0d", sec);
        end
        clear = 0;
        
        $display("\n=== Test 5: Continue Counting after Clear ===");
        repeat(5) begin
            @(posedge clk_1hz);
            #10;
            $display("Time: %0t ns, sec=%0d", $time, sec);
        end
        if (sec == 5) begin
            $display("PASS: Counting normal after clear");
        end else begin
            $display("FAIL: Counting error after clear, expected 5, got %0d", sec);
        end
        
        $display("\n=== Test 6: Count to Maximum (63) ===");
        clear = 1;
        @(posedge clk_1hz);
        #10;
        clear = 0;
        repeat(63) @(posedge clk_1hz);
        #10;
        $display("Counted to 63: sec=%0d", sec);
        if (sec == 63) begin
            $display("PASS: Counted to 63");
        end else begin
            $display("FAIL: Counting error, expected 63, got %0d", sec);
        end
        
        $display("\n=== Test 7: Overflow Test (continue from 63) ===");
        @(posedge clk_1hz);
        #10;
        $display("After overflow: sec=%0d (should return to 0)", sec);
        if (sec == 0) begin
            $display("PASS: Returned to 0 after overflow");
        end else begin
            $display("FAIL: Overflow handling error, sec=%0d", sec);
        end
        
        $display("\n=== All Tests Completed ===");
        #200;
        $finish;
    end
    
    initial begin
        $monitor("Time=%0t ns, rst_n=%b, enable=%b, clear=%b, sec=%0d",
                 $time, rst_n, enable, clear, sec);
    end

endmodule
