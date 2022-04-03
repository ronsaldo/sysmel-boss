SECTION .text

;; Text mode vram
Console.VRAM equ 0xB8000
Console.Columns equ 80
Console.Rows equ 24
Console.Characters equ Console.Columns*Console.Rows

;; Clear the whole console.
GLOBAL Console.clear
Console.clear:
    push edi
    push ecx

    xor eax, eax
    mov edi, Console.VRAM
    mov ecx, Console.Characters
    rep stosw

    mov dword [Console.cursorIndex], 0
    mov byte [Console.cursorRow], 0
    mov byte [Console.cursorColumn], 0

    pop ecx
    pop edi
    ret

;; Puts an ASCII character in the console. Character in AL
GLOBAL Console.putChar
Console.putChar:
    mov ah, 07h

;; Puts a colored character in the console. Character in AL, color in AH
GLOBAL Console.putColoredChar
Console.putColoredChar:
    push edi
    
    mov edi, [Console.cursorIndex]
    mov [Console.VRAM + edi*2], ax
    inc dword [Console.cursorIndex]
    
    pop edi
    jmp Console.advanceColumn

;; String pointer in ESI, String size in ECX
GLOBAL Console.putString
Console.putString:
    mov al, [esi]
    dec ecx
    inc esi
    call Console.putChar
    test ecx, ecx
    jnz Console.putString
    ret

Console.advanceColumn:
    ret

SECTION .data
GLOBAL Console.cursorIndex
Console.cursorIndex: dd 0

GLOBAL Console.cursorRow
Console.cursorRow: db 0

GLOBAL Console.cursorColumn
Console.cursorColumn: db 0