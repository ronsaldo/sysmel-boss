ObjectLayoutType.Pointers equ 0
ObjectLayoutType.Bytes equ 1
ObjectLayoutType.Immediate equ 2

%define SmallIntegerLiteral(x) ((x) << 1) | 1

;; The object header layout
STRUC ObjectHeader
    .objectSize: resd 1
    .relocationTarget: resd 1

    .type: resd 1
    .layoutType: resb 1
    .gcColor: resb 1
    .reserved: resb 2
ENDSTRUC

;; The base type0
STRUC Type0
    .header: resb ObjectHeader_size
    .methodDictionary: resd 1
    .fixedSize: resd 1 ;; Natural
    .layoutType: resd 1 ;; Natural
    .variableElementSize: resd 1 ;; Natural
ENDSTRUC

;; An array list
STRUC ArrayList
    .header: resb ObjectHeader_size
    .size: resd 1 ;; Natural
    .values: resd 1 ;; Array()
ENDSTRUC

;; A set
STRUC Set
    .header: resb ObjectHeader_size
    .size: resd 1 ;; Natural
    .values: resd 1 ;; Array()
ENDSTRUC

;; A dictionary
STRUC Dictionary
    .header: resb ObjectHeader_size
    .size: resd 1 ;; Natural
    .keys: resd 1 ;; Array()
    .values: resd 1 ;; Array()
ENDSTRUC

;; A token
STRUC Token
    .header: resb ObjectHeader_size
    .type: resd 1 ;; Natural
    .value: resd 1 ;; CollectionInterval
ENDSTRUC

;; Image root object
STRUC ImageRootObject
    .header: resb ObjectHeader_size
    .Type0: resd 1
    .ImageRootObjectType: resd 1
    .ArrayType: resd 1
    .ArrayListType: resd 1
    .SetType: resd 1
    .DictionaryType: resd 1
    .StringType: resd 1
    .SymbolType: resd 1
    .SmallIntegerType: resd 1
    .TokenType: resd 1
    .InternedSymbolSet: resd 1
    .SystemDictionary: resd 1
ENDSTRUC

%define gcLocalAt(index) ((index) + 2) * -4

%macro buildGCStackFrame 2
    push ebp
    mov ebp, esp

    push (%1 | ((%2) << 8))

    %rep %2
    push 0
    %endrep
%endmacro

%macro destroyGCStackFrame 0
    mov esp, ebp
    pop ebp
%endmacro


SECTION .text

;; ObjectModel.Heap.BasicNewPointersObject :: ObjectSizeInBytes (ECX) -> ObjectPointer (EDI)
GLOBAL ObjectModel.BasicNewPointersObject
ObjectModel.Heap.BasicNewPointersObject:
    call ObjectModel.Heap.AllocateObjectSpace

    mov dword [edi + ObjectHeader.objectSize], ecx
    mov byte [edi + ObjectHeader.layoutType], ObjectLayoutType.Pointers
    mov al, [ObjectModel.Heap.WhiteColor]
    mov byte [edi + ObjectHeader.gcColor], al

    ret

;; ObjectModel.Heap.BasicNewTypeWithType0 :: TypePointer (ESI), Variable Data Size (ECX), ObjectPointer (EDI)
GLOBAL ObjectModel.BasicNewWithType
ObjectModel.Heap.BasicNewWithType:
    buildGCStackFrame 0, 0

    push esi
    push ecx

    mov eax, [esi + Type0.variableElementSize]
    shr eax, 1
    imul ecx, eax

    mov eax, [esi + Type0.fixedSize]
    shr eax, 1
    add ecx, eax
    
    call ObjectModel.Heap.BasicNewPointersObject

    mov dword [edi + ObjectHeader.objectSize], 0
    mov byte [edi + ObjectHeader.layoutType], ObjectLayoutType.Pointers
    mov al, [ObjectModel.Heap.WhiteColor]
    mov byte [edi + ObjectHeader.gcColor], al

    pop ecx
    pop esi

    destroyGCStackFrame
    ret

