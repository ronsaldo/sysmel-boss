SECTION .text

;; The object header layout
STRUC ObjectHeader
    .objectSize: resd 1
    .relocationTarget: resd 1
    .layoutType: resb 1
    .color: resb 1
    .reserved: resb 2
ENDSTRUC

;; A class behavior
STRUC TypeBehavior
    .header: resb ObjectHeader_size
    .methodDictionary: resd 1
ENDSTRUC

;; A dictionary
STRUC Dictionary
    .header: resb ObjectHeader_size
    .capacity: resd 1
    .size: resd 1
ENDSTRUC

;; Image root object
STRUC ImageRootObject
    .header: resb ObjectHeader_size
    .ImageRootObjectType: resb TypeBehavior_size
    .StringType: resb TypeBehavior_size
    .NaturalType: resb TypeBehavior_size
    .IntegerType: resb TypeBehavior_size
    .RationalType: resb TypeBehavior_size
    .FloatType: resb TypeBehavior_size
ENDSTRUC

%define BuildGCStackFrameDescriptors(rootCount) push rootCount

;; ObjectModel.Heap.AllocateObjectSpace :: ObjectSizeInBytes (ECX) -> ObjectPointer (EDI)
GLOBAL ObjectModel.Heap.AllocateObjectSpace
ObjectModel.Heap.AllocateObjectSpace:
    mov eax, [ObjectModel.Heap.NextAllocationAddress]
    add eax, ecx
    cmp eax, [ObjectModel.Heap.EndAddress]
    ja .heapOutOfMemory
    mov edi, eax
    ret

.heapOutOfMemory:
    ;; Attempt garbage collection
    push ecx
    push ebp
    mov ebp, esp
    BuildGCStackFrameDescriptors(0)

    call ObjectModel.Heap.GarbageCollect

    mov esp, ebp
    pop ebp
    pop ecx

    ;; Try again
    mov eax, [ObjectModel.Heap.NextAllocationAddress]
    add eax, ecx
    cmp eax, [ObjectModel.Heap.EndAddress]
    ja .increaseHeapSize
    mov edi, eax
    ret

.increaseHeapSize:
    jmp $

GLOBAL ObjectModel.Heap.GarbageCollect
ObjectModel.Heap.GarbageCollect:
    jmp $

SECTION .data
GLOBAL ObjectModel.Heap.StartAddress
ObjectModel.Heap.StartAddress: dd 0

GLOBAL ObjectModel.Heap.EndAddress
ObjectModel.Heap.EndAddress: dd 0

GLOBAL ObjectModel.Heap.NextAllocationAddress
ObjectModel.Heap.NextAllocationAddress: dd 0
