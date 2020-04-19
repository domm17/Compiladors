#!/bin/bash

bison -d bison.y
flex flex.l
gcc -o executable lex.yy.c bison.tab.c  symtab/symtab.c funcionsAuxiliars.c -lc -lfl -lm
./executable $1
