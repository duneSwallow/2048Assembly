
##############################################################
# Homework #4
# name: Luke Cesario	
# sbuid: 111009439
##############################################################
.text

##############################
# PART 1 FUNCTIONS
##############################


# int getAddressOf(cell[][] board, int n_cols, int row, int col)
# uses algorithm from hw4 details (helper method)
getAddressOf:
	li $t0, 2 # size of obj in cell
	mul $t1, $a1, $t0 #row_size = n_cols * obj_size
	mul $t1, $t1, $a2 # row_size * row
	mul $t2, $t0, $a3 #obj_size * col
	add $t1, $a0, $t1 #base_address + row_size*row
	add $t1, $t1, $t2 # above line + obj_size*col
	move $v0, $t1 #return address
	jr $ra

# int clear_board(cell[][] board, int num_rows, int num_cols)
# This function will clear the board, setting all the cells 
# of the board to empty cells (-1).
clear_board:
	addi $sp, $sp, -28
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)

	blt $a1, 2, ErrorInClear	# num_rows and num_cols must be less than 2
	blt $a2, 2, ErrorInClear

	move $s0, $a0 # base address
	move $s1, $a1 # num_rows
	move $s2, $a2 # num_cols	

	li $s5, -1 #empty cell value

	move $s3, $0 # row counter
	loopThroughRows:
		bge $s3, $s1, cleared
		move $s4, $0 # col. counter
		loopThroughColumns:
			bge $s4, $s2, leaveColLoop
			move $a0, $s0 #base_address
			move $a1, $s1 #num_rows
			move $a2, $s2 #num_cols
			move $a3, $s3 #row
			addi $sp, $sp, -8
			sw $s4, ($sp) #col
			sw $s5, 4($sp) #value (-1)
			jal place # place the value in the cell
			lw $s4, ($sp)
			lw $s5, 4($sp)
			addi $sp, $sp, 8
			beq $v0, -1, ErrorInClear
			addi $s4, $s4, 1 #increment column counter
			j loopThroughColumns
		leaveColLoop:
		addi $s3, $s3, 1 #increment row counter
		j loopThroughRows
	cleared:


	li $v0, 0
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	jr $ra
	ErrorInClear:
	li $v0, -1
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	jr $ra
	

# int place(int[][] board, int n_rows, int n_cols, int row, int col, int val)
place:
	lw $t0, ($sp) # col
	lw $t1, 4($sp)	# val	
	blt $a1, 2, ErrorInPlace # n_rows < 2 ?
	blt $a2, 2, ErrorInPlace # n_cols < 2 ?	
	bltz $a3, ErrorInPlace # row < 0 ?
	bltz $t0, ErrorInPlace # col < 0 ?
	addi $t3, $a1, -1 # n_rows - 1
	bgt $a3, $t3, ErrorInPlace # row > n_rows-1 ? 
	addi $t3, $a2, -1 # n_cols - 1
	bgt $t0, $t3, ErrorInPlace # col > n_cols-1 ? 
	li $t3, -1 	
	beq $t1, $t3, NoErrorInPlace # val == -1 ?
	blt $t1, 2, ErrorInPlace # val <= 2 ?
	
	#algorithm from class resources
	move $t2, $0 # num of 1s in value
	li $t3, 1 # position of the 1
	move $t4, $0 # loop counter
	isEvenLoop:	
		bgt $t2, 1, ErrorInPlace # exit if not even
		bge $t4, 32, NoErrorInPlace # check complete (32 = word.len) 
		and $t5, $t3, $t1 # is ther a 1 in the postion indicated by $t3?
		beqz $t5, notOne #if there isnt a one loop again
			addi $t2, $t2, 1 # increment num of ones
		notOne:
		sll $t3, $t3, 1 # next postion of 1
		addi $t4, $t4, 1 #increment loop counter
		j isEvenLoop

	NoErrorInPlace: # all errors checked
	#get address we want to store value at in array
	# $a0 is base address
	# calculate row_size
	li $t3, 2
	mul $t2, $a2, $t3 # row_size = n_cols * size_of(obj), hw
	mul $t2, $t2, $a3 # row_size * row
	mul $t3, $t3, $t0 # size_of(obj) * col
	add $t2, $t2, $t3 # (row_size*row)+(size_of(obj)*col)
	add $t2, $a0, $t2 # base_address + (above result)
	# $t2 is obj_addr[row][col]
	sh $t1, 0($t2) # load value into address calculated above
	
	li $v0, 0
	jr $ra # No error: return 0 with value now stored correctly
 	ErrorInPlace:
	li $v0, -1
	jr $ra


