`timescale 1ns / 1ps

module clk_divider_tb;

    parameter integer DIV_1HZ   = 50_000_000;
    parameter integer DIV_SCAN = 50_000;
    
    parameter integer SIM_DIV_1HZ   = 100;
    parameter integer SIM_DIV_SCAN = 10;

    reg clk;
    reg rst_n;
    wire clk_1hz;
    wire clk_scan;

    clock_divider #(
        .DIV_1HZ(SIM_DIV_1HZ),
        .DIV_SCAN(SIM_DIV_SCAN)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .clk_1hz(clk_1hz),
        .clk_scan(clk_scan)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        $dumpfile("clk_divider_tb.vcd");
        $dumpvars(0, clk_divider_tb);
        
        rst_n = 0;
        #20;
        
        rst_n = 1;
        #1000;
        
        $display("=== Test Results ===");
        $display("Time: %0t ns", $time);
        $display("clk_1hz: %b", clk_1hz);
        $display("clk_scan: %b", clk_scan);
        
        #2000;
        
        $display("=== Final State ===");
        $display("Time: %0t ns", $time);
        $display("clk_1hz: %b", clk_1hz);
        $display("clk_scan: %b", clk_scan);
        
        $finish;
    end

    initial begin
        $monitor("Time=%0t ns, rst_n=%b, clk_1hz=%b, clk_scan=%b", 
                 $time, rst_n, clk_1hz, clk_scan);
    end

endmodule

