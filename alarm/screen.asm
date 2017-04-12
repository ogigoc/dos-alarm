_print_date:
	pusha
	pushad

	call _clear
	;mov eax, [alarm_time]

	mov si, 473
	add si, cx

	mov cx, 0B800h
	mov es, cx

	mov ebx, 60

	mov edx, 0
	div ebx
	call _int_to_string
	call _print_tuple
	call _print_dots

	mov edx, 0
	div ebx
	call _int_to_string
	call _print_tuple
	call _print_dots

	mov edx, 0
	div ebx
	call _int_to_string
	call _print_tuple

.good:
	popa
	popad
	ret

_print_alarm:
	pusha
	call _clear

	mov ax, 0B800h
	mov es, ax
	
	mov bx, 450
	
	mov si, alarm_msg
	
.petlja:
	mov al, byte [si]
	cmp al, 0
	je .kraj
	
	mov [es:bx], al
	inc bx
	mov [es:bx], byte 02h
	inc bx

	inc si
	
	jmp .petlja
	
.kraj:
	popa
	ret

_clear:
	pusha
	mov ax, 0B800h
	mov es, ax
	
	mov bx, 138
	mov cx, 10
	call .petlja	
	mov bx, 298
	mov cx, 10
	call .petlja

	popa
	ret
	
.petlja:
	mov al, ' '
	
	mov [es:bx], al
	inc bx
	mov [es:bx], byte 02h
	inc bx
	
	loop .petlja
	ret

_print_tuple:
	mov [es:si], byte 2h
	dec si
	mov [es:si], cl
	dec si

	mov [es:si], byte 2h
	dec si
	mov [es:si], ch
	dec si

	ret

_print_dots:
	mov [es:si], byte 2h
	dec si
	mov [es:si], byte ':'
	dec si

%include "int2str.asm"

segment .data

