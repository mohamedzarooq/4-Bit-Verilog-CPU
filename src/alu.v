 module fulladder(input a, input b, input cin, output s, output cout);
    
      assign s = (a ^ b) ^ cin;
      assign cout = ((a ^ b) & cin) | (a & b);
    
    endmodule
    
    module ripple_4bitadder(input [3:0] a, input [3:0] b, input cin, output [3:0] s, output cout);
    
    wire c1, c2, c3;
    
    fulladder fa0 (.a(a[0]), .b(b[0]), .cin(cin), .s(s[0]), .cout(c1));
    fulladder fa1 (.a(a[1]), .b(b[1]), .cin(c1), .s(s[1]), .cout(c2));
    fulladder fa2 (.a(a[2]), .b(b[2]), .cin(c2), .s(s[2]), .cout(c3));
    fulladder fa3 (.a(a[3]), .b(b[3]), .cin(c3), .s(s[3]), .cout(cout));
    
    endmodule
    
    module alu(input [3:0] a, input [3:0] b, input [1:0] opcode, 
    output reg cout, output reg [3:0] y, output zero_f, output neg_f, output eq_f);
    
    wire [3:0] b_mod;
    wire[3:0] sum;
    wire sub_cout;
    wire cin_internal;
    wire carry;
    
    assign cin_internal = (opcode == 2'b01); //if opcode is 1 assigns to 1, if not, assigns to 0
    assign b_mod = (opcode == 2'b01) ? ~b : b;
    assign zero_f = (y == 0);
    assign neg_f = y[3];
    assign eq_f = (a == b);
    
    
    ripple_4bitadder unit (.a(a), .b(b_mod), .cin(cin_internal), .s(sum), .cout(carry));
    
    
     always@(*)
    begin
        case(opcode)
        3'b000 : begin
            y = sum; //add
            cout = carry;
        end
        3'b001 : begin
            y = sum; //subtract
            cout = ~carry;
        end
        3'b010 : begin
            y = (a < b) ? 4'b0001 : (a > b) ? 4'b0010 : 0; //COMP
            cout = 0;
        end
        3'b011 : begin
            y = a ^ b; //xor since i can't do much else
            cout = 0;
        end
        3'b100 : begin
            y = b; //LI
            cout = 0;
        end
        default: begin
            y = 4'b0000; //default: just sets both to 0
            cout = 1'b0;
        end
        endcase
    end
    endmodule