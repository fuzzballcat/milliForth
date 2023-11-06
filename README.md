# milliForth
A FORTH in 422 bytes — the smallest real programming language ever, as of yet.

![milliFORTH_justhelloworld](https://github.com/fuzzballcat/milliForth/assets/57006511/ef3d48cf-1581-4574-8625-8d97b00acaca)
*The above gif, and the file `hello_world.FORTH`, are a modified version of the hello world program used to demonstrate sectorFORTH (see below)*

## bytes?

Yes, bytes.  This is a FORTH so small it fits in a 512-byte boot sector.  This isn't new — sectorFORTH[^1] successfully fit a FORTH within the boot sector.  However, milliFORTH appears to be *the smallest* programming language implementation ever, beating out sectorLISP[^2], a mind-blowing 436 byte implementation of LISP, by 14 bytes.

## Language

sectorFORTH[^1] was an extensive guide throughout the process of implementing milliFORTH, and milliFORTH's design actually converged on sectorFORTH unintentionally in a few areas.  That said, the language implemented is intentionally very similar, being the 'minimal FORTH'.

FORTH itself will not be explained here (prior understanding assumed).  Being so small, milliFORTH contains just a handful of words:

| Word | Signature | Function |
| ---- | --------- | -------- |
| `@` | `( addr -- value )` | Get a value at an address |
| `!` | `( value addr -- )` | Store a value at an address |
| `sp@` | `( -- sp )` | Get pointer to top of the data stack |
| `rp@` | `( -- rp )` | Get pointer to top of the return stack |
| `0=` | `( value -- flag )` | Check if a value equals zero (-1 = TRUE, 0 = FALSE) |
| `+` | `( a b -- a+b )` | Sum two numbers |
| `nand` | `( a b -- aNANDb )` | NAND two numbers |
| `exit` | `( r:addr -- )` | Pop from the return stack, resume execution at the popped address |
| `key` | `( -- key )` | Read a keystroke |
| `emit` | `( char -- )` | Print out an ASCII character |
| `state` | `( -- state )` | The state of the interpreter (0 = compile words, 1 = execute words) |
| `>in` | `( -- >in )` | The current offset into the terminal input buffer |
| `here` | `( -- here )` | The pointer to the next available space in the dictionary |
| `latest`  | `( -- latest )` | The pointer to the most recent dictionary space |

milliFORTH is effectively the same FORTH as implemented by sectorFORTH, with a few modifications:

- Words don't get hidden while you are defining them.  This doesn't really hinder your actual ability to write programs, but rather makes it possible to hang the interpreter if you do something wrong in this respect.
- There's no `tib` (terminal input buffer) word, because `tib` always starts at `0x0000`, so you can just use `>in` and don't need to add anything to it.
- In the small (production) version, the delete key doesn't work.  I think this is fair since sectorLISP doesn't handle backspace either; even if you add it back, milliFORTH is still smaller by a few bytes.
- Error handling is even sparser.  Successful input results in nothing (no familiar `ok.`).  Erroneous input prints an extra blank line between the previous input and the next prompt.

## Use

sector.bin is an assembled binary of sector.asm.  You can run it using `qemu-system-i386 -fda sector.bin` (as found in the makefile), or by using any emulator of your choice.

Alternatively, `make` will reassemble sector.asm, then run the above qemu emulator.

**Included in this repo is a pyautogui script** which can be run to automatically type in the `hello_world.FORTH` file into your qemu emulator.  A very useful tool.  It is self-explaining, but usage involves simply starting the QEMU emulator, running the python script, and putting your cursor into the QEMU emulator again.

`make sizecheck` is a utility which assembles sector.asm and then lists files including size.  This is useful for checking binary size.  Note that it will always return 512, as bootloaders must have a fixed size of 512 bytes; to view the true size, the following two lines must be commented at the end of sector.asm:
```
; times 510-($-$$) db 0
; db 0x55, 0xaa
```

## References
[^1]: The immensely inspirational sectorForth, to which much credit is due: https://github.com/cesarblum/sectorforth/.
[^2]: Mind-blowing sectorLISP: https://justine.lol/sectorlisp2/, https://github.com/jart/sectorlisp.
