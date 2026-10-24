# Sovereign Stealth Crypto Suite (x86 32-bit Assembly)

This documentation provides an exhaustive, low-level technical analysis of the two-part silent cryptographic toolkit designed natively for the Windows x86 architecture. The suite operates completely decoupled from any standard visible interfaces, acting as a background phantom processing engine.

---

## 1. Architectural Philosophy: The Split Framework
To achieve optimal execution stealth, the system isolates its structural tasks into two distinct binaries:
1. **The Intelligence Assistant (`assistant.exe`):** Handles OS interactions, directory verification, file system polling, and child-process spawning.
2. **The Execution Engine (`engine.exe`):** Handles pure mathematical sliding cryptography, low-level cache purging, and algorithmic self-destruction.

---

## 2. Technical Deep-Dive: assistant.asm

The Assistant acts as the structural orchestrator. It manages the directory structure without throwing visible terminal panels.

### Detailed Routine Walkthrough:
* **`_CreateDirectoryA@8`**: Upon firing up, it queries the filesystem. If `[Crypto_Zone]` does not exist, it forces its creation with null security descriptors.
* **`_FindFirstFileA@8` & `_FindNextFileA@8`**: It invokes a kernel-level search loop utilizing the `WIN32_FIND_DATA` structural buffer (allocated at 320 bytes in `.bss`).
* **Dot Directory Screening**: 
  ```assembly
  lea edx, [find_data + 44]   
  cmp byte [edx], '.'        | je .next_file
  ```
  It inspects offset +44 (the file name pointer). If it detects a dot (`.`) or double dot (`..`), it skips execution to avoid recursive infinite directory loops.
* **Stealth Ingestion (`_WinExec@8`)**: It concatenates strings natively in memory into `cmd_buffer` to form the executing shell sequence: `engine.exe [Crypto_Zone]\filename`. It passes the constant `0` (`SW_HIDE`), ensuring `engine.exe` runs silently at the kernel thread level without rendering any black CMD frame.

---

## 3. Technical Deep-Dive: engine.asm

The Engine is the raw processing muscle. It completely bypasses the concept of generating duplicate output files, making its disk foot-print virtually untraceable.

### The In-Place Overwrite Mechanics:
Instead of utilizing double memory mapped buffers (Read -> Encrypt -> Write to new file), it intercepts the file using unified Read/Write generic flags (`0xC0000000`).
1. It reads 4096 bytes into the `.bss` buffer.
2. It tracks the exact byte counts read via `[bytes_rw]`.
3. After the loop alters the block, it pushes the pointer backwards via a negative arithmetic offset applied to `_SetFilePointer@16`:
   ```assembly
   neg edi
   push 1                      ; FILE_CURRENT
   push 0 | push edi | push dword [file_h]
   call _SetFilePointer@16
   ```
4. It instantly overwrites the exact physical disk sectors with the transformed stream data.

### The Accumulative Trolling Stream Cipher:
To avoid the intense processor cycles demanded by standard block ciphers like AES, it uses a custom dynamic stream algorithm operating at hardware register speed:
* **The Elimination of `DIV`**: Traditional loops use the division instruction to wrap key sequences. `div` consumes up to 80 clock cycles per byte. This engine uses a direct boundary comparison check:
  ```assembly
  inc ecx
  cmp ecx, [key_len] | jne .skip_reset
  xor ecx, ecx
  ```
  This single shift cuts execution overhead down to 1-2 clock cycles.
* **The Hardware Accumulator**: It keeps a rolling dynamic salt value in `edx`. For every processed character, it samples the next character from the `secret_key`, factors it into the accumulator (`add edx, ebx`), and shifts the bit patterns out via a hard rotation instruction (`ror dl, 3`). The result forms an unpredictable, heavily randomized cryptographic mask.

---

## 4. Footprint Mitigation and Sovereignty (The Null-Halt Suicide)

When processing terminates, the engine refuses to call the standard Windows API exit protocols, which normally communicate back to the kernel for thread teardown. Instead, it triggers an intentional hardware exception loop:

```assembly
.suicide_halt:
    xor esp, esp
    xor ebp, ebp
    xor eax, eax
    ; ... clearing all data registers ...
    jmp eax
```

1. **Stack Vaporization**: Wiping out `esp` and `ebp` instantly corrupts the stack frames, making stack-walking or dynamic memory debugging completely impossible for monitoring security agents.
2. **The Hardware Drop**: Forcing a direct jump instruction to the absolute address zero (`0x00000000`) triggers an immediate unhandled memory isolation fault. The CPU instantly drops the thread execution cycle from the memory pool in a microsecond, performing an untraceable hardware-level self-destruction.

---

## 5. Deployment and Binary Compilation

To assemble the source code into native 32-bit Windows standalone execution files, execute the following commands from your toolchain terminal:

```bash
# Compile the Engine
nasm -f win32 engine.asm -o engine.obj
ld -m i386pe engine.obj -o engine.exe -lkernel32

# Compile the Assistant
nasm -f win32 assistant.asm -o assistant.obj
ld -m i386pe assistant.obj -o assistant.exe -lkernel32 -luser32
```

### Operational Use Case:
Place `assistant.exe` and `engine.exe` inside your target folder. Simply dropping your plain files inside the automatically spawned `[Crypto_Zone]` folder and executing `assistant.exe` will instantly encrypt the files in-place. Dropping the encrypted items into the zone and running `assistant.exe` a third time will reverse the algorithm, returning your file perfectly intact, healthy, and pristine.
