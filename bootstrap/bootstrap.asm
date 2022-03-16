;; This must be the first included file always.
%include "bootsector.asm"

;; Common definitions.
%include "registers.asm"
%include "types.asm"

;; Bootstrap entry point.
%include "entry.asm"

;; Library functions
%include "console.asm"
