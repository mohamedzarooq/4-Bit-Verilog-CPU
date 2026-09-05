`timescale 1ns/1ps

    module cpu_tb;

        reg clk;
        reg reset;
    
        cpu uut (.clk(clk), .reset(reset));
    
        always #5 clk = ~clk;
    
    
       
        initial begin
    
        clk = 0;
        reset = 1;
    
        #10;
        reset = 0;
    
        repeat (80) begin
            @(posedge clk);
            #1;
    
            $display("PC = %0d | instr = %b | R0 = %0d | zero_flag = %b", uut.pc_out, uut.instr, uut.r0, uut.zero_flag);
        end
    
        $finish;
    
        end





    endmodule
