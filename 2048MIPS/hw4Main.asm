

.data 

.text
.globl _start

_start:

li $a0, 0xffff0000
li $a1, 4
li $a2, 4
li $a3, 1
li $t3, 1
li $t4, -1
li $t5, 20
addi $sp, $sp, -12
sw $t3, ($sp)
sw $t4, 4($sp)
sw $t5, 8($sp)
jal start_game
addi $sp, $sp, 12

move $a0, $v0
li $v0, 1
syscall

li $v0, 10
syscall

.include "hw4.asm"
