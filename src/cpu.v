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

    always @(posedge clk) begin
        if (reset)
            comp_zero <= 1'b0;
        else if (opcode == 3'b001) 
            comp_zero <= zero_flag;
    end
     
    
    endmodule