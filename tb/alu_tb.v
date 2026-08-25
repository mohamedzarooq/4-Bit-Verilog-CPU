`timescale 1ns/1ps
    
    module alu_tb;

        reg [3:0] a, b;
        reg [1:0] opcode;
        wire cout, zero_f, neg_f, eq_f;
        wire [3:0] y;
    
        alu uut(.a(a), .b(b), .opcode(opcode), .cout(cout), .y(y), .zero_f(zero_f), .neg_f(neg_f), .eq_f(eq_f));
    
        integer i;
        integer j;
        integer k;
        initial begin
            $dumpfile("alu.vcd");
            $dumpvars(0, alu_tb);
    
            a = 4'd0;
            b = 4'd0;
            opcode = 2'b00;
    
            for(int i = 0; i < 4; i++) begin
                for(int j = 0; j < 16; j++) begin
                    for(int k = 0; k < 16; k++) begin
                        a = j;
                        b = k;
                        opcode = i;
    
                        #20 
                        case(opcode)
                            2'd0: begin // ADD
                                reg [4:0] expected;
                                expected = a + b;
    
                                if(y != expected[3:0] || cout != expected[4])
                                    $display("ADD ERROR A=%d B=%d Y=%d C=%d",
                                            a,b,y,cout);
                            end
    
    
                            2'd1: begin // SUB
                                if(y != (a-b))
                                    $display("SUB ERROR A=%d B=%d Y=%d",
                                            a,b,y);
                            end
    
                            2'd2: begin //COMP
                                if(a < b && y != 4'b0001)
                                    $display("COMP ERROR: A=%d B=%d expected LESS got %b", a, b, y);
    
                                else if(a > b && y != 4'b0010)
                                    $display("COMP ERROR: A=%d B=%d expected GREATER got %b", a, b, y);
    
                                else if(a == b && y != 4'b0100)
                                    $display("COMP ERROR: A=%d B=%d expected EQUAL got %b", a, b, y);
                            end
    
    
                            2'd3: begin // XOR
                                if(y != (a ^ b))
                                    $display("XOR ERROR A=%d B=%d Y=%d",
                                            a,b,y);
                            end
    
                        endcase
    
                    end
                end
            end
            $finish;
        end
    
    
    endmodule