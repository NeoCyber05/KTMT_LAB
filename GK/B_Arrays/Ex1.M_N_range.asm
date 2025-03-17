#Enter an array of integers from the keyboard. 
#Count the elements of the array that lie within the range (M, N), 
#where M and N are two integers entered from the keyboard.
.data
	mess_size: .asciz "Enter size of array: "
	mess_sizeArr: .asciz "Enter values for M and N:\n "
	mess_input: .asciz "Enter the values of array:\n"
	output: .asciz "Count: "
	.align 2
	buffer:.space 400 #mảng 100 phần tử
		
.text
input:
        #Input size of array
	li a7,4
	la a0,mess_size
	ecall
	
	li a7,5
	ecall
	mv a1,a0   # a1 là kích cỡ mảng
	
	#Input M & N
	li a7,4
	la a0,mess_sizeArr
	ecall
	
	li a7,5
	ecall
	mv a2,a0  # a2 là M
	
	li a7,5
	ecall
	mv a3,a0  # a3 là N
	
	#Input array
	li a7,4
	la a0,mess_input
	ecall
pre:
	li t0,0  # t0 là index
	la s0,buffer  # s0 là địa chỉ cơ sở
	li t1, 0 # t1 là count
loop:
	add t2,t0,t0 #2i
	add t2,t2,t2 #4i
	add t3,s0,t2 # t3 = 4i + A
	
	li a7,5
	ecall
	mv t4,a0     #t4 là giá trị a[i] 
	sw t4, 0(t3) # lưu giá trị mảng tại địa chỉ t3 ( 4i+A )
	
	ble t4,a2,next # a[i] <= m  
	bge t4,a3,next # a[i] >= n
	addi t1,t1,1   # TM đk thì count+1
next:
	addi t0,t0,1
	blt  t0,a1,loop # i< size 
print:
	li a7,4
	la a0,output
	ecall
	
	li a7,1
	mv a0,t1
	ecall
	
	li a7,10
	ecall
	
	
	
	
	
	
	
	
	
	
