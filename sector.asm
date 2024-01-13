	bits 16
%ifdef COMPATIBLE_8088
	cpu 8086
%else
	cpu 386
%endif
	db 0eah
        dw main ;jmp 0x0050:main but reusing the segment as sentinel
	org 0x7700

RSTACK_BASE equ 0x7700
STACK_BASE equ 2
TIB equ 0x0000
TIBP1 equ TIB+1
STATE equ 0x1000  ; must be 256-bytes aligned
CIN equ 0x1002
LATEST equ 0x1004
HERE equ 0x1006
FLAG_IMM equ 1<<7
LEN_MASK equ (1<<5)-1 ; have some extra flags, why not

%define link 0x50
%macro defword 2-3 0
word_%2:
	dw link
%define link word_%2
%strlen %%len %1
	db %3+%%len
	db %1
%2:
%endmacro

defword "@",FETCH
	pop di
	push word [di]
	jmp NEXT

defword "!",STORE
	pop di
	pop word [di]
	jmp NEXT

defword "sp@",SPFETCH
	push sp
	jmp NEXT

defword "rp@",RPFETCH
	push dx
	jmp NEXT

defword "0#",ZEROEQ
	pop ax
    neg ax
	sbb ax,ax
	jmp pushax

defword "+",PLUS
    pop di
    pop ax
    add ax,di
	jmp pushax

defword "nand",NAND
    pop di
    pop ax
    and ax,di
    not ax
pushax:
	push ax
	jmp NEXT

defword "exit",EXIT
	xchg sp,dx
	pop si
	jmp DOCOL.swapsp

defword "s@",STATEVAR
    push bx
NEXT:
	lodsw
	jmp ax

defword ":",COLON
	call tok
	push si
	mov si,di
	mov ax,[bx+HERE-STATE]
	mov di,ax
	xchg [bx+LATEST-STATE],ax
	stosw
	mov al,cl
	stosb
	rep movsb
	pop si
	mov byte [bx],cl
	mov ax,0x26ff
	stosw
	mov ax,DOCOL.addr
	jmp sethere

DOCOL:
	xchg sp,dx
	push si
	xchg ax,si
	lodsw
	lodsw
.swapsp:
	xchg sp,dx
	jmp NEXT
.addr:
	dw DOCOL

defword "key",KEY
    xchg cx,ax ; ah=0
    int 0x16
    jmp pushax

defword "emit",EMIT
    pop ax
    call putchar
    jmp NEXT

defword ";",SEMICOLON,FLAG_IMM
	mov byte [bx],cl
	mov ax, EXIT
compile:
	mov di,[bx+HERE-STATE]
sethere:
	stosw
	mov [bx+HERE-STATE],di
	jmp NEXT

main:
	push cs
	push cs
	push cs
	pop ds
	pop es
	pop ss
	mov bx,STATE
	mov word [bx+LATEST-STATE],word_SEMICOLON
	mov word [bx+HERE-STATE],here
error:
	mov sp,STACK_BASE
	mov al,13
	call putchar
	mov dx,RSTACK_BASE
	xor si,si ;mov si,TIB
	push si ;mov [TIB],si
	inc si
	mov [bx],si

find:
	call tok

	lea bp,[bx+LATEST-STATE]
.1:	mov si,bp
	lodsw
        xchg bp,ax
        test ah,ah
	jz error
	lodsb
	push ax
	and al,LEN_MASK
	cmp al,cl
	pop ax
	jne .1

	push cx
	push di
	repe cmpsb
	pop di
	pop cx

	jne .1
	and al,FLAG_IMM
	or al,[bx]
	xchg si,ax
	mov si,_find
	jz compile
	jmp ax

storebyte:
	stosb
	db 0x3d ;mask xor di,di
getline:
	xor di,di ;mov di,TIB
	call getchar
	and word [bx+CIN-STATE],di
	cmp al,10
	jne storebyte
	mov ax, 0x0020
	stosw
tok:
	mov di,[bx+CIN-STATE]
	mov al,32

.1:	cmp byte [di],bl
	je getline
	scasb
	je .1
	xor cx,cx
.2:	inc cx
	scasb
	jne .2
	dec di
	mov [bx+CIN-STATE],di
	sub di,cx
	ret

_find: dw find

%ifdef BACKSPACE
testdi:	test di,di ; cmp di,TIB
	je getchar
	dec di
%endif

getchar:
	xor	ax,ax
	int 0x16
putchar:
	mov ah,0x0e
	db 0x3d ;mask mov al,10
.1:	mov al,10
	int 0x10
	cmp al,13
	je .1

; The below lines are a "QOL" improvement: the delete key.
; Since sectorLISP does not handle the delete key, I have commented them out for a fair comparison of size.
; Even when re-added, this FORTH is still smaller, however.

%ifdef BACKSPACE
	cmp al,8
	je testdi
%endif

	ret

%ifndef CHECKSIZE
times 510-($-$$) db 0
db 0x55, 0xaa
%endif

here: