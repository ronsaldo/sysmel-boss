#!/bin/bash

set -ex

OBJ="build/bootstrap/obj"
BIN="build/bootstrap/bin"

mkdir -p $OBJ $BIN

nasm -f elf32 -g -Ibootstrap -o $OBJ/BootstrapInterpreterLinux.o bootstrap/BootstrapInterpreterLinux.asm
nasm -f bin -Ibootstrap -o $OBJ/BootstrapInterpreter.bin bootstrap/BootstrapInterpreter.asm
ld -m elf_i386 -o $BIN/BootstrapInterpreterLinux $OBJ/BootstrapInterpreterLinux.o