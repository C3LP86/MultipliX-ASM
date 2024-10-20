global _start

section .data
    GuestPromptA db 'Choisissez une valeur A : ', 0x0a
    GuestPromptA_Len equ $-GuestPromptA
    GuestPromptB db 'Choisissez une valeur B : ', 0x0a
    GuestPromptB_Len equ $-GuestPromptB
    buffer times 100 db 0                                       ; buffer de 100 octets remplis avec 0
    Result_Buffer times 20 db 0                                 ; buffer pour stocker le résultat sous forme de chaîne

section .text

_start:
    ; Message pour la première saisie :
    mov rax, 1                                                  ; syscall write
    mov rdi, 1                                                  ; Gestionnaire de fichier stdout
    mov rsi, GuestPromptA                                       ; Addresse du GuestPromptA    
    mov rdx, GuestPromptA_Len                                   ; La taille du GuestPromptA
    syscall

    ; Saisie utilisateur pour la valeur A :
    mov rax, 0                                                  ; syscall read
    mov rdi, 0                                                  ; Gestionnaire de fichier stdin
    mov rsi, buffer                                             ; buffer pour stocker l'entrée utilisateur
    mov rdx, 100                                                ; taille maximale à lire
    syscall

    ; convertion de la chaine de caractère en entier (valeur A) :
    mov rsi, buffer                                             ; pointeur vers le début de la chaîne
    xor rax, rax                                                ; efface rax (valeur entière)
    xor rcx, rcx                                                ; rcx = 0 (compteur)

convert_loop_A :
    movzx rbx, byte [rsi  + rcx]                                ; lire le caractère (1 octet) dans rbx
    cmp rbx, 0xA                                                ; vérifier si on a atteint la fin (0xA = '\n')
    je conversion_done_A                                        ; sauter à la fin si c'est '\n'

    sub rbx, '0'                                                ; convertir de ASCII en valeur numérique
    imul rax, rax, 10                                           ; multiplier rax par 10 (pour la position du chiffre)
    add rax, rbx                                                ; ajouter le chiffre à rax
    inc rcx                                                     ; passer au caractère suivant
    jmp convert_loop_A                                          ; répéter la boucle

conversion_done_A:
    mov r8, rax                                                 ; valeur A

    ; Message pour la seconde saisie :
    mov rax, 1                                                  ; syscall write
    mov rdi, 1                                                  ; Gestionnaire de fichier stdout
    mov rsi, GuestPromptB                                       ; Addresse du GuestPromptB
    mov rdx, GuestPromptB_Len                                   ; La taille du GuestPromptA
    syscall

    ; Saisie utilisateur pour la valeur B :
    mov rax, 0                                                  ; syscall read
    mov rdi, 0                                                  ; Gestionnaire de fichier stdin
    mov rsi, buffer                                             ; buffer pour stocker l'entrée utilisateur
    mov rdx, 100                                                ; taille maximale à lire
    syscall

    ; convertion de la chaine de caractère en entier :
    mov rsi, buffer                                             ; pointeur vers le début de la chaîne
    xor rax, rax                                                ; efface rax (valeur entière)
    xor rcx, rcx                                                ; rcx = 0 (compteur)

convert_loop_B:
    movzx rbx, byte [rsi  + rcx]                                ; lire le caractère (1 octet) dans rbx
    cmp rbx, 0xA                                                ; vérifier si on a atteint la fin (0xA = '\n')
    je conversion_done_B                                        ; sauter à la fin si c'est '\n'

    sub rbx, '0'                                                ; convertir de ASCII en valeur numérique
    imul rax, rax, 10                                           ; multiplier rax par 10 (pour la position du chiffre)
    add rax, rbx                                                ; ajouter le chiffre à rax
    inc rcx                                                     ; passer au caractère suivant
    jmp convert_loop_B                                          ; répéter la boucle

conversion_done_B:
    mov r9, rax                                                 ; Valeur B

    ; Multiplication de A * B :
    imul r8, r9                                                 ; r8 contient maintenant a * B

    ; Convertir le résultat en chaîne de caractères pour l'afficher :
    mov rax, r8                                                 ; rax contient le résultat de la multiplication
    mov rdi, Result_Buffer                                      ; Pointeur vers le buffer pour stocker la chaîne
    call int_to_string                                          ; Convertir en chaîne de caractères

    mov rax, 1                                                  ; syscall write
    mov rdi, 1                                                  ; Gestionnaire de fichier stdout
    mov rsi, Result_Buffer                                      ; Adresse du buffer contenant le résultat sous forme de chaîne
    mov rdx, 20                                                 ; Taille maximale à afficher (dans ce cas, 20 octets)
    syscall

    ; fin du programme :
    mov rax, 60                                                 ; syscall exit
    mov rdi, 0                                                  ; code de sortie 0
    syscall

; ----------------------------------------------------------------;
; Fonction pour convertir un entier en chaîne de caractères ASCII ;
; ----------------------------------------------------------------;

int_to_string:
    mov rbx, 10                                                 ; Diviseur (base 10)
    xor rcx, rcx                                                ; Compteur pour la longueur de la chaîne

convert_digit:
    xor rdx, rdx                                                ; Effacer rdx pour la division
    div rbx                                                     ; Diviser rax par 10, résultat dans rax, reste dans rdx
    add dl, '0'                                                 ; Convertir le reste en caractère ASCII
    mov [rdi + rcx], dl                                         ; Stocker le caractère dans le buffer
    inc rcx                                                     ; Incrémenter la position dans le buffer
    test rax, rax                                               ; Tester si le quotient est zéro
    jnz convert_digit                                           ; Si ce n'est pas zéro, continuer la division

    mov byte [rdi + rcx], 0x0A
    inc rcx

    ; Inverser l'ordre des caractères pour obtenir le bon résultat
    mov rsi, rdi                                                ; Pointeur de départ
    add rdi, rcx                                                ; rdi pointe à la fin de la chaîne
    dec rdi                                                     ; Reculer pour éviter le '\n'

reverse_loop:
    cmp rsi, rdi                                                ; Si les pointeurs se croisent, on a fini
    jge reverse_done
    mov al, [rsi]                                               ; Échanger les caractères
    mov bl, [rdi]
    mov [rdi], al
    mov [rsi], bl
    inc rsi
    dec rdi
    jmp reverse_loop

reverse_done:
    ret                                                         ; Retourner au code principal