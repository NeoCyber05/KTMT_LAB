#Enter a positive integer N from the keyboard,
#print all the positive integers less than N that are divisible by 3 or 5.

.data
	mess: .asciz "Enter a positive integer: "
	newline: .asciz "\n"
	
.text
Begin:
	#Print mess
	li a7,4
	la a0,mess
	ecall
	
	#Input 
	li a7,5
	ecall
	
	#t0 = N
	mv t0,a0
	
	#For 1 to N-1
	li t1,1
For:
	bge t1,t0,exit #if t1 >= N dừng vòng lặp
	
	
	#Check t1 chia hết 3 or 5
	li t6,3
	rem t3,t1,t6 # t3 = t1 % 3
	li t6,5
	rem t5,t1,t6  # t5 = t1 % 5
	
	#Nếu chia hết thì in ra
	#or t4,t3,t5    nếu dùng or  ( t4=0 ) thì sẽ tìm số chia hết cả 3 và 5
	beqz t3,print
	beqz t5,print
	#
	addi t1,t1,1
	j For
print:
	li a7,1
	mv a0,t1
	ecall    #in số thỏa mãn
	
	li a7,4
	la a0,newline
	ecall    #xuống dòng
	
	addi t1,t1,1
	j For
exit:
	li a7,10
	ecall
	
	
	
	
	
	
	
