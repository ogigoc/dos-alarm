_print_date:
	pushad

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
	popad
	mov cx, 1
	ret

.bad:
	popad
	mov cx, 0
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