	bits 16
%ifdef COMPATIBLE_8088
	cpu 8086
%else
	cpu 386
%endif
	jmp 0x0050:main
	org 0x7700

RSTACK_BASE equ 0x76fe
STACK_BASE equ 0xfffe
TIB equ 0x0000
TIBP1 equ TIB+1
STATE equ 0x1000 
CIN equ 0x1002
LATEST equ 0x1004
HERE equ 0x1006
FLAG_IMM equ 1<<7
LEN_MASK equ (1<<5)-1 ; have some extra flags, why not

%define link 0
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
	pop bx
	push word [bx]
	jmp NEXT

defword "!",STORE
	pop bx
	pop word [bx]
	jmp NEXT

defword "sp@",SPFETCH
	push sp
	jmp NEXT

defword "rp@",RPFETCH
	push bp
	jmp NEXT

defword "0#",ZEROEQ
	pop ax
    neg ax
	sbb ax,ax
    push ax
    jmp NEXT

defword "+",PLUS
    pop bx
    pop ax
    add ax,bx
    push ax
    jmp NEXT

defword "nand",NAND
    pop bx
    pop ax
    and ax,bx
    not ax
    push ax
    jmp NEXT

defword "exit",EXIT
	xchg sp,bp
	pop si
	xchg sp,bp
	jmp NEXT

defword "s@",STATEVAR
%ifdef COMPATIBLE_8088
    mov ax,STATE
    push ax
%else
	push word STATE
%endif
NEXT:
	lodsw
	jmp ax

defword ":",COLON
	call tok
	push si
	mov si,di
	mov di,[HERE]
	mov ax,[LATEST]
	mov [LATEST],di
	stosw
	mov al,cl
	stosb
	rep movsb
	mov ax,0x26ff
	stosw
	mov ax,DOCOL.addr
    stosw 
    mov [HERE],di
    mov byte [STATE],0
    pop si
    jmp NEXT

DOCOL:
	xchg sp,bp
	push si
	xchg sp,bp
	xchg ax,si
	lodsw
	lodsw
	jmp NEXT
.addr:
	dw DOCOL

defword "key",KEY
    mov ah,0
    int 0x16
    push ax
    jmp NEXT

defword "emit",EMIT
    pop ax
    call putchar
    jmp NEXT

defword ";",SEMICOLON,FLAG_IMM
	mov byte [STATE],1
	mov ax, EXIT
compile:
	mov di,[HERE]
	stosw
	mov [HERE],di
	jmp NEXT

main:
	push cs
	push cs
	push cs
	pop ds
	pop es
	pop ss
	mov word [LATEST],word_SEMICOLON
	mov word [HERE],here
error:
	mov ax,13
	call putchar
exec:
	mov sp,STACK_BASE
	mov bp,RSTACK_BASE
	mov byte [STATE],1
	mov byte [TIB],0

find:
	call tok

	mov bx,[LATEST]
.1:	test bx,bx
	jz error

	mov si,bx
	lodsw
	lodsb
	mov dl,al
	and al,LEN_MASK
	cmp al,cl
	jne .2

	push cx
	push di
	repe cmpsb
	pop di
	pop cx

	je .3
.2:	mov bx,[bx]
	jmp .1
.3: mov ax,si
	mov si,_find
	and dl,FLAG_IMM
	or dl,[STATE]
	jz compile
	jmp ax

getline:
	mov di,TIB
.1:	call getchar
	cmp al,10
	je .2
	stosb
	jmp .1
.2: mov ax, 0x0020
	stosw
	mov word [CIN],0
tok:
	mov di,[CIN]
	mov al,32
	mov cx,-1

	repe scasb
	dec di
	cmp byte [di],0
	je getline
	mov cx,-1

	repne scasb
	dec di
	mov [CIN],di
	not cx
	dec cx
	sub di,cx
	ret

_find: dw find

getchar:
	xor	ax,ax
	int 0x16
putchar:
	mov ah,0x0e
	cmp al,13
	jne .1
	int 0x10
	mov al,10
.1:	int 0x10

; The below lines are a "QOL" improvement: the delete key.
; Since sectorLISP does not handle the delete key, I have commented them out for a fair comparison of size.
; Even when re-added, this FORTH is still smaller, however.

%ifdef BACKSPACE
	cmp al,8
	jne .2
	cmp di,TIB
	je .3
	dec di
.3:	jmp getchar
.2:
%endif

	ret

%ifndef CHECKSIZE
times 510-($-$$) db 0
db 0x55, 0xaa
%endif

here: