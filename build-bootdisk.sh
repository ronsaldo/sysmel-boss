#!/bin/sh
set -ex

OBJ="build/bootstrap-bootdisk/obj"
BIN="build/bootstrap-bootdisk/bin"

mkdir -p $OBJ $BIN

yasm -f elf32 -g dwarf2  -o $OBJ/Bootdisk.o -Ibootstrap bootstrap/Bootdisk/EntryPoint.asm 
ld -m elf_i386 -T bootstrap/Bootdisk/Ldscript.ld -o $BIN/Bootdisk.elf $OBJ/Bootdisk.o
objcopy -O binary $BIN/Bootdisk.elf $BIN/Bootdisk.bin