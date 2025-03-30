.data
prompt_string:    .asciz "Enter a string: "
output_msg:       .asciz "Result: "
newline:          .asciz "\n"

# Max string length + 1 for null terminator
BUFFER_SIZE:      .word 256
input_buffer:     .space 256

.text
main:
    # --- Input String ---
    li a7, 4
    la a0, prompt_string
    ecall

    li a7, 8                # Service code for read_string
    la a0, input_buffer     # Address of buffer
    lw a1, BUFFER_SIZE      # Max length
    ecall

    # --- Process String ---
    la s0, input_buffer     # s0 = current character address pointer
process_loop:
    lb t0, 0(s0)            # t0 = current character
    beqz t0, process_done   # If char == '\0', we are done

    # --- Check if Uppercase ('A' to 'Z') ---
    li t1, 'A'
    blt t0, t1, check_lowercase # if char < 'A', it's not uppercase, check if lowercase
    li t1, 'Z'
    bgt t0, t1, check_lowercase # if char > 'Z', it's not uppercase, check if lowercase

    # >>> It IS Uppercase -> Convert to Lowercase <<<
    addi t0, t0, 32         # Add 32 to convert to lowercase
    sb t0, 0(s0)            # Store the modified lowercase char back
    j next_char             # Go process the next character (already converted)

check_lowercase:
    # --- Check if Lowercase ('a' to 'z') ---
    li t1, 'a'
    blt t0, t1, next_char     # if char < 'a', it's not lowercase or uppercase, go to next
    li t1, 'z'
    bgt t0, t1, next_char     # if char > 'z', it's not lowercase or uppercase, go to next

    # >>> It IS Lowercase -> Convert to Uppercase <<<
    addi t0, t0, -32        # Subtract 32 to convert to uppercase
    sb t0, 0(s0)            # Store the modified uppercase char back
    # j next_char            # Explicitly jump to next char (cleaner)
                               # Falling through also works here

next_char:
    # --- Move to the next character ---
    addi s0, s0, 1          # Move pointer to the next character address
    j process_loop          # Continue the loop

process_done:
    # --- Print Result ---
    li a7, 4
    la a0, output_msg       # Print "Result: "
    ecall

    li a7, 4
    la a0, input_buffer     # Print the modified buffer content
    ecall

    # --- Exit Program ---
exit:
    li a7, 10               # Service code for exit
    ecall