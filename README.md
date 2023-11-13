# milliForth
A FORTH in 380 bytes — the smallest real programming language ever, as of yet.

![milliFORTH_justhelloworld](https://github.com/fuzzballcat/milliForth/assets/57006511/ef3d48cf-1581-4574-8625-8d97b00acaca)
*The code in the above gif, that of \[an older version of\] `hello_world.FORTH`, is a modified version of the hello world program used by sectorFORTH (see below)*

## bytes?

Yes, bytes.  This is a FORTH so small it fits in a 512-byte boot sector.  This isn't new — sectorFORTH[^1] successfully fit a FORTH within the boot sector.  However, milliFORTH appears to be *the smallest* "real" programming language implementation ever, beating out sectorLISP[^2], a mind-blowing 436 byte implementation of LISP, by 56 bytes.  ("real" excludes esolangs and other non-production languages - for example, the sectorLISP author's implementation of BF is just 99 bytes, but it clearly isn't used to any serious capacity.)

## Is it turing-complete?

Yes!  This project now includes `bf.FORTH`, a compliant brainfuck interpreter, to illlustrate that this is truly a real language.

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
| `s@` | `( -- s@ )` | The "state struct" pointer.  The cells of this struct are, in order: <ul><li>`state`: The state of the interpreter (0 = compile words, 1 = execute words)</li><li>`>in`: Pointer to the current offset into the terminal input buffer</li><li>`latest`: The pointer to the most recent dictionary space</li><li>`here`: The pointer to the next available space in the dictionary</li></ul> |

On a fundamental level, milliFORTH the same FORTH as implemented by sectorFORTH, with a few modifications:

- All of the interpreter state words are bundled into a single struct (`s@`).
- Words don't get hidden while you are defining them.  This doesn't really hinder your actual ability to write programs, but rather makes it possible to hang the interpreter if you do something wrong in this respect.
- There's no `tib` (terminal input buffer) word, because `tib` always starts at `0x0000`, so you can just use `>in` and don't need to add anything to it.
- In the small (production) version, the delete key doesn't work.  I think this is fair since sectorLISP doesn't handle backspace either; even if you add it back, milliFORTH is still smaller by a few bytes.
- Error handling is even sparser.  Successful input results in nothing (no familiar `ok.`).  Erroneous input prints an extra blank line between the previous input and the next prompt.

## Use

sector.bin is an assembled binary of sector.asm.  You can run it using `make emulate`, which invokes (and thus requires) `qemu-system-i386`, or by using any emulator of your choice.

Alternatively, `make` will reassemble sector.asm, then run the above qemu emulator.

Additionally, you can run an example file easily by running `make runfile file=SOURCE_CODE`.  Try out `make runfile file=hello_world.FORTH` or `make runfile file=bf.FORTH`!  *NOTE: Files run this way currently do not accept user input from stdin, as the file itself is being piped to qemu.  Fix coming shortly.*

`make sizecheck` is a utility which assembles sector.asm into sector.bin and then lists out the size of sector.bin for you.  Note that this automatically removes the padding from the .bin (as a working bootloader must be exactly 512 bytes).

## References
[^1]: The immensely inspirational sectorForth, to which much credit is due: https://github.com/cesarblum/sectorforth/.
[^2]: Mind-blowing sectorLISP: https://justine.lol/sectorlisp2/, https://github.com/jart/sectorlisp.
