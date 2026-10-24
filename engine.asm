section .data
    extern _CreateFileA@28, _ReadFile@20, _WriteFile@20, _SetFilePointer@16, _CloseHandle@4
    secret_key db "SovereignKey1", 0
    key_len    dd 13

section .bss
    buffer       resb 4096
    bytes_rw     resd 1
    file_h       resd 1

section .text
    global _start

_start:
    mov eax, [esp + 8]
    test eax, eax               | jz .suicide_halt
    
    push 0 | push 1 | push 3 | push 0 | push 1 | push 0xC0000000 | push eax
    call _CreateFileA@28
    cmp eax, -1                 | je .suicide_halt
    mov [file_h], eax

    xor ecx, ecx                
    xor edx, edx                

.read_loop:
    push 0 | push bytes_rw | push 4096 | push buffer | push dword [file_h]
    call _ReadFile@20
    mov edi, [bytes_rw]
    test edi, edi               | jle .done
    xor esi, esi

.process_bytes:
    cmp esi, edi                | jge .write_back
    
    movzx ebx, byte [secret_key + ecx]
    add edx, ebx                
    ror dl, 3                   
    xor bl, dl
    xor byte [buffer + esi], bl 

    inc ecx
    cmp ecx, [key_len]          | jne .skip_reset
    xor ecx, ecx
.skip_reset:
    inc esi                     | jmp .process_bytes

.write_back:
    neg edi
    push 1
    push 0 | push edi | push dword [file_h]
    call _SetFilePointer@16
    neg edi

    push 0 | push bytes_rw | push edi | push buffer | push dword [file_h]
    call _WriteFile@20
    jmp .read_loop

.done:
    push dword [file_h]         | call _CloseHandle@4

    xor eax, eax                | mov ecx, 1024 | mov edi, buffer | rep stosd

.suicide_halt:
    xor esp, esp                | xor ebp, ebp
    xor eax, eax                | xor ebx, ebx | xor ecx, ecx | xor edx, edx | xor esi, esi | xor edi, edi
    jmp eax