# int start_game(cell[][] board, int num_rows, int num_cols, int r1, int c1, int r2, int c2)
# This function will start a game by calling clear_board first and then placing two starting
# values (the starting value is 2), one at (r1,c1) and another at (r2,c2).
start_game:
	lw $t4, ($sp) # c1
	lw $t5, 4($sp) # r2
	lw $t6, 8($sp) # c2
	addi $sp, $sp, -32
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp) 
	sw $s5, 20($sp) 
	sw $s6, 24($sp)
	sw $ra, 28($sp)
	move $s4, $t4
	move $s5, $t5
	move $s6, $t6
	
	move $s0, $a0 # base_address
	move $s1, $a1 # num_rows
	move $s2, $a2 # num_cols
	move $s3, $a3 # r1
	#arguments are already in correct place
	jal clear_board
	beq $v0, -1, ErrorInStart
	
	move $a0, $s0 # base_address
	move $a1, $s1 # num_rows
	move $a2, $s2 # num_cols
 	move $a3, $s3 # r1
	addi $sp, $sp, -8
	sw $s4, ($sp) # c1
	li $t0, 2 # start value
	sw $t0, 4($sp) # value
	jal place	
	addi $sp, $sp, 8
	beq $v0, -1, ErrorInStart
	
	move $a0, $s0 # base_address
	move $a1, $s1 # num_rows
	move $a2, $s2 # num_cols
 	move $a3, $s5 # r2
	addi $sp, $sp, -8
	sw $s6, ($sp) # c2
	li $t0, 2 # start value
	sw $t0, 4($sp) # value
	jal place	
	addi $sp, $sp, 8
	beq $v0, -1, ErrorInStart

	li $v0, 0 #no error

	ErrorInStart:
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp) 
	lw $s5, 20($sp) 
	lw $s6, 24($sp)
	lw $ra, 28($sp)
	addi $sp, $sp, 32
	jr $ra

##############################
# PART 2 FUNCTIONS
##############################

# int merge_row(cell[][] board, int num_rows, int num_cols, int row, int direction)
merge_row:
	lw $t0, ($sp)
	addi $sp, $sp, -36
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp)	
	move $s4, $t0
		
	beqz $s4, goodRowDirection
	bne $s4, 1, ErrorInMergeRow # direction must equal 0 or 1
	goodRowDirection:
	blt $a1, 2, ErrorInMergeRow # necessary: num_rows >= 2
	blt $a2, 2, ErrorInMergeRow # necessary: num_cols >= 2 
	bltz $a3, ErrorInMergeRow # row < 0 ?
	bge $a3, $a1, ErrorInMergeRow # necessary: row < num_rows 
	# no argument errors
	move $s0, $a0 # base_address
	move $s1, $a1 # num_rows
	move $s2, $a2 # num_cols
	move $s3, $a3 # row
	# $s4 = direction
	beq $s4, 1, mergeRightToLeft
	# left to right:
	
		li $s5, 0 # column counter
		li $s4, 0 # nonEmptyCell counter
	mergeLtRloop:
		addi $t0, $s2, -2 #last possible column# needed
		bgt $s5, $t0, ExitMergeRow # col_counter > last needed ?
		move $a0, $s0 # base_address 
		move $a1, $s2 # num_cols
		move $a2, $s3 # row
		move $a3, $s5 # col (the changing variable here)
		jal getAddressOf # get address of next cell
		lh $s6, ($v0) # load that cell
		lh $s7, 2($v0)	# load the cell to its right
		bne $s6, $s7, dontMergeCellLtR # are the cell values equal?
		beq $s6, -1, dontMergeCellLtR # no merging next to empty cells
		beq $s7, -1, dontMergeCellLtR 
		add $s6, $s6, $s6 # double cell on left
		li $s7, -1 # right cell is now empty
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s3 # row
		addi $sp, $sp, -8
		sw $s5, ($sp) # col
		sw $s6, 4($sp) # value (doubled cell)
		jal place
		beq $v0, -1, ErrorInMergeRow
		addi $sp, $sp, 8
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s3 # row
		addi $sp, $sp, -8
		addi $t0, $s5, 1
		sw $t0, ($sp) # col
		sw $s7, 4($sp) # value (doubled cell)
		jal place
		beq $v0, -1, ErrorInMergeRow
		addi $sp, $sp, 8
		dontMergeCellLtR:
		addi $s5 $s5, 1 #increment column
		j mergeLtRloop # loop back around

	mergeRightToLeft:
		addi $s5, $s2, -1 #column counter starting at num-cols - 1
	mergeRtLloop:
		blt $s5, 1, ExitMergeRow # col_counter > last needed ?
		move $a0, $s0 # base_address 
		move $a1, $s2 # num_cols
		move $a2, $s3 # row
		addi $t0, $s5, -1 # we want to get address of left cell of the pair
		move $a3, $t0 # col (the changing variable here)
		jal getAddressOf # get address of next cell
		lh $s6, ($v0) # load that cell
		lh $s7, 2($v0)	# load the cell to its right
		bne $s6, $s7, dontMergeCellRtL # are the cell values equal?
		beq $s7, -1, dontMergeCellRtL # no merging next to empty cells
		beq $s6, -1, dontMergeCellRtL 
		add $s7, $s7, $s7 # double cell on right
		li $s6, -1 # left cell is now empty
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s3 # row
		addi $sp, $sp, -8
		addi $t0, $s5, -1
		sw $t0, ($sp) # col
		sw $s6, 4($sp) # value (doubled cell)
		jal place
		beq $v0, -1, ErrorInMergeRow
		addi $sp, $sp, 8
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s3 # row
		addi $sp, $sp, -8
		sw $s5, ($sp) # col
		sw $s7, 4($sp) # value (doubled cell)
		jal place
		beq $v0, -1, ErrorInMergeRow
		addi $sp, $sp, 8
		dontMergeCellRtL:
		addi $s5 $s5, -1 #decrement column
		j mergeRtLloop # loop back around
	
	ExitMergeRow:
		move $s4, $0 # non empty cell counter
		move $s5, $0 # col counter
	countNonEmptyMergeRowLoop:	
		bge $s5, $s2, returnNumNonEmptyMergeRow
		move $a0, $s0 # base_address 
		move $a1, $s2 # num_cols
		move $a2, $s3 # row
		move $a3, $s5 # col (the changing variable here)
		jal getAddressOf # get address of next cell
		lh $s6, ($v0) # load that cell
		beq $s6, -1, nextCountNonEmptyMergeRowLoop
		addi $s4, $s4, 1 # increment num of non empty cells
		nextCountNonEmptyMergeRowLoop:
		addi $s5, $s5, 1 # increment col counter
		j countNonEmptyMergeRowLoop
	returnNumNonEmptyMergeRow:
	move $v0, $s4
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
   jr $ra
    
	ErrorInMergeRow:
	li $v0, -1
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
   jr $ra

