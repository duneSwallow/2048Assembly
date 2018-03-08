

.data 
fin: .asciiz "input.txt" # for writing moves

.text
.globl _start

_start:

li $s5, 0xffff0000

li $a0, 0xffff0000
li $a1, 4
li $a2, 5
jal clear_board
beq $v0, -1, ExitForever

move $a0, $v0
li $v0, 1
syscall

li $s0, 0 #row counter
fillCol:
bge $s0, 4, exitFillCol
li $a0, 0xffff0000
li $a1, 4
li $a2, 4
move $a3, $s0
addi $sp, $sp, -8
li $t1, 2
sw $t1, ($sp)
li $t0, 2
sw $t0, 4($sp)
jal place
move $a0, $v0
li $v0, 1
syscall
addi $sp, $sp, 8
addi $s0, $s0, 1
j fillCol
exitFillCol:	

li $s0, 0 #col counter
fillRow:
bge $s0, 4, exitFillRow
li $a0, 0xffff0000
li $a1, 4
li $a2, 4
li $a3, 2
addi $sp, $sp, -8
sw $s0, ($sp)
li $t0, 2
sw $t0, 4($sp)
jal place
move $a0, $v0
li $v0, 1
syscall
addi $sp, $sp, 8
addi $s0, $s0, 1
j fillRow
exitFillRow:	

li $a0, 0xffff0000
li $a1, 4
li $a2, 4
li $a3, 3
addi $sp, $sp, -8
li $t1, 2
sw $t1, ($sp)
li $t0, -1
sw $t0, 4($sp)
jal place
move $a0, $v0
li $v0, 1
syscall
addi $sp, $sp, 8


gameLoop:
li $v0, 12 # read move
syscall
beq $v0, 'e', ExitForever
beq $v0, 'D', move
beq $v0, 'U', move
beq $v0, 'R', move
beq $v0, 'L', move
j ExitForever

move:
move $a0, $s5 # base_address
li $a1, 4 # num_rows
li $a2, 4 # num_cols
move $a3, $v0 
jal user_move
move $s0, $v0
move $s1, $v1
move $a0, $s0
li $v0, 1
syscall
move $a0, $s1
li $v0, 1
syscall


j gameLoop







ExitForever:
li $v0, 10
syscall

.include "hw4.asm"
