.data
prompt_size:      .asciz "Enter the number of elements: "
prompt_element:   .asciz "Enter element: "
output_msg:       .asciz "Sorted array: "
space:            .asciz " "
newline:          .asciz "\n"

# Allocate space for the main array and a temporary array for positives
# Assuming a maximum of 100 elements for simplicity
ARRAY_MAX_SIZE:   .word 100
array:            .space 400 # 100 elements * 4 bytes/word
positive_array:   .space 400 # Temporary array for positive numbers

.text
main:
    # --- Get Array Size ---
    li a7, 4
    la a0, prompt_size
    ecall

    li a7, 5            # Read int (size)
    ecall
    mv s1, a0           # s1 = array_size (n)

    # Optional: Validate size > 0 (omitted for brevity, assume valid input)
    # Load max size for boundary check during input
    lw t6, ARRAY_MAX_SIZE
    bgt s1, t6, exit    # Exit if requested size > max size (simple error handling)


    # --- Get Array Elements ---
    la s0, array        # s0 = base address of array
    li t0, 0            # t0 = loop counter (i)
    mv t1, s0           # t1 = current address pointer for array
input_loop:
    bge t0, s1, input_done # if i >= n, done input

    # Prompt for element (optional, can remove for cleaner input)
    # li a7, 4
    # la a0, prompt_element
    # ecall

    li a7, 5            # Read int (element value)
    ecall
    sw a0, 0(t1)        # Store element in array[i]

    addi t1, t1, 4      # Move pointer to next element address
    addi t0, t0, 1      # Increment counter i
    j input_loop
input_done:

    # --- Extract Positive Numbers ---
    la s2, positive_array # s2 = base address of positive_array
    li t0, 0            # t0 = loop counter (i)
    mv t1, s0           # t1 = current address pointer for array
    mv t2, s2           # t2 = current address pointer for positive_array
    li s3, 0            # s3 = positive_count
extract_loop:
    bge t0, s1, extract_done # if i >= n, done extracting

    lw t3, 0(t1)        # t3 = array[i]
    blez t3, skip_positive # if array[i] <= 0, skip

    # It's a positive number
    sw t3, 0(t2)        # Store positive number in positive_array
    addi t2, t2, 4      # Move positive_array pointer
    addi s3, s3, 1      # Increment positive_count

skip_positive:
    addi t1, t1, 4      # Move array pointer
    addi t0, t0, 1      # Increment counter i
    j extract_loop
extract_done:

    # --- Sort Positive Numbers (using Bubble Sort) ---
    # Only sort if there's more than 1 positive number
    li t0, 1
    ble s3, t0, sort_done # if positive_count <= 1, no need to sort

    li t0, 0            # t0 = outer loop counter (i)
sort_outer_loop:
    addi t1, s3, -1     # t1 = positive_count - 1 (outer loop limit)
    bge t0, t1, sort_done # if i >= positive_count - 1, sorting is done

    li t2, 0            # t2 = inner loop counter (j)
    mv t3, s2           # t3 = base address for inner loop comparison (addr of pos[j])
sort_inner_loop:
    # Calculate inner loop limit: positive_count - i - 1
    sub t4, s3, t0
    addi t4, t4, -1
    bge t2, t4, sort_next_outer # if j >= positive_count - i - 1, end inner loop

    # Addresses for comparison
    mv t5, t3           # t5 = address of pos[j]
    addi t6, t3, 4      # t6 = address of pos[j+1]

    # Values for comparison
    lw a0, 0(t5)        # a0 = pos[j]
    lw a1, 0(t6)        # a1 = pos[j+1]

    ble a0, a1, sort_no_swap # if pos[j] <= pos[j+1], no swap needed

    # Swap elements
    sw a1, 0(t5)        # pos[j] = a1
    sw a0, 0(t6)        # pos[j+1] = a0

sort_no_swap:
    addi t3, t3, 4      # Move inner loop base address pointer (for next j)
    addi t2, t2, 1      # Increment j
    j sort_inner_loop

sort_next_outer:
    addi t0, t0, 1      # Increment i
    j sort_outer_loop
sort_done:

    # --- Merge Sorted Positives Back into Original Array ---
    li t0, 0            # t0 = loop counter (i)
    mv t1, s0           # t1 = current address pointer for array
    mv t2, s2           # t2 = current address pointer for sorted positive_array
merge_loop:
    bge t0, s1, merge_done # if i >= n, done merging

    lw t3, 0(t1)        # t3 = original value at array[i]
    blez t3, merge_skip_replace # if original value <= 0, skip replacement

    # Position needs a sorted positive number
    lw t4, 0(t2)        # t4 = next sorted positive number
    sw t4, 0(t1)        # Place it in the original array: array[i] = t4
    addi t2, t2, 4      # Move pointer for sorted positive array

merge_skip_replace:
    addi t1, t1, 4      # Move array pointer
    addi t0, t0, 1      # Increment counter i
    j merge_loop
merge_done:

    # --- Print Result Array ---
    li a7, 4
    la a0, output_msg
    ecall

    li t0, 0            # t0 = loop counter (i)
    mv t1, s0           # t1 = current address pointer for array
print_loop:
    bge t0, s1, print_done # if i >= n, done printing

    lw a0, 0(t1)        # a0 = array[i]
    li a7, 1            # Print integer
    ecall

    li a7, 4            # Print space
    la a0, space
    ecall

    addi t1, t1, 4      # Move pointer
    addi t0, t0, 1      # Increment counter i
    j print_loop
print_done:
    li a7, 4            # Print newline at the end
    la a0, newline
    ecall

    # --- Exit Program ---
exit:
    li a7, 10           # Service code for exit
    ecall