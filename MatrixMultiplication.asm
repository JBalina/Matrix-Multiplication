#Jonathan Balina
#Extra Credit Project
#Write a recursive function to calculate the determinant of a square matrix nxn.



.data
	prompt1: .asciiz "Enter the dimension of your matrix: "
	message1: .asciiz "The size of your matrix is "
	x: .asciiz "x"
	prompt2: .asciiz "Enter elements to fill matrix: \n"
	message2: .asciiz "Your matrix is:\n"
	message3: .asciiz "The determinant of the matrix is: "
	newline: .asciiz "\n"
.text
main:
	li $v0, 4
	la $a0, prompt1
	syscall
	li $v0, 5
	syscall
	move $s0, $v0 #$s0 = matrix col & rows
	la $a0, message1
	li $v0, 4
	syscall
	move $a0, $s0
	li $v0, 1
	syscall
	la $a0, x
	li $v0, 4
	syscall
	move $a0, $s0
	li $v0, 1
	syscall
	la $a0, newline
	li $v0, 4
	syscall
	move $s6, $s0
	mul $s1, $s0, $s0 #$s1 = matrix size
	addi $t0, $zero, 4
	mul $s1, $s1, $t0
	move $s7, $s1 
	move $a0, $s1
	li $v0, 9
	syscall
	move $s2, $v0 #$s2 = matrix base
	la $a0, prompt2
	li $v0, 4
	syscall
	move $a0, $s2 #$a0 = matrix base, $a1 = col row size
	move $a1, $s0
	jal initializeMatrix
	la $a0, newline
	li $v0, 4
	syscall
	la $a0, message2
	syscall
	move $a0, $s2
	move $a1, $s0
	jal printMatrix
	move $a0, $s2
	move $a1, $s0
	jal getDeterminant
	move $t1, $v0
	li $v0, 4
	la $a0, message3
	syscall
	move $a0, $t1
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	li $v0, 10
	syscall
	
initializeMatrix:
	addi $t0, $zero, 0
OuterLoop: #rows
	beq $t0, $a1, endOuterLoop
	addi $t1, $zero, 0
InnerLoop: #columns
	beq $t1, $a1, endInnerLoop
	mul $t2, $t0, $a1 #i*row_size
	add $t2, $t2, $t1 #$t2=i*row_size+j
	addi $t3, $zero, 4
	mul $t3, $t2, $t3 #$t3=$t2*4
	add $t4, $a0, $t3 #$t4=matrix+base+offset[i][j]
	li $v0, 5
	syscall
	move $t5, $v0
	sw $t5, 0($t4) #put $t2 in Mem[$t4]
	addi $t1, $t1, 1
	j InnerLoop
endInnerLoop:
	addi $t0, $t0, 1 #increment serial row index by 1
	j OuterLoop
endOuterLoop:
	add $v0, $a0, $zero #return matrix base address
	jr $ra



getDeterminant:
	addi $sp, $sp, -36
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	sw $t3, 24($sp)
	sw $t4, 28($sp)
	sw $t5, 32($sp)
	addi $t0, $zero, 1
	bne $a1, $t0, ifNotOne #if n == 1
	lw $v0, 0($a0) #return matrix[0][0]
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	lw $t2, 20($sp)
	lw $t3, 24($sp)
	lw $t4, 28($sp)
	lw $t5, 32($sp)
	addi $sp, $sp, 36
	jr $ra	
ifNotOne:
	move $t2, $a0
	move $a0, $s7
	li $v0, 9
	syscall
	move $t1, $v0 #$t1 = temp[N][N]
	move $a0, $t2
	addi $s0, $zero, 1 #$s0 = sign
	addi $s1, $zero, 0 #$s1 = D
	addi $t2, $zero, 0
	
LoopD: #for(int i =0; i<n; i++)
	beq $t2, $a1, endLoopD
	move $a2, $t1
	move $a3, $t2
	jal Cofactors
	move $t1, $a2
	addi $t3, $zero, 4
	mul $t3, $t2, $t3 #$t3 = j*sizeofbytes
	add $t3, $a0, $t3 # +matrixbase
	lw $t4, 0($t3) #t4 = matrix[0][$t2]
	mul $t5, $t4, $s0 #t5 = sign*matrix[0][$t2]
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	move $a0, $t1
	addi $a1, $a1, -1
	jal getDeterminant
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	addi $sp, $sp, 8
	mul $t5, $v0, $t5 #sign*matrix[0][$t2]*Determinant(temp,n-1)
	add $s1, $s1, $t5 #D += 
	addi $t3, $zero, -1
	mul $s0, $s0, $t3 #sign = sign* -1
	addi $t2, $t2, 1
	j LoopD
