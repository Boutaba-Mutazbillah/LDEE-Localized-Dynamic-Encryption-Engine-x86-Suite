section .data
    extern _CreateDirectoryA@8, _FindFirstFileA@8, _FindNextFileA@8, _FindClose@4, _WinExec@8, _ExitProcess@4
    zone_dir      db "[Crypto_Zone]", 0
    search_path   db "[Crypto_Zone]\*.*", 0
    engine_name   db "engine.exe ", 0

section .bss
    find_h        resd 1
    find_data     resb 320
    cmd_buffer    resb 1024

section .text
    global _start

_start:
    push 0
    push zone_dir
    call _CreateDirectoryA@8

    push find_data
    push search_path
    call _FindFirstFileA@8
    cmp eax, -1                 | je .exit
    mov [find_h], eax

.file_loop:
    lea edx, [find_data + 44]   
    cmp byte [edx], '.'        | je .next_file
    
    push edx
    call .build_command

    push 0                      
    push cmd_buffer
    call _WinExec@8

.next_file:
    push find_data
    push dword [find_h]
    call _FindNextFileA@8
    test eax, eax               | jnz .file_loop

    push dword [find_h]         | call _FindClose@4

.exit:
    push 0                      | call _ExitProcess@4

.build_command:
    mov ecx, [esp + 4]
    mov edi, cmd_buffer
    mov esi, engine_name
.copy_engine:
    lodsb                       | stosb
    test al, al                 | jnz .copy_engine
    dec edi                     
    
    mov esi, zone_dir
.copy_zone:
    lodsb                       | stosb
    test al, al                 | jnz .copy_zone
    dec edi
    
    mov al, '\'                 | stosb
    mov esi, ecx
.copy_file:
    lodsb                       | stosb
    test al, al                 | jnz .copy_file
    ret 4
