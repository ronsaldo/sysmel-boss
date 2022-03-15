
[bits 16]
[org 0x7c00]

BootstrapLoadBase equ 0x1000
SectorsToRead equ 255

bootsectorEntry:
    mov [bootDrive], dl

    ; Read disk
    mov ah, 02h
    mov al, SectorsToRead
    mov cl, 2h
    mov ch, 0h
    mov dh, 0h

    int 13h
    jc bootError
    ;cmp al, SectorsToRead
    ;jne bootError

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

bootError:
    jmp $

[bits 32]
boot32:
    mov ax, 10h
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    jmp 0x10000

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
