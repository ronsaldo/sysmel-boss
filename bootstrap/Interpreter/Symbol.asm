SECTION .text

;; Environment.Symbol.InternNativeString :: String Data (ESI) . String Size (ECX) -> ObjectPointer (EDI)
GLOBAL Environment.Symbol.InternNativeString
Environment.Symbol.InternNativeString:
    buildGCStackFrame 0, 0
    push esi
    push ecx
    add ecx, ObjectHeader_size

    pop ecx
    pop esi
    destroyGCStackFrame
    ret
