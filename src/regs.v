module register(input [3:0] d, input clk, input en, 
    input reset, output reg [3:0] q, output [3:0] notq);
    
      assign notq = ~q;
      always@(posedge clk) begin
            if(reset) begin
                q <= 0; //when reset is high it sets q to 0(<= delays setting the value so it synchronizes with clk at next cycle)
            end
            else if(en) begin
                q <= d; //when enable is high write data in d to q 
            end 
            //if both are false then q holds its value
    
      end
    endmodule

module reg_sel(input [3:0] d, input clk, input sel, input en, input reset, output wire [3:0] q0, output wire [3:0] q1, output [3:0] mux_out);  
    
    wire [3:0] notq0, notq1;
    wire en0, en1;
    assign en0 = en & ~sel; //chooses which register to write from
    assign en1 = en & sel;
    
    register R0 (.d(d), .clk(clk), .en(en0), .reset(reset), .q(q0), .notq(notq0));
    register R1 (.d(d), .clk(clk), .en(en1), .reset(reset), .q(q1), .notq(notq1));
    
    assign mux_out = sel ? q1 : q0;
    
    
    
    endmodule