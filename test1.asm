	
	org 100h
	mov ax, 0B800h
	mov es, ax
	mov bx, 400

unos:
	mov ah, 0
	int 16h

	cmp al, 'w'
	je idi_gore

	cmp al, 's'
	je idi_dole

	cmp al, 'a'
	je idi_levo

	cmp al, 'd'
	je idi_desno

	cmp al, 'q'
	je _end

	jmp unos

idi_gore:
	call _clear
	sub bx, 160
	jmp draw

idi_dole:
	call _clear
	add bx, 160
	jmp draw

idi_levo:
	call _clear
	sub bx, 2
	jmp draw

idi_desno:
	call _clear
	add bx, 2


draw:
	mov [es:bx], byte 1
	inc bx
	mov [es:bx], byte 02h	
	dec bx

	jmp unos
	
_clear:
	mov [es:bx], byte 0
	ret

_end:
	ret
