module clock_divider(
    input clk,
    input reset,
    output reg slow_clk
);

    reg[26:0] counter;

    always @(posedge clk) begin
        if(reset) begin
            counter <= 0;
            slow_clk <= 0;
        end
        else begin
            if(counter == 27'd99_999_999) begin
                counter <= 0;
                slow_clk <= 1;
            end
            else begin
                counter <= counter + 1;
                slow_clk <= 0;
        end
        end

    end


endmodule