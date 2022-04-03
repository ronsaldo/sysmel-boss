#!/bin/bash

set -ex

OBJ="build/bootstrap-linux/obj"
BIN="build/bootstrap-linux/bin"

mkdir -p $OBJ $BIN

yasm -f elf32 -g dwarf2 -Ibootstrap -o $OBJ/BootstrapInterpreterLinux.o bootstrap/Linux/EntryPoint.asm
ld -m elf_i386 -o $BIN/BootstrapInterpreterLinux $OBJ/BootstrapInterpreterLinux.o