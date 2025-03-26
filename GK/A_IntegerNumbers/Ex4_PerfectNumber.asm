.data
prompt: .asciz "Enter a positive integer N: "
newline: .asciz "\n"
text_perfect: .asciz "Perfect numbers less than N: \n"
error_msg: .asciz "Please enter a positive integer.\n"

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

    # Print the header for perfect numbers
    li a7, 4              # syscall for print string
    la a0, text_perfect   # load address of perfect numbers header message
    ecall

    # Loop from 1 to N-1 to check perfect numbers
    li t1, 1              # t1 = 1 (start from 1)
check_perfect:
    mv a0, t1            # a0 = current number to check
    jal ra, is_perfect    # call is_perfect function
    beq a0, zero, print_perfect # if number is perfect (a0 == 0), print it
    addi t1, t1, 1        # increment the number
    blt t1, t0, check_perfect # if t1 < N, continue checking

    # Exit program
    li a7, 10             # syscall for exit
    ecall

print_error:
    # Print error message and ask for input again
    li a7, 4              # syscall for print string
    la a0, error_msg      # load address of error message
    ecall

    # Ask for input again
    j input_loop          # jump to input loop to ask for input again

# is_perfect function
# Input: a0 = number to check
# Output: a0 = 0 if perfect, 1 if not perfect
is_perfect:
    # Initialize sum of divisors to 0
    li t2, 0              # t2 = sum of divisors

    # Check divisors from 1 to a0 / 2
    li t3, 1              # t3 = divisor candidate
check_divisor:
    bge t3, a0, check_done # if t3 >= a0, finish
    rem t4, a0, t3        # t4 = a0 % t3
    beq t4, zero, add_divisor # if a0 % t3 == 0, t3 is a divisor

    addi t3, t3, 1        # increment divisor candidate
    j check_divisor       # continue checking divisors

add_divisor:
    add t2, t2, t3        # sum = sum + t3
    addi t3, t3, 1        # increment divisor candidate
    j check_divisor       # continue checking divisors

check_done:
    # Check if sum of divisors equals the number
    beq t2, a0, perfect   # if sum == a0, it's a perfect number
    li a0, 1              # a0 = 1, not perfect
    ret

perfect:
    li a0, 0              # a0 = 0, perfect
    ret

# print_perfect function
# Prints the perfect number (a0)
print_perfect:
    li a7, 1              # syscall for print integer
    mv a0, t1             # move the perfect number into a0
    ecall                 # print perfect number
    li a7, 4              # syscall for print string
    la a0, newline        # load address of newline string
    ecall                 # print newline
    ret
