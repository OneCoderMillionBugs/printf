default rel
bits 64

section .text
extern _write
global wx64print

; Use of registers:
; rbx - current format string address
; r8  - output string index
; rdi - arg number

wx64print:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 4192
    ; Process register arguments
    mov     [rbp - 08], rcx
    mov     [rbp - 16], rdx
    mov     [rbp - 24], r8
    mov     [rbp - 32], r9
    movsd   [rbp - 40], xmm1
    movsd   [rbp - 48], xmm2
    movsd   [rbp - 56], xmm3
    xor     r8, r8
    xor     rdi, rdi
    ; Load the format string
    mov     rbx, [rbp - 08]
.fsloop:
    mov     cl, [rbx]
    cmp     cl, 0       ; null
    jz      .end
    cmp     cl, 37      ; %
    jz      .nextarg
    mov     [rbp - 4160 + r8], cl
    inc     r8
    inc     rbx
    jmp     .fsloop
.nextarg:
    ; Fetch next argument
    inc     rbx
    inc     rdi
    mov     cl, [rbx]
    cmp     cl, 99      ; c
    jz      .argc
    cmp     cl, 100     ; d
    jz      .argd
    cmp     cl, 115     ; s
    jz      .args
.argc:
    ; Character argument
    cmp     rdi, 1
    cmovz   rcx, [rbp - 16]
    cmp     rdi, 2
    cmovz   rcx, [rbp - 24]
    cmp     rdi, 3
    cmovz   rcx, [rbp - 32]
    cmp     rdi, 4
    cmovae  rcx, [rbp + rdi * 8 + 16]
    mov     [rbp - 4160 + r8], cl
    inc     r8
    inc     rbx
    jmp     .fsloop
.argd:
    ; Signed int argument
    cmp     rdi, 1
    cmovz   rcx, [rbp - 16]
    cmp     rdi, 2
    cmovz   rcx, [rbp - 24]
    cmp     rdi, 3
    cmovz   rcx, [rbp - 32]
    cmp     rdi, 4
    cmovae  rcx, [rbp + rdi * 8 + 16]
    ; Save the start of the string
    mov     rsi, r8
    cmp     ecx, 0
    jl      .sign
    jmp     .loop1
.sign:
    mov     byte [rbp - 4160 + r8], 45 ; -
    neg     ecx
    inc     r8
    ; Save the start of the string
    mov     rsi, r8
.loop1:
    mov     rax, rcx
    mov     r9, rax
    imul    r9, 429496730
    sar     r9, 32
    mov     rcx, r9
    imul    r9, 10
    cmp     r9, rax
    jg      .p1
    sub     rax, r9
    add     rax, 48     ; 0
    mov     [rbp - 4160 + r8], al
    inc     r8
    cmp     rcx, 0
    jz      .break1
    jmp     .loop1
.p1:
    ; Fix possible inaccuracy
    sub     r9, rax
    mov     rax, 10
    sub     rax, r9
    add     rax, 48     ; 0
    mov     [rbp - 4160 + r8], al
    inc     r8
    cmp     rcx, 0
    jz      .break1
    dec     rcx
    jmp     .loop1
.break1:
    ; Reverse the number
    mov     rax, r8
    dec     rax
    mov     r9, rsi
.loop2:
    mov     sil, [rbp - 4160 + rax]
    mov     dl, [rbp - 4160 + r9]
    mov     [rbp - 4160 + rax], dl
    mov     [rbp - 4160 + r9], sil
    dec     rax
    inc     r9
    cmp     rax, r9
    jle     .break2
    jmp     .loop2
.break2:
    inc     rbx
    jmp     .fsloop
.args:
    ; String argument
    cmp     rdi, 1
    cmovz   rcx, [rbp - 16]
    cmp     rdi, 2
    cmovz   rcx, [rbp - 24]
    cmp     rdi, 3
    cmovz   rcx, [rbp - 32]
    cmp     rdi, 4
    cmovae  rcx, [rbp + rdi * 8 + 16]
.loop3:
    mov     rax, [rcx]
    cmp     al, 0
    jz      .break3
    mov     [rbp - 4160 + r8], al
    inc     rcx
    inc     r8
    jmp     .loop3
.break3:
    inc     rbx
    jmp     .fsloop
.end:
    mov     byte [rbp - 4160 + r8], 0
    mov     rcx, 1
    lea     rdx, [rbp - 4160]
    mov     [rbp - 64], r8
    call    _write
    mov     rax, [rbp - 64]
    add     rsp, 4192
    leave
    ret