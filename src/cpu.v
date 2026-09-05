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
    
module alu(input [3:0] a, input [3:0] b, input [2:0] opcode, 
    output reg cout, output reg [3:0] y, output zero_f, output neg_f, output eq_f);
    
    wire [3:0] b_mod;
    wire[3:0] sum;
    wire sub_cout;
    wire cin_internal;
    wire carry;
    
    assign cin_internal = (opcode == 3'b001); //if opcode is 1 assigns to 1, if not, assigns to 0
    assign b_mod = (opcode == 3'b001) ? ~b : b;
    assign zero_f = (y == 0);
    assign neg_f = y[3];
    assign eq_f = (a == b);
    
    
    ripple_4bitadder unit (.a(a), .b(b_mod), .cin(cin_internal), .s(sum), .cout(carry));
    
    
    always@(*) begin
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
            y = eq_f; //comp
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

module control_unit(input [2:0] opcode, output reg reg_write, 
    output reg [2:0] alu_op, output reg alu_src, 
    output reg  jump, output reg jump_cond);
    always@(*) begin
        reg_write = 0;
        alu_src = 0;
        alu_op = 3'b000;
        jump = 0;
        jump_cond = 0;
    case(opcode)
    
    3'b000 : begin //add
        alu_op = 3'b000;
        reg_write = 1;
        alu_src = 1;
    end
    3'b001 : begin //comp
        alu_op = 3'b010;
        alu_src = 1;
    end
    3'b010 : begin //jmp
        jump = 1;
        jump_cond = 0;
    end
    
    3'b011 : begin //jeq
        jump = 1;
        jump_cond = 1;
    end
    3'b100 : begin //li
        alu_src = 1;
        reg_write = 1;
        alu_op = 3'b100;
    end
    
    endcase
    
    
    
    
    
    end
    
    
    
    endmodule

module instruction_memory(input [3:0] addr, output reg [7:0] instr);

    always @(*) begin
      //count from 0 to 10. i need to increment, store, and output, then loop back to 0 once at 10. ADD(00), LOAD(10), STORE(01), JUMP(11)

    case(addr) 
                      //What the values of the address mean: ###(ISA)_####(value)_#(register)
        4'b0000 : instr = 8'b100_0000_0; //li 1 to r0
        4'b0001 : instr = 8'b000_0001_0; //add 1 to r0 i.e r0 = r0 + 1
        4'b0010 : instr = 8'b001_1010_0; //compare r0 to 10
        4'b0011 : instr = 8'b011_0101_0; //jeq to instruction 5(reset)
        4'b0100 : instr = 8'b010_0001_0; //jmp to instruction 1(loop)
        4'b0101 : instr = 8'b100_0000_0; //li 0 to r0
        4'b0110 : instr = 8'b010_0001_0; //jmp to instruction 1(loop)
        default : instr = 8'b000_0000_0;
    endcase
    end


    endmodule

module program_counter(input clk, input reset, input jump, input jump_cond, input [3:0] jump_add, input count_en, input eq_flag, output reg [3:0] pc_out);

      wire [3:0] next_pc;
      wire [3:0] increment;
      wire pc_takejump;

      assign increment = pc_out + 1;
      assign pc_takejump = jump & (jump_cond ? eq_flag : 1'b1); //for jeq in isa
      assign next_pc = pc_takejump ? jump_add : increment; //jump to new address if enabled
        
    
      always @(posedge clk) begin
            if (reset)
                pc_out <= 0;
            else if (count_en)
                pc_out <= next_pc;
        end
        
    
    endmodule

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




    

module cpu(input wire clk, input wire reset);
    
    wire [3:0] pc_out;
    wire [7:0] instr;
    reg comp_val;
    
    program_counter PC (
        .clk(clk),
        .reset(reset),
        .jump(jump),
        .jump_cond(jump_cond),
        .jump_add(instr[4:1]),
        .count_en(1'b1),
        .eq_flag(comp_val),
        .pc_out(pc_out)
    );
    
    instruction_memory IM (
        .addr(pc_out),
        .instr(instr)
    );
    
    wire [2:0] opcode = instr[7:5];
    wire [3:0] imm = instr[4:1];
    wire sel = instr[0];
    
    wire reg_write, alu_src, jump, jump_cond;
    wire [2:0] alu_op;
    
    control_unit CU (
        .opcode(opcode),
        .reg_write(reg_write),
        .alu_op(alu_op),
        .alu_src(alu_src),
        .jump(jump),
        .jump_cond(jump_cond)
    );
    
    wire [3:0] reg_data;
    wire [3:0] r0, r1;
    
    reg_sel RF (
        .d(alu_out),
        .clk(clk),
        .sel(sel),
        .en(reg_write),
        .reset(reset),
        .q0(r0),
        .q1(r1),
        .mux_out(reg_data)
    );
    
    wire [3:0] alu_b;
    
    assign alu_b = alu_src ? imm : r1;
    
    wire [3:0] alu_out;
    wire zero_flag, neg_flag, eq_flag;
    wire cout;
    
    alu ALU (
        .a(reg_data),
        .b(alu_b),
        .opcode(alu_op),
        .y(alu_out),
        .cout(cout),
        .zero_f(zero_flag),
        .neg_f(neg_flag),
        .eq_f(eq_flag)
    );

    always @(posedge clk) begin
        if (reset)
            comp_val <= 1'b0;
        else if (opcode == 3'b001) 
            comp_val <= eq_flag;
    end
     
    
    endmodule