	org 100h

	mov ax, 0B800h
	mov es, ax
	mov si, 400

	mov ax, 5123
	mov bl, 10
	mov di, 0

lloop:
	mov bl, 10
	div bl

	inc di

	mov bh, ah
	mov bl, 0
	push bx



	mov ah, 0

	cmp al, 0
	jne lloop

reverse:
	pop bx
	mov ah, bh
	mov ch, ah
	mov dx, 48
	call _print
	dec di

	cmp di, 0
	jne reverse

	ret
	
_print:
	dec ch
	inc dx

	cmp ch, 0
	jne _print

	mov [es:si], dx
	inc si
	mov [es:si], byte 2h
	inc si

	ret