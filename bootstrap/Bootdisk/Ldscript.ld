ENTRY(bootsectorEntry)

SECTIONS {
    .bootsector (0x7C00) : {
        *(.bootsector)
    }

    .text : {
        *(.text)
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss)
    }
}
