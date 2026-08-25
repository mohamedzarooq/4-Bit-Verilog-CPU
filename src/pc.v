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
