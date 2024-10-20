# Description

This project implements a simple calculator in x86 assembler that allows the user to multiply two integers.
The program uses system calls to interact with the user by displaying messages and reading input. 
It converts the entered strings to integers, performs the multiplication, then converts the result to a string for display.

# Features
- User Input: Asks the user to enter two integers (A and B).
- Multiplication: Performs multiplication of the two values.
- Display result: Displays the result of the multiplication in the console.

# Use
- Compilation: Uses an assembler such as NASM to assemble the code.
- Execution: Runs the program to enter the values ​​and get the result.

```
# To simply run the code :
user@linux:~/MultipliX-ASM$ ./assembler.sh MultipliX.s
Enter a value for A : 5
Enter a value for B : 6
Result : 30

# To debug the code with GDB :
user@linux:~/MultipliX-ASM$ ./assembler.sh MultipliX.s -g
GEF for linux ready, type `gef' to start, `gef config' to configure
93 commands loaded and 5 functions added for GDB 13.1 in 0.00ms using Python engine 3.11
Reading symbols from MultipliX...
(No debugging symbols found in MultipliX)
gef➤  b _start 
Breakpoint 1 at 0x401000
```
