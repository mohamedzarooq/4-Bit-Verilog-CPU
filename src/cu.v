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
    