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
STACK_BASE equ 0 ; stack subtracts before write so first goes to 0xFFFE
TIB equ 0x0000
TIBP1 equ TIB+1
STATE equ 0x1000 
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
	jmp pushax

defword "+",PLUS
    pop bx
    pop ax
    add ax,bx
	jmp pushax

defword "nand",NAND
    pop bx
    pop ax
    and ax,bx
    not ax
pushax:
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
	mov di,[bx+HERE-CIN]
	mov ax,[bx+LATEST-CIN]
	mov [bx+LATEST-CIN],di
	stosw
	mov al,cl
	stosb
	rep movsb
	mov ax,0x26ff
	stosw
	mov ax,DOCOL.addr
    stosw 
    mov [bx+HERE-CIN],di
    mov byte [bx+STATE-CIN],cl
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
    xchg cx,ax ; ah=0
    int 0x16
    jmp pushax

defword "emit",EMIT
    pop ax
    call putchar
    jmp NEXT

defword ";",SEMICOLON,FLAG_IMM
	mov byte [STATE],cl
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
	mov al,13
	call putchar
exec:
	xor sp, sp ; mov sp,STACK_BASE
	mov bp,RSTACK_BASE
	xor bx,bx ;mov bx,TIB
	mov byte [bx],bl
	inc bx
	mov byte [STATE],bl

find:
	call tok

	inc bx
	inc bx ;mov bx,LATEST
.1:	mov bx,[bx]
        test bh,bh
	jz error

	mov si,bx
	lodsw
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
	or al,[STATE]
	xchg si,ax
	mov si,_find
	jz compile
	jmp ax

storebyte:
	stosb
	db 0x3d ;mask xor di,di
getline:
	xor di,di ;mov di,TIB
.1:	call getchar
	cmp al,10
	jne storebyte
	mov ax, 0x0020
	stosw
	and word [CIN],0
tok:
	mov bx,CIN
	mov di,[bx]
	mov al,32

.1:	scasb
	je .1
	dec di
	cmp byte [di],0
	je getline
	mov cx,-1

	repne scasb
	dec di
	mov [bx],di
	not cx
	dec cx
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
	je testdi
%endif

	ret

%ifndef CHECKSIZE
times 510-($-$$) db 0
db 0x55, 0xaa
%endif

here: