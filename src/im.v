module instruction_memory(input [3:0] addr, output reg [7:0] instr);

    always @(*) begin
      //count from 0 to 10. i need to increment, store, and output, then loop back to 0 once at 10. ADD(00), LOAD(10), STORE(01), JUMP(11)

    case(addr) 
                      //What the values of the address mean: ###(ISA)_####(value)_#(register)
        4'b0000 : instr = 8'b100_0000_0; //li 0 to r0
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
