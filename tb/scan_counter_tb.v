`timescale 1ns / 1ps

module scan_counter_tb;

    reg clk_scan;
    reg rst_n;
    
    wire [1:0] sel;
    
    scan_counter uut (
        .clk_scan(clk_scan),
        .rst_n(rst_n),
        .sel(sel)
    );
    
    initial begin
        clk_scan = 0;
        forever #10 clk_scan = ~clk_scan;
    end
    
    initial begin
        $dumpfile("scan_counter_tb.vcd");
        $dumpvars(0, scan_counter_tb);
        
        rst_n = 0;
        #20;
        
        $display("\n=== Test 1: Reset Function ===");
        @(posedge clk_scan);
        #2;
        if (sel == 0) begin
            $display("PASS: sel=0 after reset");
        end else begin
            $display("FAIL: Reset failed, sel=%0d", sel);
        end
        
        $display("\n=== Test 2: Normal Counting (0-3 cycle) ===");
        rst_n = 1;
        repeat(8) begin
            @(posedge clk_scan);
            #2;
            $display("Time: %0t ns, sel=%0d", $time, sel);
        end
        
        $display("\n=== Test 3: Verify Cycle Counting ===");
        if (sel == 0) begin
            $display("PASS: Counting cycle normal, returned to 0");
        end else begin
            $display("FAIL: Counting cycle error, sel=%0d", sel);
        end
        
        $display("\n=== Test 4: Re-count after Reset ===");
        rst_n = 0;
        @(posedge clk_scan);
        #2;
        if (sel == 0) begin
            $display("PASS: sel=0 after reset");
        end else begin
            $display("FAIL: Reset failed, sel=%0d", sel);
        end
        
        rst_n = 1;
        repeat(4) begin
            @(posedge clk_scan);
            #2;
            $display("Time: %0t ns, sel=%0d", $time, sel);
        end
        
        $display("\n=== All Tests Completed ===");
        #200;
        $finish;
    end
    
    initial begin
        $monitor("Time=%0t ns, rst_n=%b, sel=%0d",
                 $time, rst_n, sel);
    end

endmodule

