# 	* READ ME BEFORE UNDERSTANDING MY CODE *
#	* ALGORITHM *
#	This program have 3 main parts: 
#	1. Read number of students: There's nothing to say about this
#	2. Read student's name and mark: 
#		- Read and split student's name to chars and push them to stack (chars)
#		- Then, push length of name to stack (len) (notice: len = name'length + 2, will be explained why after)
#		- And read and push student's mark to stack (mark)
#		--> So stack will be pushed in this form: ... || mark len chars || mark len chars || mark len chars
#	3. Print student's name descentdently 
#		This part have 2 main parts: 
#		3.1. Find the max mark in stack
#		3.2. Loop through stack, if there's a student have his mark = current max mark -> print out
#		And then, loop through stack again until all student have been printed.
#		NOTE: There's a variable named maxSoFar need to be noticed 
#		(while loop through stack, a mark which greater than maxSoFar will be passed through)
# --------------------------------------------------------------------------------------------- #
#	* Example *
#	Student 1: nam, 5
#	Student 2: huy, 2
#	Student 3: duong, 3
#	------------------
# 	After step 2, stack will belike: ... || mark len chars || 3 7 duong || 2 5 huy || 5 5 nam || 
# 	Step 3: 
#	3.1: 	max = 5 -> print out 'student 1: nam' -> maxSoFar = 5
#	-> 		max = 3 -> print out 'student 3: duong' -> maxSoFar = 3
#	-> 		max = 2 -> print out 'student 2: huy' -> maxSoFar = 2
#	-> 		all students have been printed 
#	-> 		EXIT
# ---------------------------------------------------------------------------------------------- #


.data 
nameStr: .space 100

inputAmountMes: .asciiz "Input number of students: "
inputNameMes:   .asciiz "Input student's name: "
inputMarkMes:   .asciiz "Input student's mark: "
Message:        .asciiz "Student name:"

#
# 	s0 = number of students
#	
.text

#**********
# Read number of students
#**********
readAmount: 	
		li 	$v0, 51
		la 	$a0, inputAmountMes
		syscall
		la	$s0, 0($a0) 			# s0 = number of students

#**********
# Read student's name and mark
#**********
readNameMark:
		li	$s1, 0 				# intialize i = 0 (i for loop in readNameMark)
loop: 		
		addi	$s1, $s1, 1 			# i = i + 1 (i for loop in readNameMark)
readName:	
		li	$v0, 54
		la	$a0, inputNameMes
		la	$a1, nameStr
		la	$a2, 100
		syscall
	
		la	$a0, nameStr			# a0 = nameStr[0]
		addi	$t0, $zero, 0			# length = 0 (nameStr[i]) 
pushNameToStack:		
		# read each char of nameStr
		add	$t1, $a0, $t0			# t1 = address(nameStr[0] + i)
		lb	$t2, 0($t1)			# t2 = value(t1) = char
		
		# push each char to stack 
		addi	$sp, $sp, -4		
		sw	$t2, 0($sp)		
		beq	$t2, $zero, end_of_str		# if 'end of string'
		addi	$t0, $t0, 1			# else length++
		j	pushNameToStack			# and continue to push 
end_of_str:
		# After student's name is pushed to stack,
		# push legnth of name to stack
		addi	$sp, $sp, -4
		addi 	$t0, $t0, 1
		sw	$t0, 0($sp)
end_of_readName:

readMark: 	
		li 	$v0, 51
		la 	$a0, inputMarkMes
		syscall
pushMarkToStack: 
		addi	$sp, $sp, -4
		sw	$a0, 0($sp)
end_of_readMark:

		beq	$s1, $s0, end_of_loop		# if all student is push -> exit
		j	loop				# else continue to read name and mark
end_of_loop:
end_of_readNameMark:

# Save current address of stack pointer to loop through stack many times
		add	$fp, $sp, -4
		
#************************************************		
# LOOP THROUGHT STACK TO PRINT STUDENT
#	t1 = maxSoFar
#	t0 = max
#	s3 = number of student have printed
#	t6 = student's mark popped from stack
#	t2 = length of student's name popped from stack
#************************************************
		li 	$t1, 100				# set maxSoFar = 100
		li 	$s3, 0 				# number of student have printed