# int merge_col(cell[][] board, int num_rows, int num_cols, int col, int direction)
merge_col:
	lw $t0, ($sp)
	addi $sp, $sp, -36
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp)
	move $s4, $t0	# dir
	
	beqz $s4, goodColDirection
	bne $s4, 1, ErrorInMergeCol # direction must equal 0 or 1
	goodColDirection:
	blt $a1, 2, ErrorInMergeCol # necessary: num_rows >= 2
	blt $a2, 2, ErrorInMergeCol # necessary: num_cols >= 2 
	bltz $a3, ErrorInMergeCol # col < 0 ?
	bge $a3, $a2, ErrorInMergeCol # necessary: col < num_cols 
	# no argument errors
	move $s0, $a0 # base_address
	move $s1, $a1 # num_rows
	move $s2, $a2 # num_cols
	move $s3, $a3 # col
	# $s4 = direction
	beq $s4, 1, mergeTopToBottom
	# bottom to top:
		addi $s5, $s1, -1 #row counter starting at num_rows - 1
	mergeBtTloop:
		blt $s5, 1, ExitMergeCol # row_counter > last needed ?

		move $a0, $s0 # base_address 
		move $a1, $s2 # num_cols
		move $a2, $s5 # row (the changing variable here)
		move $a3, $s3 # col 
		jal getAddressOf # get address of bottom cell of the pair
		lh $s6, ($v0) # load the bottom cell

		move $a0, $s0 # base_address 
		move $a1, $s2 # num_cols
		addi $t0, $s5, -1 # we want to get address of top cell of the pair
		move $a2, $t0 # row (the changing variable here)
		move $a3, $s3 # col 
		jal getAddressOf # get address of top cell of the pair
		lh $s7, ($v0) # load the top cell of the pair

		bne $s6, $s7, dontMergeCellBtT # are the cell values equal?
		beq $s6, -1, dontMergeCellBtT # no merging next to empty cells
		beq $s7, -1, dontMergeCellBtT 

		add $s6, $s6, $s6 # double cell on bottom
		li $s7, -1 # left cell is now empty
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s5 # row
		addi $sp, $sp, -8
		sw $s3, ($sp) # col
		sw $s6, 4($sp) # value (doubled cell)
		jal place
		beq $v0, -1, ErrorInMergeCol
		addi $sp, $sp, 8
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		addi $t0, $s5, -1
		move $a3, $t0 # row
		addi $sp, $sp, -8
		sw $s3, ($sp) # col
		sw $s7, 4($sp) # value (doubled cell)
		jal place
		beq $v0, -1, ErrorInMergeCol	
		addi $sp, $sp, 8
		dontMergeCellBtT:
		addi $s5, $s5, -1 #decrement row
		j mergeBtTloop # loop back around

	mergeTopToBottom:
		li $s5, 0 #row counter
	mergeTtBloop:
		addi $t0, $s1, -2 #last possible row# needed
		bgt $s5, $t0, ExitMergeCol # row_counter > last needed ?
		move $a0, $s0 # base_address 
		move $a1, $s2 # num_cols
		move $a2, $s5 # row
		move $a3, $s3 # col (the changing variable here)
		jal getAddressOf # get address of next cell
		lh $s6, ($v0) # load that cell
		move $a0, $s0 # base_address 
		move $a1, $s2 # num_cols
		addi $t0, $s5, 1
		move $a2, $t0 # row (the changing variable here)
		move $a3, $s3 # col 
		jal getAddressOf # get address of next cell
		lh $s7, ($v0)	# load the cell underneath
		bne $s6, $s7, dontMergeCellTtoB # are the cell values equal?
		beq $s6, -1, dontMergeCellTtoB # no merging next to empty cells
		beq $s7, -1, dontMergeCellTtoB 
		add $s6, $s6, $s6 # double cell on top
		li $s7, -1 # bottom cell is now empty
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s5 # row
		addi $sp, $sp, -8
		sw $s3, ($sp) # col
		sw $s6, 4($sp) # value (doubled cell)
		jal place
		beq $v0, -1, ErrorInMergeCol
		addi $sp, $sp, 8
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		addi $t0, $s5, 1
		move $a3, $t0 # row
		addi $sp, $sp, -8
		sw $s3, ($sp) # col
		sw $s7, 4($sp) # value (doubled cell)
		jal place
		beq $v0, -1, ErrorInMergeCol
		addi $sp, $sp, 8
		dontMergeCellTtoB:
		addi $s5 $s5, 1 #increment row
		j mergeTtBloop # loop back around
		
		
	ExitMergeCol:
	li $s4, 0 # numOfNonEmptyCells
	li $s5, 0 # row counter
	countNonEmptyMergeColLoop:	
		bge $s5, $s1, returnNumNonEmptyMergeCol
		move $a0, $s0 # base_address 
		move $a1, $s2 # num_cols
		move $a2, $s5 # row (the changing variable here)
		move $a3, $s3 # col 
		jal getAddressOf # get address of next cell
		lh $s6, ($v0) # load that cell
		beq $s6, -1, nextCountNonEmptyMergeColLoop
		addi $s4, $s4, 1 # increment num of non empty cells
		nextCountNonEmptyMergeColLoop:
		addi $s5, $s5, 1 # increment row
		j countNonEmptyMergeColLoop
	returnNumNonEmptyMergeCol:
	move $v0, $s4
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
   jr $ra
    
	ErrorInMergeCol:
	li $v0, -1
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
   jr $ra

   
# int shift_row(cell[][] board, int num_rows, int num_cols, int row, int direction)
shift_row:
	lw $t0, ($sp) # direction
	addi $sp, $sp, -36
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp) # this function calls other functions
	move $s0, $a0 # base_address
	move $s1, $a1 # num_rows
	move $s2, $a2 # num_cols
	move $s3, $a3 # row
	move $s4, $t0 # dir
	bltz $s3, ErrorInShiftRow # row < 0 ?
	bge $s3, $s1, ErrorInShiftRow # row >= num_rows ?
	blt $s1, 2, ErrorInShiftRow # num_rows < 2 ?
	blt $s2, 2, ErrorInShiftRow # num_cols < 2 ?
	beqz $s4, shiftRowArgsGood # direction == 0 ?
	bne $s4, 1, ErrorInShiftRow # direction != 1 ?
	shiftRowArgsGood: # no argument errors
	beq $s4, 1, shiftRowRight
	#shift left:
		li $s5, 1 # col index
		li $s7, 0 # num of shifted cells
		li $s1, 0 # set shifted to false
	shiftRowLeftLoop:
		bge $s5, $s2, ExitShiftRow # col index >= num_cols ?
		move $a0, $s0 # base_address
		move $a1, $s2 # num_cols
		move $a2, $s3 # row
		move $a3, $s5 # col (variable)
		jal getAddressOf
		lh $s6, ($v0) # value at [row][cell]
		beq $s6, -1, nextShiftRowLeftLoop
			addi $s4, $s5, -1 # shift index
		shiftCellLeftLoop:
			blt $s4, $0, nextShiftRowLeftLoop # col index < 0 ?
			move $a0, $s0 # base_address
			move $a1, $s2 # num_cols
			move $a2, $s3 # row
			move $a3, $s4 # col (variable)
			jal getAddressOf
			lh $t0, ($v0) # value to left of cell to be shifted
			bne $t0, -1, nextShiftRowLeftLoop
			sh $s6, ($v0) # move right value into left cell
			li $t1, -1 # empty cell
			sh $t1, 2($v0) # make the right cell now empty
			li $s1, 1 # set shifted to true since a cell was shifted
			addi $s4, $s4, -1 # decrement shift index
			j shiftCellLeftLoop
		nextShiftRowLeftLoop:
		bne $s1, 1, noShiftLeft # was a cell shifted?
		addi $s7, $s7, 1 # increment shifted cell counter
		noShiftLeft:
		li $s1, 0 # set shifted to false
		addi $s5, $s5, 1 # increment col index
		j shiftRowLeftLoop
	shiftRowRight:
		addi $s5, $s2, -2 # col index
		li $s7, 0 # num of shifted cells 
		li $s1, 0 # set shifted to false
	shiftRowRightLoop:
		blt $s5, 0, ExitShiftRow # col index <= 0 ?
		move $a0, $s0 # base_address
		move $a1, $s2 # num_cols
		move $a2, $s3 # row
		move $a3, $s5 # col (variable)
		jal getAddressOf
		lh $s6, ($v0) # value at [row][cell]
		beq $s6, -1, nextShiftRowRightLoop
			move $s4, $s5 # shift index
		shiftCellRightLoop:
			addi $t0, $s2, -1
			bge $s4, $t0, nextShiftRowRightLoop # col index > num_cols ?
			move $a0, $s0 # base_address
			move $a1, $s2 # num_cols
			move $a2, $s3 # row
			move $a3, $s4 # col (variable)
			jal getAddressOf
			lh $t0, 2($v0) # value to the right of cell to be shifted
			bne $t0, -1, nextShiftRowRightLoop
			sh $s6, 2($v0) # move left value into right cell
			li $t1, -1 # empty cell
			sh $t1, ($v0) # make the left cell now empty
			li $s1, 1 # set shifted to true since a cell was shifted
			addi $s4, $s4, 1 # increment shift index
			j shiftCellRightLoop
		nextShiftRowRightLoop:
		bne $s1, 1, noShiftRight # was a cell shifted?
		addi $s7, $s7, 1 # increment shifted cell counter
		noShiftRight:
		li $s1, 0 # set shifted to false
		addi $s5, $s5, -1 # decrement col index
		j shiftRowRightLoop
	ExitShiftRow:
	move $v0, $s7 # return num of shifted cells
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
   jr $ra
	ErrorInShiftRow:
	li $v0, -1
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
   jr $ra


