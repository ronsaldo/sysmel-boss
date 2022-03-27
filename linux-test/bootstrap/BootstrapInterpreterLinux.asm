[bits 32]

SECTION .text
GLOBAL _start
_start:
    ;; For now just allocate everything in the stack.
    and esp, -16
    mov [ObjectModel.Heap.EndAddress], esp
    sub esp, 4<<20
    mov [ObjectModel.Heap.StartAddress], esp
    mov [ObjectModel.Heap.NextAllocationAddress], esp

    ;; Make the end of the GC stack frame
    push 0
    mov ebp, esp
    push 0

    ;; Initialize the bootstrap environment
    call BootstrapEnvironment.Initialize

    ;; Run the startup script.
    call BootstrapEnvironment.RunStartupScript

    ;; Exit with the default exit code
    xor eax, eax
    call systemPrimitiveExit

;; systemPrimitivePutString :: Character (EAX)
GLOBAL systemPrimitivePutChar
systemPrimitivePutChar:
    push esi
    push ecx
    push ebp
    mov ebp, esp

    push eax
    mov esi, esp
    mov ecx, 1
    call systemPrimitivePutString

    mov esp, ebp
    pop ebp
    pop ecx
    pop esi
    ret

;; systemPrimitivePutString :: Source String (ESI), Source String Size (ECX)
GLOBAL systemPrimitivePutString
systemPrimitivePutString:
    pusha

    mov edx, ecx
    mov ecx, esi
    mov ebx, 0
    mov eax, 4
    xor esi, esi
    int 80h
    
    popa
    ret

;; systemPrimitiveExit :: Exit Code (EAX)
GLOBAL systemPrimitiveExit
systemPrimitiveExit:
    mov ebx, eax
    mov eax, 1
    int 80h
    jmp $

%include "BootstrapInterpreter.asm"
