SECTION .text

;; Environment.String.ComputeHash :: String Data (ESI) . String Size (ECX) -> Hash Code (EAX)
GLOBAL Environment.String.ComputeHash
Environment.String.ComputeHash:
    push esi
    push ecx
    push ebx
    mov eax, 123456

.hashLoop:
    cmp ecx, 0
    jz .endHash

    imul eax, 1664525
    movzx ebx, byte [esi]
    add eax, ebx
    and eax, 0x3fffffff

    inc esi
    dec ecx

    jmp .hashLoop
    
.endHash:
    pop ebx
    pop ecx
    pop esi
    ret