GLOBAL ObjectModel.BuildImageRootObject
ObjectModel.BuildImageRootObject:
    buildGCStackFrame 0, 0

    ;; Image root object.
    mov ecx, ImageRootObject_size
    call ObjectModel.Heap.BasicNewPointersObject
    mov [ObjectModel.Heap.ImageRootObject], edi

    ;; Type0
    mov ecx, Type0_size
    call ObjectModel.Heap.BasicNewPointersObject
    mov dword [edi + Type0.fixedSize], SmallIntegerLiteral(Type0_size)
    mov dword [edi + Type0.layoutType], SmallIntegerLiteral(ObjectLayoutType.Pointers)
    mov ebx, [ObjectModel.Heap.ImageRootObject]
    mov [ebx + ImageRootObject.Type0], edi

    ;; ImageRootObjectType
    mov esi, [ebx + ImageRootObject.Type0]
    xor ecx, ecx
    call ObjectModel.Heap.BasicNewWithType
    
    mov dword [edi + Type0.fixedSize], SmallIntegerLiteral(ImageRootObject_size)
    mov dword [edi + Type0.layoutType], SmallIntegerLiteral(ObjectLayoutType.Pointers)
    mov [ebx + ObjectHeader.type], edi
    mov [ebx + ImageRootObject.ImageRootObjectType], edi

    ;; ArrayType
    mov esi, [ebx + ImageRootObject.Type0]
    xor ecx, ecx
    call ObjectModel.Heap.BasicNewWithType
    
    mov dword [edi + Type0.fixedSize], SmallIntegerLiteral(ObjectHeader_size)
    mov dword [edi + Type0.layoutType], SmallIntegerLiteral(ObjectLayoutType.Pointers)
    mov [ebx + ImageRootObject.ArrayType], edi

    ;; ArrayList
    mov esi, [ebx + ImageRootObject.Type0]
    xor ecx, ecx
    call ObjectModel.Heap.BasicNewWithType
    
    mov dword [edi + Type0.fixedSize], SmallIntegerLiteral(ArrayList_size)
    mov dword [edi + Type0.layoutType], SmallIntegerLiteral(ObjectLayoutType.Pointers)
    mov [ebx + ImageRootObject.ArrayListType], edi

    ;; Set
    mov esi, [ebx + ImageRootObject.Type0]
    xor ecx, ecx
    call ObjectModel.Heap.BasicNewWithType
    
    mov dword [edi + Type0.fixedSize], SmallIntegerLiteral(Set_size)
    mov dword [edi + Type0.layoutType], SmallIntegerLiteral(ObjectLayoutType.Pointers)
    mov [ebx + ImageRootObject.SetType], edi

    ;; Dictionary
    mov esi, [ebx + ImageRootObject.Type0]
    xor ecx, ecx
    call ObjectModel.Heap.BasicNewWithType
    
    mov dword [edi + Type0.fixedSize], SmallIntegerLiteral(Dictionary_size)
    mov dword [edi + Type0.layoutType], SmallIntegerLiteral(ObjectLayoutType.Pointers)
    mov [ebx + ImageRootObject.DictionaryType], edi

    ;; String
    mov esi, [ebx + ImageRootObject.Type0]
    xor ecx, ecx
    call ObjectModel.Heap.BasicNewWithType
    
    mov dword [edi + Type0.fixedSize], SmallIntegerLiteral(ObjectHeader_size)
    mov dword [edi + Type0.layoutType], SmallIntegerLiteral(ObjectLayoutType.Bytes)
    mov [ebx + ImageRootObject.StringType], edi

    ;; Symbol
    mov esi, [ebx + ImageRootObject.Type0]
    xor ecx, ecx
    call ObjectModel.Heap.BasicNewWithType
    
    mov dword [edi + Type0.fixedSize], SmallIntegerLiteral(ObjectHeader_size)
    mov dword [edi + Type0.layoutType], SmallIntegerLiteral(ObjectLayoutType.Bytes)
    mov [ebx + ImageRootObject.SymbolType], edi

    ;; Symbol
    mov esi, [ebx + ImageRootObject.Type0]
    xor ecx, ecx
    call ObjectModel.Heap.BasicNewWithType
    
    mov dword [edi + Type0.fixedSize], SmallIntegerLiteral(ObjectHeader_size)
    mov dword [edi + Type0.layoutType], SmallIntegerLiteral(ObjectLayoutType.Bytes)
    mov [ebx + ImageRootObject.SymbolType], edi

    ;; SmallInteger
    mov esi, [ebx + ImageRootObject.Type0]
    xor ecx, ecx
    call ObjectModel.Heap.BasicNewWithType
    
    mov dword [edi + Type0.fixedSize], SmallIntegerLiteral(ObjectHeader_size)
    mov dword [edi + Type0.layoutType], SmallIntegerLiteral(ObjectLayoutType.Immediate)
    mov [ebx + ImageRootObject.SmallIntegerType], edi

    ;; Token
    mov esi, [ebx + ImageRootObject.Type0]
    xor ecx, ecx
    call ObjectModel.Heap.BasicNewWithType
    
    mov dword [edi + Type0.fixedSize], SmallIntegerLiteral(Token_size)
    mov dword [edi + Type0.layoutType], SmallIntegerLiteral(ObjectLayoutType.Immediate)
    mov [ebx + ImageRootObject.TokenType], edi

    ;; InternedSymbolSet
    mov esi, [ebx + ImageRootObject.SetType]
    xor ecx, ecx
    call ObjectModel.Heap.BasicNewWithType
    mov [ebx + ImageRootObject.InternedSymbolSet], edi

    ;; SystemDictionary
    mov esi, [ebx + ImageRootObject.DictionaryType]
    xor ecx, ecx
    call ObjectModel.Heap.BasicNewWithType
    mov [ebx + ImageRootObject.SystemDictionary], edi

    destroyGCStackFrame
    ret