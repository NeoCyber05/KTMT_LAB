.data
prompt_string:    .asciz "Enter a string: "
output_char_msg:  .asciz "Most frequent uppercase character: "
output_freq_msg:  .asciz "\nFrequency: "
output_pos_msg:   .asciz "\nPositions (0-based index): "
no_uppercase_msg: .asciz "No uppercase letters found.\n"
space:            .asciz " "
newline:          .asciz "\n"

# Max string length + 1 for null terminator
BUFFER_SIZE:      .word 256
input_buffer:     .space 256

# Frequency counts for 'A' through 'Z' (26 letters)
FREQ_COUNT_SIZE:  .word 26
freq_counts:      .space 104 # 26 words * 4 bytes/word

# Positions storage - Assume max occurrences won't exceed buffer size
# (A safer approach might limit this, but makes code simpler here)
positions:        .space 1024 # Allocate space for up to 256 positions

.text
main:
    # --- Initialization ---
    # Zero out the frequency count array
    lw t0, FREQ_COUNT_SIZE  # t0 = 26
    li t1, 0                # t1 = loop counter (i)
    la t2, freq_counts      # t2 = base address of freq_counts
init_counts_loop:
    bge t1, t0, init_counts_done # if i >= 26, done
    mul t3, t1, t1          # Calculate offset (i * 4) using slli later
    slli t3, t1, 2          # t3 = i * 4
    add t4, t2, t3          # t4 = address of freq_counts[i]
    sw zero, 0(t4)          # freq_counts[i] = 0
    addi t1, t1, 1          # i++
    j init_counts_loop
init_counts_done:

    # --- Input String ---
    li a7, 4
    la a0, prompt_string
    ecall

    li a7, 8                # Service code for read_string
    la a0, input_buffer     # Address of buffer
    lw a1, BUFFER_SIZE      # Max length
    ecall

    # --- First Pass: Count Frequencies ---
    la s0, input_buffer     # s0 = current char pointer
    la s1, freq_counts      # s1 = base address of freq_counts
count_freq_loop:
    lb t0, 0(s0)            # t0 = current character
    beqz t0, count_freq_done # if char == '\0', done

    # Check if uppercase ('A' <= char <= 'Z')
    li t1, 'A'
    blt t0, t1, count_freq_next # if char < 'A', skip
    li t1, 'Z'
    bgt t0, t1, count_freq_next # if char > 'Z', skip

    # It's an uppercase letter
    li t1, 'A'
    sub t2, t0, t1          # t2 = index = char - 'A'
    slli t3, t2, 2          # t3 = index * 4 (offset)
    add t4, s1, t3          # t4 = address of freq_counts[index]
    lw t5, 0(t4)            # t5 = current count
    addi t5, t5, 1          # Increment count
    sw t5, 0(t4)            # Store back the new count

count_freq_next:
    addi s0, s0, 1          # Move to next character in input string
    j count_freq_loop
count_freq_done:

    # --- Second Pass: Find Max Frequency and Character ---
    li s2, -1               # s2 = max_freq = -1 (ensures any count > 0 is picked)
    li s3, 0                # s3 = index_of_max = 0 ('A') initially
    lw t0, FREQ_COUNT_SIZE  # t0 = 26
    li t1, 0                # t1 = loop counter (i)
    la t2, freq_counts      # t2 = base address of freq_counts
find_max_loop:
    bge t1, t0, find_max_done # if i >= 26, done

    slli t3, t1, 2          # t3 = i * 4
    add t4, t2, t3          # t4 = address of freq_counts[i]
    lw t5, 0(t4)            # t5 = current count (freq_counts[i])

    ble t5, s2, find_max_next # if current_count <= max_freq, skip update

    # Found a new max
    mv s2, t5               # max_freq = current_count
    mv s3, t1               # index_of_max = i

find_max_next:
    addi t1, t1, 1          # i++
    j find_max_loop
find_max_done:

    # --- Check if any uppercase letter was found ---
    bltz s2, no_uppercase   # if max_freq < 0 (still -1), none found

    # Calculate the most frequent character
    li t0, 'A'
    add s4, t0, s3          # s4 = most_freq_char = 'A' + index_of_max

    # --- Third Pass: Find Positions ---
    la s0, input_buffer     # s0 = current char pointer
    la s5, positions        # s5 = pointer to store positions
    li s6, 0                # s6 = position index counter (in string)
    li s7, 0                # s7 = count of positions found
find_pos_loop:
    lb t0, 0(s0)            # t0 = current character
    beqz t0, find_pos_done  # if char == '\0', done

    bne t0, s4, find_pos_next # if char != most_freq_char, skip

    # Found an occurrence of the most frequent character
    sw s6, 0(s5)            # Store current string index (s6) in positions array
    addi s5, s5, 4          # Move positions pointer
    addi s7, s7, 1          # Increment count of positions found

find_pos_next:
    addi s0, s0, 1          # Move to next character in input string
    addi s6, s6, 1          # Increment string position index
    j find_pos_loop
find_pos_done:

    # --- Output Results ---
    # Print character message
    li a7, 4
    la a0, output_char_msg
    ecall

    # Print the most frequent character
    li a7, 11               # Service code for print_char
    mv a0, s4               # Character to print
    ecall

    # Print frequency message
    li a7, 4
    la a0, output_freq_msg
    ecall

    # Print the max frequency
    li a7, 1                # Service code for print_int
    mv a0, s2               # Frequency to print
    ecall

    # Print positions message
    li a7, 4
    la a0, output_pos_msg
    ecall

    # Print the stored positions
    li t0, 0                # t0 = loop counter for positions
    la t1, positions        # t1 = base address of positions array
print_pos_loop:
    bge t0, s7, print_pos_done # if counter >= position_count, done

    lw a0, 0(t1)            # a0 = position to print
    li a7, 1                # Print integer
    ecall

    li a7, 4                # Print space
    la a0, space
    ecall

    addi t1, t1, 4          # Move to next position in array
    addi t0, t0, 1          # Increment counter
    j print_pos_loop
print_pos_done:
    li a7, 4                # Print final newline
    la a0, newline
    ecall
    j exit                  # Go to exit after printing results

no_uppercase:
    li a7, 4
    la a0, no_uppercase_msg
    ecall
    # Fall through to exit

exit:
    li a7, 10               # Service code for exit
    ecall