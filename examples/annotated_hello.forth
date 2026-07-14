\ milliForth annotated example — Hello World with stack comments
\ Demonstrates: string literal, emit loop, stack discipline
\ Author: EDAULC (SNAPKITTYWEST) 2026-07-14

\ Print a single character
\ Stack effect: ( char -- )
: emit-char  ( char -- )
  1 1 syscall3  \ write(1, char_addr, 1)
;

\ Print newline
\ Stack effect: ( -- )
: newline  ( -- )
  10 emit-char
;

\ Hello World in milliForth
\ Stack: starts and ends empty
: main
  72 emit-char   \ H
  101 emit-char  \ e
  108 emit-char  \ l
  108 emit-char  \ l
  111 emit-char  \ o
  44 emit-char   \ ,
  32 emit-char   \  (space)
  87 emit-char   \ W
  111 emit-char  \ o
  114 emit-char  \ r
  108 emit-char  \ l
  100 emit-char  \ d
  33 emit-char   \ !
  newline
;

main
