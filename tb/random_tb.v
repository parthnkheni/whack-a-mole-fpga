`timescale 1ns / 1ps

module random_tb;

    reg clk;
    reg rst_n;
    reg enable;
    
    wire [2:0] random_num;
    
    // Test variables
    reg [2:0] prev_value;
    integer count[0:4];
    integer i;
    
    random uut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .random_num(random_num)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 50MHz clock (20ns period)
    end
    
    // Test sequence
    initial begin
        $dumpfile("random_tb.vcd");
        $dumpvars(0, random_tb);
        
        // Initialize
        rst_n = 0;
        enable = 0;
        #50;
        
        $display("\n=== Test 1: Reset Function ===");
        @(posedge clk);
        #5;
        if (random_num == 0) begin
            $display("PASS: random_num=0 after reset");
        end else begin
            $display("FAIL: Reset failed, random_num=%0d", random_num);
        end
        
        $display("\n=== Test 2: Enable Function - Generate Random Numbers ===");
        rst_n = 1;
        enable = 1;
        repeat(20) begin
            @(posedge clk);
            #5;
            $display("Time: %0t ns, random_num=%0d", $time, random_num);
            // Verify range: 0-4
            if (random_num > 4) begin
                $display("ERROR: random_num=%0d is out of range (should be 0-4)!", random_num);
            end
        end
        
        $display("\n=== Test 3: Disable Function ===");
        enable = 0;
        @(posedge clk);
        #5;
        prev_value = random_num;
        $display("Time: %0t ns, random_num=%0d (captured)", $time, prev_value);
        
        repeat(5) begin
            @(posedge clk);
            #5;
            $display("Time: %0t ns, random_num=%0d (should remain %0d)", $time, random_num, prev_value);
            if (random_num != prev_value) begin
                $display("ERROR: random_num changed when enable=0!");
            end
        end
        
        $display("\n=== Test 4: Re-enable and Generate More Random Numbers ===");
        enable = 1;
        repeat(20) begin
            @(posedge clk);
            #5;
            $display("Time: %0t ns, random_num=%0d", $time, random_num);
            if (random_num > 4) begin
                $display("ERROR: random_num=%0d is out of range!", random_num);
            end
        end
        
        $display("\n=== Test 5: Statistical Distribution Check ===");
        count[0] = 0;
        count[1] = 0;
        count[2] = 0;
        count[3] = 0;
        count[4] = 0;
        
        repeat(100) begin
            @(posedge clk);
            #5;
            case(random_num)
                0: count[0] = count[0] + 1;
                1: count[1] = count[1] + 1;
                2: count[2] = count[2] + 1;
                3: count[3] = count[3] + 1;
                4: count[4] = count[4] + 1;
            endcase
        end
        
        $display("\nDistribution after 100 samples:");
        $display("  Value 0: %0d times (%.1f%%)", count[0], (count[0] * 100.0) / 100.0);
        $display("  Value 1: %0d times (%.1f%%)", count[1], (count[1] * 100.0) / 100.0);
        $display("  Value 2: %0d times (%.1f%%)", count[2], (count[2] * 100.0) / 100.0);
        $display("  Value 3: %0d times (%.1f%%)", count[3], (count[3] * 100.0) / 100.0);
        $display("  Value 4: %0d times (%.1f%%)", count[4], (count[4] * 100.0) / 100.0);
        
        $display("\n=== Test 6: Reset and Re-initialize ===");
        rst_n = 0;
        @(posedge clk);
        #5;
        if (random_num == 0) begin
            $display("PASS: random_num=0 after reset");
        end else begin
            $display("FAIL: Reset failed, random_num=%0d", random_num);
        end
        
        rst_n = 1;
        enable = 1;
        repeat(10) begin
            @(posedge clk);
            #5;
            $display("Time: %0t ns, random_num=%0d", $time, random_num);
        end
        
        $display("\n=== All Tests Completed ===");
        #200;
        $finish;
    end
    
    // Monitor
    initial begin
        $monitor("Time=%0t ns, rst_n=%b, enable=%b, random_num=%0d",
                 $time, rst_n, enable, random_num);
    end

endmodule

