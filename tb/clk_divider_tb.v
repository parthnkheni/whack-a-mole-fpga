`timescale 1ns / 1ps

module clk_divider_tb;

    // 测试参数
    parameter integer DIV_1HZ   = 50_000_000;
    parameter integer DIV_SCAN = 50_000;
    
    // 为了加快仿真，使用较小的分频值
    parameter integer SIM_DIV_1HZ   = 100;  // 仿真用：100个时钟周期
    parameter integer SIM_DIV_SCAN = 10;    // 仿真用：10个时钟周期

    // 信号声明
    reg clk;
    reg rst_n;
    wire clk_1hz;
    wire clk_scan;

    // 实例化被测模块
    clock_divider #(
        .DIV_1HZ(SIM_DIV_1HZ),
        .DIV_SCAN(SIM_DIV_SCAN)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .clk_1hz(clk_1hz),
        .clk_scan(clk_scan)
    );

    // 时钟生成：10ns 周期 (50MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 5ns 半周期，总周期 10ns
    end

    // 测试序列
    initial begin
        $dumpfile("clk_divider_tb.vcd");
        $dumpvars(0, clk_divider_tb);
        
        // 初始化
        rst_n = 0;
        #20;
        
        // 释放复位
        rst_n = 1;
        #1000;
        
        // 检查输出
        $display("=== 测试结果 ===");
        $display("时间: %0t ns", $time);
        $display("clk_1hz: %b", clk_1hz);
        $display("clk_scan: %b", clk_scan);
        
        // 观察几个周期
        #2000;
        
        $display("=== 最终状态 ===");
        $display("时间: %0t ns", $time);
        $display("clk_1hz: %b", clk_1hz);
        $display("clk_scan: %b", clk_scan);
        
        $finish;
    end

    // 监控信号变化
    initial begin
        $monitor("时间=%0t ns, rst_n=%b, clk_1hz=%b, clk_scan=%b", 
                 $time, rst_n, clk_1hz, clk_scan);
    end

endmodule

