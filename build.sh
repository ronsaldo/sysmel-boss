#!/bin/sh
set -ex

mkdir -p out 
yasm -f bin -o out/bootstrap.bin bootstrap/bootstrap.asm 