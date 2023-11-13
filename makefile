run:
	yasm -f bin -o sector.bin sector.asm
	qemu-system-i386 -fda sector.bin

runfile:
	rm -f /tmp/sector.in /tmp/sector.out
	mkfifo /tmp/sector.in /tmp/sector.out
	(sleep 1; python3 py_autotype.py $(file)) | qemu-system-i386 -nographic -fda sector.bin

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