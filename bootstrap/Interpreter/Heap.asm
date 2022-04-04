SECTION .text

;; ObjectModel.Heap.AllocateObjectSpace :: ObjectSizeInBytes (ECX) -> ObjectPointer (EDI)
GLOBAL ObjectModel.Heap.AllocateObjectSpace
ObjectModel.Heap.AllocateObjectSpace:
    mov eax, [ObjectModel.Heap.NextAllocationAddress]
    add eax, ecx
    cmp eax, [ObjectModel.Heap.EndAddress]
    ja .heapOutOfMemory

    mov edi, [ObjectModel.Heap.NextAllocationAddress]
    mov [ObjectModel.Heap.NextAllocationAddress], eax

    call ObjectModel.Heap.ClearAllocatedObject
    ret

.heapOutOfMemory:
    ;; Attempt garbage collection
    buildGCStackFrame 0, 0
    push ecx

    call ObjectModel.Heap.GarbageCollect

    pop ecx
    destroyGCStackFrame

    ;; Try again
    mov eax, [ObjectModel.Heap.NextAllocationAddress]
    add eax, ecx
    cmp eax, [ObjectModel.Heap.EndAddress]
    ja .increaseHeapSize

    mov edi, [ObjectModel.Heap.NextAllocationAddress]
    mov [ObjectModel.Heap.NextAllocationAddress], eax

    call ObjectModel.Heap.ClearAllocatedObject
    ret

.increaseHeapSize:
    jmp $

GLOBAL ObjectModel.Heap.ClearAllocatedObject
ObjectModel.Heap.ClearAllocatedObject:
    push ecx
    push edi

    cld
    xor eax, eax
    shr ecx, 2

    rep stosd

    pop edi
    pop ecx
    ret

GLOBAL ObjectModel.Heap.GarbageCollect
ObjectModel.Heap.GarbageCollect:
    jmp $

SECTION .data
GLOBAL ObjectModel.Heap.StartAddress
ObjectModel.Heap.StartAddress: dd 0

GLOBAL ObjectModel.Heap.ImageRootObject
ObjectModel.Heap.ImageRootObject: dd 0

GLOBAL ObjectModel.Heap.EndAddress
ObjectModel.Heap.EndAddress: dd 0

GLOBAL ObjectModel.Heap.NextAllocationAddress
ObjectModel.Heap.NextAllocationAddress: dd 0

GLOBAL ObjectModel.Heap.WhiteColor
ObjectModel.Heap.WhiteColor: db 0

GLOBAL ObjectModel.Heap.BlackColor
ObjectModel.Heap.BlackColor: db 2