# int shift_col(cell[][] board, int num_rows, int num_cols, int col, int direction)
shift_col:
	lw $t0, ($sp) # direction
	addi $sp, $sp, -36
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp) # this function calls other functions
		
	move $s0, $a0 # base_address
	move $s1, $a1 # num_rows
	move $s2, $a2 # num_cols
	move $s3, $a3 # col
	move $s4, $t0 # dir

	bltz $s3, ErrorInShiftCol # col < 0 ?
	bge $s3, $s2, ErrorInShiftCol # col >= num_cols ?
	blt $s1, 2, ErrorInShiftCol # num_rows < 2 ?
	blt $s2, 2, ErrorInShiftCol # num_cols < 2 ?
	beqz $s4, shiftColArgsGood # direction == 0 ?
	bne $s4, 1, ErrorInShiftCol # direction != 1 ?
	shiftColArgsGood: # no argument errors
	beq $s4, 1, shiftColDown
	#shift up:
		li $s5, 1  # row index
		li $s7, 0 # num of shifted cells
		li $t6, 0 # set shifted to false
	shiftColUpLoop:
		bge $s5, $s1, ExitShiftCol # row index >= num_rows ?
		move $a0, $s0 # base_address
		move $a1, $s2 # num_cols
		move $a2, $s5 # row (variable)
		move $a3, $s3 # col 
		addi $sp, $sp, -4
		sw $t6, ($sp)
		jal getAddressOf
		lw $t6, ($sp)
		addi $sp, $sp, 4
		lh $s6, ($v0) # value at [row][cell]
		beq $s6, -1, nextShiftColUpLoop

			addi $s4, $s5, -1 # shift index
		shiftCellUpLoop:
			blt $s4, $0, nextShiftColUpLoop # row index < 0 ?
			move $a0, $s0 # base_address
			move $a1, $s2 # num_cols
			move $a2, $s4 # row (variable)
			move $a3, $s3 # col
			addi $sp, $sp, -4
			sw $t6, ($sp) 
			jal getAddressOf
			lw $t6, ($sp)
			addi $sp, $sp, 4
			move $t2, $v0 

			move $a0, $s0 # base_address
			move $a1, $s2 # num_cols
			addi $t3, $s4, 1 # row below top
			move $a2, $t3 # row (variable)
			move $a3, $s3 # col 
			addi $sp, $sp, -8
			sw $t2, ($sp)
			sw $t6, 4($sp)
			jal getAddressOf
			lw $t2, ($sp)
			lw $t6, 4($sp)
			addi $sp, $sp, 8
			move $t3, $v0 
			lh $t4, ($t2) # value in cell on top
			lh $t5, ($t3) # value in cell on bottom
			
			bne $t4, -1, nextShiftColUpLoop # is top cell empty ?
			sh $s6, ($t2) # move bottom value into top cell
			li $t1, -1 # empty cell
			sh $t1, ($t3) # make the bottom cell now empty
			li $t6, 1 # set shifted to true since a cell was shifted
			addi $s4, $s4, -1 # decrement shift index
			j shiftCellUpLoop
		nextShiftColUpLoop:
		bne $t6, 1, noShiftUp # was a cell shifted?
		addi $s7, $s7, 1 # increment shifted cell counter
		noShiftUp:
		li $t6, 0 # set shifted to false
		addi $s5, $s5, 1 # increment row index
		j shiftColUpLoop

	shiftColDown:
		addi $s5, $s1, -2 # row index
		li $s7, 0 # num of shifted cells 
		li $t6, 0 # set shifted to false
	shiftColDownLoop:
		blt $s5, 0, ExitShiftRow # row index <= 0 ?
		move $a0, $s0 # base_address
		move $a1, $s2 # num_cols
		move $a2, $s5 # row (variable)
		move $a3, $s3 # col 
		addi $sp, $sp, -4
		sw $t6, ($sp)
		jal getAddressOf
		lw $t6, ($sp)
		addi $sp, $sp, 4
		lh $s6, ($v0) # value at [row][cell]
		beq $s6, -1, nextShiftColDownLoop

			move $s4, $s5 # shift index
		shiftCellDownLoop:
			addi $t0, $s1, -1
			bge $s4, $t0, nextShiftColDownLoop # col index >= num_rows ?
			move $a0, $s0 # base_address
			move $a1, $s2 # num_cols
			move $a2, $s4 # row (variable)
			move $a3, $s3 # col
			addi $sp, $sp, -4
			sw $t6, ($sp) 
			jal getAddressOf
			lw $t6, ($sp)
			addi $sp, $sp, 4
			move $t2, $v0 
			
			move $a0, $s0 # base_address
			move $a1, $s2 # num_cols
			addi $t0, $s4, 1
			move $a2, $t0 # row (variable)
			move $a3, $s3 # col 
			addi $sp, $sp, -8
			sw $t2, ($sp)
			sw $t6, 4($sp)
			jal getAddressOf
			lw $t2, ($sp)
			lw $t6, 4($sp)
			addi $sp, $sp, 8
			move $t3, $v0 
			lh $t4, ($t2) # value in cell on top
			lh $t5, ($t3) # value in cell on bottom

			bne $t5, -1, nextShiftColDownLoop
			sh $s6, ($t3) # move top value into bottom cell
			li $t1, -1 # empty cell
			sh $t1, ($t2) # make the top cell now empty
			li $t6, 1 # set shifted to true since a cell was shifted
			addi $s4, $s4, 1 # increment shift index
			j shiftCellDownLoop
		nextShiftColDownLoop:
		bne $t6, 1, noShiftDown # was a cell shifted?
		addi $s7, $s7, 1 # increment shifted cell counter
		noShiftDown:
		li $t6, 0 # set shifted to false
		addi $s5, $s5, -1 # decrement col index
		j shiftColDownLoop



   ExitShiftCol:
	move $v0, $s7 # return num of shifted cells
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
   jr $ra
	ErrorInShiftCol:
	li $v0, -1
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
   jr $ra


