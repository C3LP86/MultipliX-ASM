global _start

section .data
    GuestPromptA db 'Enter a value for A : '
    GuestPromptA_Len equ $-GuestPromptA
    GuestPromptB db 'Enter a value for B : '
    GuestPromptB_Len equ $-GuestPromptB
    GuestPrompt_Result db 'Result : '
    GuestPrompt_Result_Len equ $-GuestPrompt_Result
    buffer times 100 db 0                                       ; buffer of 100 bytes filled with 0
    Result_Buffer times 20 db 0                                 ; buffer to store the result as a string

section .text

_start:
    ; Display the first input message:
    mov rax, 1                                                  ; syscall write
    mov rdi, 1                                                  ; file descriptor stdout
    mov rsi, GuestPromptA                                       ; address of GuestPromptA    
    mov rdx, GuestPromptA_Len                                   ; size of GuestPromptA
    syscall

    ; User input for value A:
    mov rax, 0                                                  ; syscall read
    mov rdi, 0                                                  ; file descriptor stdin
    mov rsi, buffer                                             ; buffer to store user input
    mov rdx, 100                                                ; max size to read
    syscall

    ; Convert the string to an integer (value A):
    mov rsi, buffer                                             ; pointer to the start of the string
    xor rax, rax                                                ; clear rax (the integer value)
    xor rcx, rcx                                                ; rcx = 0 (counter)

convert_loop_A :
    movzx rbx, byte [rsi + rcx]                                 ; read the character (1 byte) into rbx
    cmp rbx, 0xA                                                ; check if we reached the end (0xA = '\n')
    je conversion_done_A                                        ; jump to the end if it's '\n'

    sub rbx, '0'                                                ; convert from ASCII to numerical value
    imul rax, rax, 10                                           ; multiply rax by 10 (for the digit's position)
    add rax, rbx                                                ; add the digit to rax
    inc rcx                                                     ; move to the next character
    jmp convert_loop_A                                          ; repeat the loop

conversion_done_A:
    mov r8, rax                                                 ; store value A in r8

    ; Display the second input message:
    mov rax, 1                                                  ; syscall write
    mov rdi, 1                                                  ; file descriptor stdout
    mov rsi, GuestPromptB                                       ; address of GuestPromptB
    mov rdx, GuestPromptB_Len                                   ; size of GuestPromptB
    syscall

    ; User input for value B:
    mov rax, 0                                                  ; syscall read
    mov rdi, 0                                                  ; file descriptor stdin
    mov rsi, buffer                                             ; buffer to store user input
    mov rdx, 100                                                ; max size to read
    syscall

    ; Convert the string to an integer (value B):
    mov rsi, buffer                                             ; pointer to the start of the string
    xor rax, rax                                                ; clear rax (the integer value)
    xor rcx, rcx                                                ; rcx = 0 (counter)

convert_loop_B:
    movzx rbx, byte [rsi + rcx]                                 ; read the character (1 byte) into rbx
    cmp rbx, 0xA                                                ; check if we reached the end (0xA = '\n')
    je conversion_done_B                                        ; jump to the end if it's '\n'

    sub rbx, '0'                                                ; convert from ASCII to numerical value
    imul rax, rax, 10                                           ; multiply rax by 10 (for the digit's position)
    add rax, rbx                                                ; add the digit to rax
    inc rcx                                                     ; move to the next character
    jmp convert_loop_B                                          ; repeat the loop

conversion_done_B:
    mov r9, rax                                                 ; store value B in r9

    ; Multiply A * B:
    imul r8, r9                                                 ; r8 now contains A * B

    ; Convert the result to a string for display:
    mov rax, r8                                                 ; rax contains the result of the multiplication
    mov rdi, Result_Buffer                                      ; pointer to the buffer to store the string
    call int_to_string                                          ; convert to a string

    mov byte [Result_Buffer + rcx], 0x0A                        ; add '\n' (newline) to the end of the buffer
    inc rcx                                                     ; increment the length counter
    
    ; Display the final result message:
    mov rax, 1                                                  ; syscall write
    mov rdi, 1                                                  ; file descriptor stdout
    mov rsi, GuestPrompt_Result                                 ; address of GuestPrompt_Result    
    mov rdx, GuestPrompt_Result_Len                             ; size of GuestPrompt_Result
    syscall

    ; Display the result:
    mov rax, 1                                                  ; syscall write
    mov rdi, 1                                                  ; file descriptor stdout
    mov rsi, Result_Buffer                                      ; address of the buffer containing the result string
    mov rdx, 20                                                 ; max size to display (in this case, 20 bytes)
    syscall

    ; End the program:
    mov rax, 60                                                 ; syscall exit
    mov rdi, 0                                                  ; exit code 0
    syscall

; ------------------------------------------------------ ;
; Function to convert an integer to an ASCII string      ;
; ------------------------------------------------------ ;

int_to_string:
    mov rbx, 10                                                 ; divisor (base 10)
    xor rcx, rcx                                                ; counter for string length

convert_digit:
    xor rdx, rdx                                                ; clear rdx for division
    div rbx                                                     ; divide rax by 10, quotient in rax, remainder in rdx
    add dl, '0'                                                 ; convert remainder to ASCII character
    mov [rdi + rcx], dl                                         ; store the character in the buffer
    inc rcx                                                     ; increment position in the buffer
    test rax, rax                                               ; check if the quotient is zero
    jnz convert_digit                                           ; if not zero, continue dividing

    ; Reverse the order of the characters to get the correct result:
    mov rsi, rdi                                                ; starting pointer
    add rdi, rcx                                                ; rdi points to the end of the string
    dec rdi                                                     ; move back to avoid the '\n'

reverse_loop:
    cmp rsi, rdi                                                ; if the pointers cross, we're done
    jge reverse_done
    mov al, [rsi]                                               ; swap characters
    mov bl, [rdi]
    mov [rdi], al
    mov [rsi], bl
    inc rsi
    dec rdi
    jmp reverse_loop

reverse_done:
    ret                                                         ; return to the main code