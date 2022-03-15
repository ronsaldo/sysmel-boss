#!/bin/sh
set -ex

mkdir -p out 
yasm -f bin -o out/bootsector.bin bootsector.asm 
yasm -f bin -o out/bootstrap.bin bootstrap.asm 
cat out/bootsector.bin out/bootstrap.bin > out/boot.bin