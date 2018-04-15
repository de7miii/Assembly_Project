global _main
section .data
A: dd 4
timee: dd 0
threshold: dd 0
section .bss
section .text
_main:
    mov ebp, esp; for correct debugging
    ;write your code here
    mfence
    lfence
    rdtsc
    lfence
    mov esi, eax
    mov eax, [A]
    rdtsc
    sub esi, eax
    clflush [A]
    mov ebx, 10000
    mov eax, esi
    xor edx,edx
    div ebx
    mov esi, eax
    mov [timee], esi
    
    xor eax,eax
    xor esi,esi
    mfence
    lfence
    rdtsc
    lfence
    mov esi, eax
    mov eax, [A]
    rdtsc
    sub esi, eax
    mov ebx, 10000
    mov eax, esi
    xor edx,edx
    div ebx
    mov esi, eax
    mov [threshold], esi
    
    ret