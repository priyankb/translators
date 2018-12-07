# Translators assignment notes

## Assignment 1:
The full assignment is implemented and successfully scans all three Python files and displays the appropriate tokens. Moreover it utilizes a stack in order to accurately display all DEDENT tokens.

## Assignment 2:
In the second assignment we had to create a parser that gets the tokens from the scanner and applies a syntactic ruling them. The grammar rules were created using productions that would define various kinds of statements such as: assignments, while loops, if conditionals and break statements. Within each production, helper functions would take parameters from the Python file and translate each line into the C++ translation. Each statement would then be pushed into a vector of strings that would be outputted from the main file. Files p1.py and p3.py were able to flawlessly output the conversions, however there was an issue with else statements when trying to convert p2.py. My next step of action was to fix the else statement in the production and see if it was matching the tokens within the p2.py file.

## Assignment 3:
The goal of the third assignment was to create a tree structure that would represent the statements. A graphical version of the tree version of the tree was to be created using GraphViz. One incomplete portion of the assignment is the else statements, as it was not fixed from the previous assignment. However all the other statements are able to create nodes in a hierarchical manner accurately. Some nodes contain incorrect values such as curly braces around if statements and separate nodes for DEDENT tokens, which needed to be altered. The node structure also contained a value type that would have made GraphViz translation by assigning a specific numeric value for the different statements (assignment,while,if). My next task in this assignment would have been to assert that the node values were created without fault before proceeding to convert it to GraphViz for the graphical tree representation.

## Assignment 4:
A large portion of this assignment remained incomplete due to version issues. Problems arose when trying to generate target machine code and outputting it into a file. More issues came up when attempting to utilize the PassManager object in order to perform the optimizations that would have greatly reduced the size of the code. I strived to solve my problems by first downloading the newer version of LLVM onto my machine. However later realizing that I could not use the cmake command within Windows Powershell in order to build my LLVM environment. Given more time I aimed to download the pre-built binaries for Windows that would have allowed me to develop with LLVM locally. In regards to the assignment, I would have traversed the tree built in the previous assignment and created basic blocks for each of the statements such as conditionals. Harnessing the binaryOperation function for all statements that require computations. Finally I would apply the optimizations using a special -o flag and output the object code into another file. 
