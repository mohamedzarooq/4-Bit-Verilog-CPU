  `timescale 1ns/1ps
    
    module cpu_tb;

    reg clk;
    reg reset;

    cpu uut (.clk(clk), .reset(reset));

    always #5 clk = ~clk;

    
       integer i;
       integer expected_pc [0:9];
       initial begin
            expected_pc[0]=0;
            expected_pc[1]=1;
            expected_pc[2]=2;
            expected_pc[3]=3;
            expected_pc[4]=4;
            expected_pc[5]=1;
            expected_pc[6]=2;
            expected_pc[7]=3;
            expected_pc[8]=4;
            expected_pc[9]=1;

        clk = 0;
        reset = 1;

        $dumpfile("cpu.vcd");
        $dumpvars(0, cpu_tb);

        #20 reset = 0;

        for(i = 0; i < 10; i=i+1) begin
            @(posedge clk);
            if(uut.pc_out != expected_pc[i])
                $display("FAIL at cycle %d | expected=%0d | actual=50d", i, i, uut.pc_out);
            else
                $display("PASS cycle %d", i);
        end

        $finish;
    end





    endmodule