# int check_state(cell[][] board, int num_rows, int num_cols)
# This function checks the current state of the game. If any cell on the board has a value ?
# 2048, the game has been won. If all cells are full and no adjacent cells can be merged (no
# diagonals), the game has been lost.
# All inputs assumed valid
check_state:
	addi $sp, $sp, -36
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp)
	move $s0, $a0 # base_address
	move $s1, $a1 # num_rows
	move $s2, $a2 # num_cols
		# iterate by row
		move $s3, $0 # row counter
		move $s5, $0 # isMovesLeft == false
	checkStateRowLoop:
		bge $s3, $s1, ExitCheckStateLoop # row >= num_rows
		move $s4, $0 # col counter
		checkStateColLoop:
			#check cell
			bge $s4, $s2, ExitCheckColLoop
			move $a0, $s0 # base_address
			move $a1, $s2 # num_cols
			move $a2, $s3 # row
			move $a3, $s4 # col
			jal getAddressOf
			move $s6, $v0 # address of current cell
			lh $s7, ($s6) # value in cell	
			li $t4, 2048
			beq $s7, $t4, ExitVictorious # the game is won
			bne $s7, -1,  checkRightCell # still moves left
			li $s5, 1 # moves left	
			checkRightCell:
			addi $t0, $s4, 1 # cell to the right
			bge $t0, $s2, checkLeftCell
			lh $t1, 2($s6) # value to right 
			li $t4, 2048
			beq $t1, $t4, ExitVictorious
			beq $t1, -1, movePossibleRight # a shift is still possible
			beq $t1, $s7, movePossibleRight # a merge is still possible 
			j checkLeftCell
			movePossibleRight: li $s5, 1 #move left
			checkLeftCell:
			addi $t0, $s4, -1 # cell to the left
			blt $t0, $0, checkTopCell # cell < 0 ?
			addi $t2, $s6, -2 # address to the left
			lh $t1, ($t2) # cell value to the left
			li $t4, 2048
			beq $t1, $t4, ExitVictorious 
			beq $t1, $s7, movePossibleLeft # a merge is still possible
			beq $t1, -1, movePossibleLeft # still moves left
			j checkTopCell
			movePossibleLeft: li $s5, 1
			checkTopCell:
			addi $t0, $s3, -1 # row above cell
			blt $t0, $0, checkBottomCell
			move $a0, $s0 # base_address
			move $a1, $s2 # num_cols
			move $a2, $t0 # row
			move $a3, $s4 # col
			jal getAddressOf
			lh $t1, ($v0) # value in cell above
			li $t4, 2048
			beq $t1, $t4, ExitVictorious
			beq $t1, $s7, movePossibleTop # merge still possible
			beq $t1, -1, movePossibleTop # shift still possible
			j checkBottomCell
			movePossibleTop: li $s5, 1
			checkBottomCell:
			addi $t0, $s3, 1 # row below cell
			bge $t0, $s1, nextCheckStateColLoop # bttom row >= num_rows ?
			move $a0, $s0 # base_address
			move $a1, $s2 # num_cols
			move $a2, $t0 # row
			move $a3, $s4 # col
			jal getAddressOf
			lh $t1, ($v0) # value in cell above
			li $t4, 2048
			beq $t1, $t4, ExitVictorious
			beq $t1, $s7, movePossibleBottom # merge still possible
			beq $t1, -1, movePossibleBottom # shift still possible
			j nextCheckStateColLoop
			movePossibleBottom: li $s5, 1
			nextCheckStateColLoop:		
			addi $s4, $s4, 1 # increment col
			j checkStateColLoop
		ExitCheckColLoop:
		addi $s3, $s3, 1 # increment row
		j checkStateRowLoop 
	ExitCheckStateLoop:
	# no cell was empty, adjacent to an equal cell, or equal to 2048, therefore you lose
	beq $s5, 1, ExitNeutral # moves still left
	li $v0, -1 # exit as an utter loser
	j ExitCheckState
	ExitVictorious:
	li $v0, 1 # exit as the champion you were born to be
	j ExitCheckState
	ExitNeutral:
	li $v0, 0 # keep going. its not over.
	ExitCheckState:
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
	jr $ra # exit function

