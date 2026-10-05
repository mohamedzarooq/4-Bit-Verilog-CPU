module top(input wire clk, input wire reset, output wire[3:0] led, output wire[3:0] D0_AN,output wire[7:0] D0_SEG, output wire[3:0] D1_AN, output wire[7:0] D1_SEG);

    wire[3:0] pc;
    wire[3:0] r0;
    wire[3:0] r1;
    wire slow_clk;

    clock_divider DIV(.clk(clk), .reset(reset), .slow_clk(slow_clk));
    cpu CPU(.clk(clk), .reset(reset), .step(slow_clk), .pc_out(pc), .r0(r0), .r1(r1));
    seg7_decoder DECODER(.hex(pc), .seg(D0_SEG));
    seg7_decoder DECODER1(.hex(r0), .seg(D1_SEG));
    assign D0_AN = 4'b1110;
    assign D1_AN = 4'b1110;
    assign led = pc;

endmodule
