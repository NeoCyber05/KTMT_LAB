.data
prompt:      .asciz "Enter a positive integer: "
error_msg:   .asciz "Error: Input must be a positive integer. Please try again.\n" # Thông báo lỗi rõ hơn
lucky_msg:   .asciz " is a lucky number.\n"
not_lucky_msg: .asciz " is not a lucky number.\n"
newline:     .asciz "\n"

.text
main:
# --- Vòng lặp nhập liệu và kiểm tra ---
input_loop:
    # Print prompt
    li a7, 4          # Service code for print_string
    la a0, prompt     # Address of string to print
    ecall

    # Read integer N
    li a7, 5          # Service code for read_int
    ecall
    mv s0, a0         # Store N in s0

    # Check if N > 0
    blez s0, input_error # Branch if N <= 0. Nếu không, tiếp tục xử lý

    # Nếu đến đây, N là số nguyên dương, thoát khỏi vòng lặp nhập liệu
    # và đi tới phần logic chính

    # --- Logic kiểm tra số may mắn ---
    # Count the number of digits in N
    mv t0, s0         # Use t0 as a temporary copy of N
    li t1, 0          # t1 = digit count (d)
    li t2, 10         # Constant 10 for division/modulo
count_loop:
    beqz t0, count_done # If t0 is 0, we are done counting
    div t0, t0, t2    # N = N / 10
    addi t1, t1, 1    # Increment digit count
    j count_loop
count_done:
    # s1 will hold the digit count (d)
    mv s1, t1

    # Handle single digit numbers (always lucky)
    li t0, 1
    beq s1, t0, print_lucky # If d == 1, it's lucky

    # Calculate half length (d / 2)
    li t3, 2
    div s2, s1, t3    # s2 = half_len = d / 2

    # Calculate 10^half_len (divisor)
    li s3, 1          # s3 = divisor = 1 (starts at 10^0)
    mv t0, s2         # t0 = counter = half_len
power_loop:
    beqz t0, power_done # If counter is 0, done
    mul s3, s3, t2    # divisor = divisor * 10
    addi t0, t0, -1   # Decrement counter
    j power_loop
power_done:
    # s3 now holds 10^half_len

    # Separate the number into left and right halves
    rem s4, s0, s3    # s4 = right_half = N % divisor
    div s5, s0, s3    # s5 = left_half = N / divisor

    # Calculate sum of digits for the right half
    mv a0, s4         # Pass right_half to sum_digits
    call sum_digits
    mv s6, a0         # Store right_sum in s6

    # Calculate sum of digits for the left half
    mv a0, s5         # Pass left_half to sum_digits
    call sum_digits
    mv s7, a0         # Store left_sum in s7

    # Compare sums
    beq s6, s7, print_lucky
    # If sums are not equal, it's not lucky
    j print_not_lucky

# --- Subroutine to calculate sum of digits ---
# Input: a0 = number
# Output: a0 = sum of digits
# Uses temporary registers: t0, t1, t2, t3
sum_digits:
    addi sp, sp, -4   # Allocate space on stack
    sw ra, 0(sp)      # Save return address

    li t0, 0          # t0 = sum = 0
    mv t1, a0         # t1 = current number part
    li t2, 10         # Constant 10
sum_loop:
    beqz t1, sum_done # If number part is 0, done
    rem t3, t1, t2    # t3 = last digit = number % 10
    add t0, t0, t3    # sum = sum + digit
    div t1, t1, t2    # number = number / 10
    j sum_loop
sum_done:
    mv a0, t0         # Return sum in a0

    lw ra, 0(sp)      # Restore return address
    addi sp, sp, 4    # Deallocate stack space
    ret               # Return (jr ra)

# --- Output Sections ---
input_error:
    # Print error message
    li a7, 4
    la a0, error_msg
    ecall
    # Jump back to ask for input again
    j input_loop      # Quay lại đầu vòng lặp nhập liệu

print_lucky:
    # Print the original number
    li a7, 1
    mv a0, s0
    ecall
    # Print the "is lucky" message
    li a7, 4
    la a0, lucky_msg
    ecall
    j exit

print_not_lucky:
    # Print the original number
    li a7, 1
    mv a0, s0
    ecall
    # Print the "is not lucky" message
    li a7, 4
    la a0, not_lucky_msg
    ecall
    j exit

# --- Exit Program ---
exit:
    li a7, 10         # Service code for exit
    ecall