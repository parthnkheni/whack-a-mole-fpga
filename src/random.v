module random(
    input  wire clk,
    input  wire rst_n,
    input  wire enable,
    output reg  [2:0] random_num  
);

    //use lfsr for random
    reg [15:0] lfsr;
    
    
    wire feedback = lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr <= 16'hACE1;   // non-zero seed
            random_num <= 3'd0;
        end else begin
            // LFSR shifts every cycle → better randomness
            lfsr <= {lfsr[14:0], feedback};

            // Only update output when enabled
            if (enable) begin
                // Take 3 LSBs (0~7)
                if (lfsr[2:0] < 5)
                    random_num <= lfsr[2:0];
                else
                    random_num <= lfsr[2:0] - 3'd3;   // Map 5→2, 6→3, 7→4
            end
        end
    end

endmodule