loopStack:
		add	$sp, $fp, $zero			# set stack pointer to top of stack

# Find max student's mark in stack (max < maxSoFar)
findMax: 
		li	$t0, 0				# set max = 0
		li	$t7, 1				# set i for findMax = 1
popMark:		
		addi 	$sp, $sp, 4
		lw	$t6, 0($sp)			# get student Mark = t6
		beq	$t6, $t1, popNameLength		# if student's mark = maxSoFar -> go through
		bgt	$t6, $t1, popNameLength
		blt	$t6, $t0, popNameLength		# if student's mark < current max -> go through

		add	$t0, $t6, $zero			# else set new max		
popNameLength:
		addi	$sp, $sp, 4
		lw	$t2, 0($sp)			# nameLength = t2
popName:
		# loop through stack to get name
		li	$s1, 0 				# intialize i = 0 		
popLoop:
		addi	$s1, $s1, 1 			# i = i + 1 
		addi 	$sp, $sp, 4
		bne	$s1, $t2, popLoop		# if i != nameLength
end_of_popName:	

		# check condition to continue to loop	
		beq	$t7, $s0, end_of_findMax		# if all students were looped -> exit findMax
		addi	$t7, $t7, 1			# else i = i + 1,
		j	popMark				# continue to loop
end_of_findMax:	

# Set maxSoFar = max
		add	$t1, $t0, 0
			
# Print student's inf who have current max mark
		add	$sp, $fp, $zero			# point $sp to top of stack to begin 
loopForPrint: 
		li	$s2, 1				# set i for loopStack  = 1
popMark2:		
		addi 	$sp, $sp, 4
		lw	$t6, 0($sp)			# get student Mark = t6
		
		addi	$sp, $sp, 4
		lw	$t5, 0($sp)			# get student's name length = t5
		
		beq	$t6, $t0, printName		# if student's mark = current mark => print student's name
		j	goThrough			# else go through that student
checkCondition: 	
		beq	$s2, $s0, end_of_loopForPrint	# if stack was loop through -> exit and check to continue to print another student
		addi	$s2, $s2, 1			# else i = i + 1
		j	popMark2				# continue to loop through stack
		
# @printName function
printName:	
		addi	$s3, $s3, 1			# whenever a student have printed, s3 = s3 + 1 ( s3 = number of student have printed)
		li	$s1, 0				# number of chars have been read
		
		la 	$a0, nameStr			# a0 = address of .space to store chars popped from stack 
		la	$a1, 0($a0)			# a1 = address of current element 
		
# Get all name's chars from stack, and push them to a .space named 'nameStr'
loopForStore:
		# pop char from stack and store in $a1 (a1 = current element in .space)
		addi 	$sp, $sp, 4			
		lw	$t8, 0($sp)
		sb	$t8, 0($a1)
		addi	$a1, $a1, 4			# move to next element in .space
		addi	$s1, $s1, 1 			# i = i + 1 ( s1 = number of chars have been read)
		bne	$s1, $t5, loopForStore		# if i != nameLength -> continue loop


# Loop through .space to print student's name
		li	$s1, 0				# counter of char
printOut: 		
		addi	$a1, $a1, -4
		lb	$t3, 0($a1)
		li	$v0, 11
		la	$a0, 0($t3)
		syscall
		addi	$s1, $s1, 1
		beq	$s1, $t5, checkCondition
		j 	printOut
end_of_printName:

# @goThrough function
goThrough:		
		li	$s1, 0
loopThrough:
		addi 	$sp, $sp, 4
		addi	$s1, $s1, 1 			# i = i + 1 
		bne	$s1, $t5, loopThrough		# if i != nameLength
		j	checkCondition
end_of_loopForPrint:	

# Check condition to decide if there's need to loop throught stack one more time
		beq	$s3, $s0, end_of_loopStack	# if all student's name have printed -> exit program
		j	loopStack			# else loop through stack again 
end_of_loopStack:


