#3.Write a function to check if a number is a prime number. 
#Then enter two positive integers M and N from the keyboard, print out all the prime numbers between M and N.

.data
prompt_m: .asciz "Enter the first positive integer M: "
prompt_n: .asciz "Enter the second positive integer N: "
newline: .asciz "\n"
text_prime: .asciz "Prime numbers between M and N: \n"
error_msg: .asciz "Please enter a positive integer.\n"

.text
.global _start

_start:
    # Print prompt for M
    li a7, 4              # syscall for print string
    la a0, prompt_m       # load address of prompt message for M
    ecall

input_loop_mn:
    # Read integer M from user
    li a7, 5              # syscall for read integer
    ecall
    mv t0, a0            # store M in t0

    # Check if M is a positive integer (M > 0)
    blez t0, print_error  # if M <= 0, print error and ask for input again

    # Print prompt for N
    li a7, 4              # syscall for print string
    la a0, prompt_n       # load address of prompt message for N
    ecall

    # Read integer N from user
    li a7, 5              # syscall for read integer
    ecall
    mv t1, a0            # store N in t1

    # Check if N is a positive integer (N > 0)
    blez t1, print_error  # if N <= 0, print error and ask for input again

    # Print the header for prime numbers
    li a7, 4              # syscall for print string
    la a0, text_prime     # load address of prime numbers header message
    ecall

    # Loop from M to N to check prime numbers
    addi t0,t0,1
    mv t2, t0            # t2 = M
check_primes:
    mv a0, t2            # a0 = current number to check
    jal ra, is_prime      # call is_prime function
    beq a0, zero, print_prime  # if number is prime (a0 == 0), print it
    addi t2, t2, 1        # increment the number
    blt t2, t1, check_primes # if t2 < N, continue checking

    # Exit program
    li a7, 10             # syscall for exit
    ecall

print_error:
    # Print error message and ask for input again
    li a7, 4              # syscall for print string
    la a0, error_msg      # load address of error message
    ecall

    # Ask for input again (both M and N)
    j input_loop_mn        # jump to input loop to ask for M and N again

# is_prime function
# Input: a0 = number to check
# Output: a0 = 0 if prime, 1 if not prime
is_prime:
    # Check if number is less than 2 (not prime)
    li t3, 2              # t3 = 2
    blt a0, t3, not_prime # if a0 < 2, not prime

    # Initialize divisor to 2
    li t4, 2              # t4 = 2

check_divisor:
    # Check if t4 * t4 <= a0
    mul t5, t4, t4        # t5 = t4 * t4
    bgt t5, a0, prime     # if t5 > a0, a0 is prime

    # Check if a0 is divisible by t4
    rem t6, a0, t4        # t6 = a0 % t4
    beq t6, zero, not_prime # if a0 % t4 == 0, not prime

    addi t4, t4, 1        # increment divisor
    j check_divisor       # continue checking

prime:
    li a0, 0              # a0 = 0, prime
    ret

not_prime:
    li a0, 1              # a0 = 1, not prime
    ret

# print_prime function
# Prints the prime number (a0)
print_prime:
    # Print prime number directly using t2 (instead of a0) to avoid overwriting
    li a7, 1              # syscall for print integer
    mv a0, t2             # move the prime number into a0
    ecall                 # print prime number
    li a7, 4              # syscall for print string
    la a0, newline        # load address of newline string
    ecall                 # print newline
    ret
