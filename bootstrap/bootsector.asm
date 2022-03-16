
[bits 16]
[org 0x7c00]

BootSectorsToRead equ 63

bootsectorEntry:
    mov [bootDrive], dl

    xor ax, ax
    mov ds, ax
    cld

    ; Read disk
    mov ah, 02h
    mov al, BootSectorsToRead
    mov cl, 2h
    mov ch, 0h
    mov dh, 0h

    xor bx, bx
    mov es, bx
    mov bx, 0x7e00

    int 13h
    jc bootsectorError
    cmp al, BootSectorsToRead
    jne bootsectorError

    ; Disable interrupts.
    cli

    ; Fast a20 gate
    in al, 0x92
    or al, 2
    out 0x92, al

    lgdt [gdtDescriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 8h:boot32

bootsectorError:
    jmp $

[bits 32]
boot32:
    mov ax, 10h
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    jmp 08h:bootstrapStart32

bootDrive: db 0

gdtSegments:
    dq 0h ; Null segment

    dw 0xffff    ; segment length, bits 0-15
    dw 0x0       ; segment base, bits 0-15
    db 0x0       ; segment base, bits 16-23
    db 10011010b ; flags (8 bits)
    db 11001111b ; flags (4 bits) + segment length, bits 16-19
    db 0x0       ; segment base, bits 24-31

    dw 0xffff    ; segment length, bits 0-15
    dw 0x0       ; segment base, bits 0-15
    db 0x0       ; segment base, bits 16-23
    db 10010010b ; flags (8 bits)
    db 11001111b ; flags (4 bits) + segment length, bits 16-19
    db 0x0       ; segment base, bits 24-31

gdtSegmentsEnd:

gdtDescriptor:
    dw gdtSegmentsEnd - gdtSegments - 1
    dd gdtSegments

; padding
times 510 - ($-$$) db 0

dw 0xaa55
