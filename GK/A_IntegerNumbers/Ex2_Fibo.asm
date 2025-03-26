.data
prompt: .asciz "Enter a positive integer N: "
newline: .asciz "\n"
.text
.global _start

_start:
    # Print prompt message
    li a7, 4              # syscall for print string
    la a0, prompt         # load address of prompt message
    ecall

    # Read integer N from user
    li a7, 5              # syscall for read integer
    ecall
    mv t0, a0            # store input value (N) in t0

    # Initialize Fibonacci numbers (f0 = 0, f1 = 1)
    li t1, 0              # f0 = 0
    li t2, 1              # f1 = 1

fib_loop:
    # Print Fibonacci number t1
    li a7, 1              # syscall for print integer
    mv a0, t1             # move current Fibonacci number to a0
    ecall

    # Print newline after each Fibonacci number
    li a7, 4              # syscall for print string
    la a0, newline        # load address of newline string
    ecall

    # Calculate next Fibonacci number
    add t3, t1, t2        # t3 = t1 + t2
    mv t1, t2             # f0 = f1
    mv t2, t3             # f1 = f2

    # Check if next Fibonacci number is less than N
    blt t1, t0, fib_loop  # if f0 < N, repeat the loop

    # Exit program
    li a7, 10             # syscall for exit
    ecall
