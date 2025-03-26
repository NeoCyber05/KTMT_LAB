.data
prompt: .asciz "Enter a positive integer N: "
lucky_msg: .asciz "The number is a lucky number.\n"
not_lucky_msg: .asciz "The number is not a lucky number.\n"
error_msg: .asciz "Please enter a positive integer.\n"
newline: .asciz "\n"

.text
.global _start

_start:
    # Print prompt message
    li a7, 4              # syscall for print string
    la a0, prompt         # load address of prompt message
    ecall

input_loop:
    # Read integer N from user
    li a7, 5              # syscall for read integer
    ecall
    mv t0, a0            # store N in t0

    # Check if the input is a positive integer (N > 0)
    blez t0, print_error  # if N <= 0, print error and ask for input again

    # Find the number of digits in N
    mv t1, t0            # copy N to t1
    li t2, 0              # initialize digit count to 0
    li t3, 10             # load 10 into t3 for division

count_digits:
    div t1, t1, t3        # divide t1 by 10 and store the result in t1
    addi t2, t2, 1        # increment digit count
    bnez t1, count_digits # continue if t1 > 0

    # Split the number into two halves
    li t4, 0              # counter for left half digits
    li s1, 0              # sum of left half digits
    li s2, 0              # sum of right half digits
    mv t5, t2             # total digit count

    # Divide the total digits by 2 using s7 to store 2
    li s7, 2              # s7 = 2
    div t5, t5, s7        # divide total digits by 2

    # If the total digits count is odd, we add one digit to the right side
    # So the right half will have one more digit than the left half
    bnez t2, handle_odd_digits

handle_odd_digits:
    li t6, 0              # counter for right half

split_number:
    rem s10, t0, t3        # get the last digit (N % 10)
    div t0, t0, t3        # divide N by 10 to reduce it

    # Update left or right half sum
    bge t4, t5, add_right # if in right half, add to right sum
    add s1, s1, s10        # add to left half sum
    j continue_split

add_right:
    add s2, s2, s10        # add to right half sum

continue_split:
    addi t4, t4, 1        # increment counter
    bnez t0, split_number # continue splitting

    # Compare sums of left and right halves
    beq s1, s2, print_lucky # if sums are equal, it's a lucky number

    # If not lucky, print message and exit
print_not_lucky:
    li a7, 4              # syscall for print string
    la a0, not_lucky_msg  # load address of "not lucky" message
    ecall
    li a7, 10             # syscall for exit
    ecall

print_lucky:
    li a7, 4              # syscall for print string
    la a0, lucky_msg      # load address of "lucky" message
    ecall
    li a7, 10             # syscall for exit
    ecall

print_error:
    # Print error message and ask for input again
    li a7, 4              # syscall for print string
    la a0, error_msg      # load address of error message
    ecall

    # Ask for input again
    j input_loop          # jump to input loop to ask for input again