endLoopD:
	move $v0, $s1 #return D
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	lw $t2, 20($sp)
	lw $t3, 24($sp)
	lw $t4, 28($sp)
	lw $t5, 32($sp)
	addi $sp, $sp, 36
	jr $ra	

Cofactors: #$a0 = matrixbase; $a1 = matrix dimensions; $a2 =  tempmatrixbase; $a3 = col
	addi $sp, $sp, -32
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	sw $t4, 20($sp)
	sw $t5, 24($sp)
	sw $t6, 28($sp)
	addi $t0, $zero, 0 # i
	addi $t1, $zero, 0 # j
	addi $t2, $zero, 0 #$t2 = row; $t3 = col
OuterLoopC:
	beq $t2, $a1, endOuterLoopC
	addi $t3, $zero, 0
InnerLoopC:
	beq $t3, $a1, endInnerLoopC
	beqz $t2, ExitIf #(row != 0)
	beq $t3, $a3, ExitIf #(col != callercol)
	mul $t4, $s6, $t2 # i*dimension
	add $t4, $t4, $t3 # + j
	addi $t5, $zero, 4
	mul $t4, $t4, $t5 # * sizeofbytes
	add $t4, $a0, $t4 # + matrixbase
	lw $t6, 0($t4) #$t6 = matrix[row][col]
	mul $t4, $s6, $t0 # i*dimension
	add $t4, $t4, $t1 # + j
	mul $t4, $t4, $t5 # * sizeofbytes
	add $t4, $a2, $t4 # + tempmatrixbase
	sw $t6, 0($t4) #temp[i][j] = matrix[row][col]
	addi $t1, $t1, 1 #j++
	addi $t4, $a1, -1
	bne $t1, $t4, ExitIf
	addi $t1, $zero, 0 #j = 0
	addi $t0, $t0, 1 #i++
	
ExitIf:
	addi $t3, $t3, 1
	j InnerLoopC
endInnerLoopC:
	addi $t2, $t2, 1
	j OuterLoopC
endOuterLoopC:
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	lw $t4, 20($sp)
	lw $t5, 24($sp)
	lw $t6, 28($sp)
	addi $sp, $sp, 32
	jr $ra
	
	


printMatrix:
	addi $sp, $sp, -44
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	sw $t4, 20($sp)
	sw $t5, 24($sp)
	sw $t6, 28($sp)
	sw $a0, 32($sp)
	sw $a1, 36($sp)
	sw $v0, 40($sp)
	move $a1, $s6
	addi $t0, $zero, 0
	addu $t7, $a0, $zero
outerLoop2:
	beq $t0, $a1, endOuterLoop2 
	addi $t1, $zero, 0 
innerLoop2:
	beq $t1, $a1, endInnerLoop2
	mult $t0, $a1 
	mflo $t2
	addu $t2, $t2, $t1 
	sll $t3, $t2, 2
	addu $t4, $t7, $t3 
	lw $t5, 0($t4)
	add $a0, $t5, $zero
	li $v0, 1
	syscall
	la $a0, '\t'
	li $v0, 11
	syscall
	addi $t1, $t1, 1
	j innerLoop2
endInnerLoop2:
	la $a0, '\n'
	li $v0, 11
	syscall
	addi $t0, $t0, 1 
	j outerLoop2
endOuterLoop2:
	la $a0, newline
	li $v0, 4
	syscall
	addu $v0, $a0, $zero
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	lw $t4, 20($sp)
	lw $t5, 24($sp)
	lw $t6, 28($sp)
	lw $a0, 32($sp)
	lw $a1, 36($sp)
	lw $v0, 40($sp)
	addi $sp, $sp, 44
	jr $ra
	
PrintV0:
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $v0, 8($sp)
	move $a0, $v0
	li $v0, 1
	syscall
	la $a0, newline
	li $v0, 4
	syscall
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $v0, 8($sp)
	addi $sp, $sp, 12
	jr $ra
