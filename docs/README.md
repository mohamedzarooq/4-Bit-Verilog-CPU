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
