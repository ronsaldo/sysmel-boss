;; This must be the first included file always.
%include "Bootdisk/Bootsector.asm"

;; Common definitions.
%include "Bootdisk/Registers.asm"
%include "Bootdisk/Types.asm"

;; Bootstrap entry point.
%include "Bootdisk/Entry.asm"

;; Library functions
%include "Bootdisk/Console.asm"

;; The interpreter
%include "Interpreter/Interpreter.asm"