# (int, int) user_move(cell[][] board, int num_rows, int num_cols, char dir)
# This function simulates a user’s move. dir can be one of the following values: ‘L’, ‘R’,
# ‘U’ or ‘D’.
user_move:
	addi $sp, $sp, -36
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp)

	move $s0, $a0 # base_address
	move $s1, $a1 # num_rows
	move $s2, $a2 # num_cols
	move $s3, $a3 # char dir
	beq $s3, 'L', leftMove
	beq $s3, 'R', rightMove
	beq $s3, 'U', upMove
	beq $s3, 'D', downMove	
	j ExitErrorInUserMove # direction is an error
	
	leftMove:
	move $s4, $0 # row (iterate from top row to bottom row)
	moveLeftLoop:
		bge $s4, $s1, tilesInPlace # row >= num_rows 
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s4 # row
		addi $sp, $sp, -4
		sw $0, ($sp) # shift left
		jal shift_row
		addi $sp, $sp, 4
		beq $v0, -1, ExitErrorInUserMove # function reports an error
	
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s4 # row
		addi $sp, $sp, -4
		sw $0, ($sp) # merge row left to right
		jal merge_row
		addi $sp, $sp, 4
		beq $v0, -1, ExitErrorInUserMove # function reports an error
	
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s4 # row
		addi $sp, $sp, -4
		sw $0, ($sp) # shift left
		jal shift_row
		addi $sp, $sp, 4
		beq $v0, -1, ExitErrorInUserMove # function reports an error

		addi $s4, $s4, 1 # increment row
		j moveLeftLoop

	
	rightMove:
	move $s4, $0 # row (iterate from top row to bottom row)
	moveRightLoop:
		bge $s4, $s1, tilesInPlace # row >= num_rows 
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s4 # row
		addi $sp, $sp, -4
		li $t0, 1 # shift right
		sw $t0, ($sp) 
		jal shift_row
		addi $sp, $sp, 4
		beq $v0, -1, ExitErrorInUserMove # function reports an error
	
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s4 # row
		addi $sp, $sp, -4
		li $t0, 1 
		sw $t0, ($sp) # merge row right to left
		jal merge_row
		addi $sp, $sp, 4
		beq $v0, -1, ExitErrorInUserMove # function reports an error
	
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s4 # row
		addi $sp, $sp, -4
		li $t0, 1 # shift right
		sw $t0, ($sp)
		jal shift_row
		addi $sp, $sp, 4
		beq $v0, -1, ExitErrorInUserMove # function reports an error

		addi $s4, $s4, 1 # increment row
		j moveRightLoop
	
	upMove:
		move $s4, $0 # col iterate from left col to right col
	moveUpLoop:
		bge $s4, $s1, tilesInPlace # col >= num_col
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s4 # col
		addi $sp, $sp, -4
		sw $0, ($sp) # shift up
		jal shift_col
		addi $sp, $sp, 4
		beq $v0, -1, ExitErrorInUserMove # function reports an error
	
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s4 # col
		addi $sp, $sp, -4
		li $t0, 1 
		sw $t0, ($sp) # merge top to bottom
		jal merge_col
		addi $sp, $sp, 4
		beq $v0, -1, ExitErrorInUserMove # function reports an error
	
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s4 # col
		addi $sp, $sp, -4
		sw $0, ($sp) # shift up
		jal shift_col
		addi $sp, $sp, 4
		beq $v0, -1, ExitErrorInUserMove # function reports an error

		addi $s4, $s4, 1 # increment col
		j moveUpLoop
	
	downMove:
		move $s4, $0 # col iterate from left col to right col
	moveDownLoop:
		bge $s4, $s1, tilesInPlace # col >= num_col
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s4 # col
		addi $sp, $sp, -4
		li $t0, 1 # shift down
		sw $t0, ($sp)
		jal shift_col
		addi $sp, $sp, 4
		beq $v0, -1, ExitErrorInUserMove # function reports an error
	
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s4 # col
		addi $sp, $sp, -4
		sw $0, ($sp) # merge bottom to top
		jal merge_col
		addi $sp, $sp, 4
		beq $v0, -1, ExitErrorInUserMove # function reports an error
	
		move $a0, $s0 # base_address
		move $a1, $s1 # num_rows
		move $a2, $s2 # num_cols
		move $a3, $s4 # col
		addi $sp, $sp, -4 
		li $t0, 1 # shift down
		sw $t0, ($sp) 
		jal shift_col
		addi $sp, $sp, 4
		beq $v0, -1, ExitErrorInUserMove # function reports an error

		addi $s4, $s4, 1 # increment col
		j moveDownLoop

	tilesInPlace:
	move $a0, $s0 # base_address
	move $a1, $s1 # num_rows
	move $a2, $s2 # num_cols
	jal check_state
	move $v1, $v0 # return result of check_state
	li $v0, 0 # successful completion of function
	j ExitUserMove

	ExitErrorInUserMove:
	li $v0, -1 
	li $v1, -1
	ExitUserMove:
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36	
	jr $ra




