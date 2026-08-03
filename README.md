# 4-Bit-Verilog-CPU
A simple 4 bit cpu that I made in verilog that has it's own custom ISA catered to count from 0 to 10 in a loop

Over the summer I've taken the time to make this with no experience with computer architecture. With the help of AI and Ben Eater(shout out to the goat). 
I made this pretty simple CPU that counts from 1 to 10 in a loop.

**CUSTOM ISA**


For this, I decided to make a small, but usable ISA for this that I've listed below along with the assembly code the CPU needs:

  
  - 000: ADD //R0 = R0 + R1
  - 001: COMP //compare R0 to R1, flags
  - 010: JMP //jump, PC = address
  - 011: JEQ //jump if equal flag is up
  - 100: LI //load immediate (loads a specific value directly into the register, hence the immediate)


  This 3 bit ISA was enough to count in a loop properly


  Instructions:
      1. LI R0, 1
      LOOP:
      2. ADD R0, 1
      3. COMP R0, 10
      4. JEQ RESET
      5. JMP, address 2
      RESET:
      6. LI R0, 0
      7. JMP LOOP


**MODULES**


For this CPU, there are 5 different modules/parts needed to make this work: The ALU(Arithmetic Logic Unit), CU(Control Unit), IM(Instruction Memory), PC(Program Counter), and registers.
Here's each of those verilog codes listed down below:

**ALU**


Does all the math the CPU needs to perform properly.
I went ahead and added the 4 bit adder module that I used for the arithmetic of the ALU:


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
        2'b00 : begin
            y = sum; //add
            cout = carry;
        end
        2'b01 : begin
            y = sum; //subtract
            cout = ~carry;       
        end
        2'b10 : begin
            y = (a < b) ? 4'b0001 : (a > b) ? 4'b0010 : 4'b0100; //compare(basically a mux)
            cout = 0;
        end
        2'b11 : begin
            y = a ^ b; //xor since i can't do much else
            cout = 0;
        end
        default: begin
            y = 4'b0000; //default: just sets both to 0
            cout = 1'b0;
        end
        endcase
    end
    
    
    endmodule


**CONTROL UNIT**


Like the brain, it sends proper signals to the correct module depending on the instruction in memory

    module control_unit(input [2:0] opcode, output reg reg_write, 
    output reg [1:0] alu_op, output reg alu_src, 
    output reg  jump, output reg jump_cond);
    always@(*)
    begin
        reg_write = 0;
        alu_src = 0;
        alu_op = 2'b00;
        jump = 0;
        jump_cond = 0;
    case(opcode)
    
    3'b000 : begin //add
        alu_op = 2'b00;
        reg_write = 1;
        alu_src = 1;
    end
    3'b001 : begin //comp
        alu_op = 2'b10;
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
    end
    
    endcase
    
    
    
    
    
    end
    
    
    
    endmodule
    

**INSTRUCTION MEMORY**


Since this is based on the ISA, I have underscores that cut off what each portion of the address is supposed to represent:

    module instruction_memory(input [3:0] addr, output reg [7:0] instr);

    always @(*) begin
      //count from 0 to 10. i need to increment, store, and output, then loop back to 0 once at 10. ADD(00), LOAD(10), STORE(01), JUMP(11)

    case(addr) 
                      //What the values of the address mean: ###(ISA)_####(value)_#(register)
        4'b0000 : instr = 8'b100_0001_0; //li 1 to r0
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

**PROGRAM COUNTER**

This is necessary for the CPU to know which address to fetch:

    module program_counter(input clk, input reset, input jump, input jump_cond, input [3:0] jump_add, input count_en, input zero_flag, output reg [3:0] pc_out);

      wire [3:0] next_pc;
      wire [3:0] increment;
      wire pc_takejump;

      assign increment = pc_out + 1;
      assign pc_takejump = jump & (jump_cond ? zero_flag : 1'b1); //for jeq in isa
      assign next_pc = pc_takejump ? jump_add : increment; //jump to new address if enabled
        
    
      always @(posedge clk) begin
            if (reset)
                pc_out <= 0;
            else if (count_en)
                pc_out <= next_pc;
        end
        
    
    endmodule

**REGISTERS**

Needed to actually hold the data the CPU requires:

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
    

    //This is very important so that the ALU knows which register to fetch data from


    module reg_sel(input [3:0] d, input clk, input sel, input en, input reset, output wire [3:0] q0, output wire [3:0] q1, output [3:0] mux_out);  
    
    wire [3:0] notq0, notq1;
    wire en0, en1;
    assign en0 = en & ~sel; //chooses which register to write from
    assign en1 = en & sel;
    
    register R0 (.d(d), .clk(clk), .en(en0), .reset(reset), .q(q0), .notq(notq0));
    register R1 (.d(d), .clk(clk), .en(en1), .reset(reset), .q(q1), .notq(notq1));
    
    assign mux_out = sel ? q1 : q0;
    
    
    
    endmodule


Combining all of these together through a mini bus (mainly just a few wires) here is the CPU module itself with each of the previous instantiated within:


    module cpu();
    
    wire [3:0] pc_out;
    wire [7:0] instr;
    
    program_counter PC (
        .clk(clk),
        .reset(reset),
        .jump(jump),
        .jump_cond(jump_cond),
        .jump_add(instr[4:1]),
        .count_en(1'b1),
        .zero_flag(zero_flag),
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
    wire [1:0] alu_op;
    
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
     
    
    endmodule

**Verification**

Since Icarus Verilog has limited SystemVerilog capabilities, I mainly used Verilog for the testbenches as well as GTKWave for visual representation


The first testbench I did was making sure the program counter is working properly. Since there is a jump in order for my CPU to do as I intended, I manually checked the expected sequence. While this isn't the best way of checking this, this was the easiest for right now: 
    
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


  When I ran the test everything passed which shows that the jump and my ISA is translating correctly over to my PC. In the future I will probably implement and see if the zero flag is up as this is a better way of checking rather than manually entering what I expect.


  **ALU Verification**

Now I've implemented a ALU testbench to verify that my ALU outputted the correct values based on the opcode given: either ADD, SUB, COMP, or XOR. I did this by utilizing nested for loops to test every possible combination and see if there was error:

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

Running this test using my ALU module all tests passed which verifies my ALU's functionality.



  


  
