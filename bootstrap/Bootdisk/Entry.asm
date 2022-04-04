[bits 32]
SECTION .text

bootstrapStart32:
    mov esp, BootstrapStackPointer

    ;; Make the end of the GC stack frame
    push 0
    mov ebp, esp
    push 0

    ;; Use the extended memory for the HEAP
    mov eax, 0x00100000
    mov [ObjectModel.Heap.StartAddress], eax
    mov [ObjectModel.Heap.NextAllocationAddress], eax
    add eax, 0x00E00000
    mov [ObjectModel.Heap.EndAddress], eax

    call Console.clear

    ;; Initialize the bootstrap environment
    call BootstrapEnvironment.Initialize

    ;; Run the startup script.
    call BootstrapEnvironment.RunStartupScript

    mov esi, .helloWorldString.elements
    mov ecx, .helloWorldString.size
    call Console.putString

    call systemPrimitiveExit


.helloWorldString.elements:
    db 'Hello World!!'
.helloWorldString.size equ $ - .helloWorldString.elements

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
    jmp Console.putString

;; systemPrimitiveExit :: Exit Code (EAX)
GLOBAL systemPrimitiveExit
systemPrimitiveExit:
    hlt
    jmp $