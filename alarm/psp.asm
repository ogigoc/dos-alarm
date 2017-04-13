segment .code

_parse_start:
	pusha
	cld
	mov cx, 7
	mov si, ax
	mov di, start
	repe cmpsb
	jne .bad

.good:
	popa
	mov ax, 1
	ret
.bad:
	popa
	mov ax, 0
	ret



_parse_stop:
	pusha
	cld
	mov cx, 6
	mov si, ax
	mov di, stop
	repe cmpsb
	jne .bad

.good:
	popa
	mov ax, 1
	ret
.bad:
	popa
	mov ax, 0
	ret



_parse_time:
	pusha
	mov bx, ax
	cmp byte [bx+2], ':'
	jne .bad_format
	cmp byte [bx+5], ':'
	jne .bad_format
	cmp byte [bx+8], 0
	jne .bad_format

	mov byte [bx+2], 0
	mov si, bx
	mov ecx, 0
	call _string_to_int
	cmp cx, 23
	jg .bad_format
	mov eax, ecx
	mov dword [.tmp], 60
	mul dword [.tmp]

	add bx, 3
	mov byte [bx+2], 0
	mov si, bx
	call _string_to_int
	cmp cx, 59
	jg .bad_format
	add eax, ecx
	mov dword [.tmp], 60
	mul dword [.tmp]

	add bx, 3
	mov byte [bx+2], 0
	mov si, bx
	call _string_to_int
	cmp cx, 59
	jg .bad_format
	add eax, ecx
	
.good:
	mov [alarm_time], eax
	popa
	ret
.bad_format:
	popa
	ret

	.tmp dw 0
	.sol dw 0

%include "str2int.asm"

segment .data

start: db '-start ', 0
stop: db '-stop', 0
good: db 'Good', 0
bad: db 'Bad', 0