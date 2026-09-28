# 4-Bit-Verilog-CPU
A simple 4 bit cpu that I made in verilog that has it's own custom ISA

Over the summer I've taken the time to make this with no experience with computer architecture. With the help of AI and Ben Eater(shout out to the goat). 
I made this pretty simple CPU that counts from 1 to 10 in a loop.

**CUSTOM ISA**


For this, I decided to make a small, but usable ISA for this that I've listed below along with the assembly code the CPU needs:

  
  - 000: ADD (R0 = R0 + R1)
  - 001: COMP (compare R0 to R1, uses flags)
  - 010: JMP (jump, PC = address)
  - 011: JEQ (jump if equal flag is up)
  - 100: LI (load immediate (loads a specific value directly into the register, hence the immediate))


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

The main program I'm using is 'programs.mem'. This converts the instructions above into binary:

      Here is that and what each instruction does:
            10000000 //li 0 to r0
            00000010 //add 1 to r0 i.e r0 = r0 + 1
            00110100 //compare r0 to 10
            01101010 //jeq to instruction 5(reset)
            01000010 //jmp to instruction 1(loop)
            10000000 //li 0 to r0
            01000010 //jmp to instruction 1(loop)
            00000000 //program has ended, so auto to default instruction
            00000000
            00000000
            00000000
            00000000
            00000000
            00000000
            00000000
            

**HOW TO RUN** 

1. Download Icarus Verilog:
      I used Icarus to write all my code. Here's a guide to install: https://steveicarus.github.io/iverilog/usage/installation.html

2. Clone the repo: 
      `git clone git@github.com:mohamedzarooq/4-Bit-Verilog-CPU.git`


3. Compile code(I added all modules in cpu file to make it easier):
      `iverilog -o cpu_sim.vvp cpu.v cpu_tb.v`

4. Run the VVP file:
      `vvp cpu_sim.vvp`

5. To use waveform run GTKWave(This will also need to be installed):
      `gtkwave`
