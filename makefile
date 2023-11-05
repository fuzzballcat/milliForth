run:
	yasm -f bin -o sector.bin sector.asm
	qemu-system-i386 -fda sector.bin

prep:
	yasm --preproc-only sector.S

sizecheck:
	yasm -f bin -o sector.bin sector.asm
	ls -la