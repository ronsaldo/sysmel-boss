[bits 32]
bootstrapStart32:
    mov esp, BootstrapStackPointer
    push ebp

    call Console.clear

    mov esi, .helloWorldString.elements
    mov ecx, .helloWorldString.size
    call Console.putString

    jmp $


.helloWorldString.elements:
    db 'Hello World!!'
.helloWorldString.size equ $ - .helloWorldString.elements

bootstrapEnd:
