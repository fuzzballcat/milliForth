run:
	yasm -f bin -o sector.bin sector.asm
	qemu-system-i386 -fda sector.bin

emulate:
	qemu-system-i386 -fda sector.bin

with:
	yasm -f bin -o sector.bin sector.asm $(options)
	qemu-system-i386 -fda sector.bin

prep:
	yasm --preproc-only sector.S

sizecheck:
	yasm -f bin -o sector.bin sector.asm -D CHECKSIZE
	ls -la | grep sector.bin | awk '{print $$9":",$$5,"bytes"}'
	@yasm -f bin -o sector.bin sector.asm # rewrite with working .bin