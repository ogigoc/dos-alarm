_int_to_string:
	pushad
	mov ax, dx
	mov dx, 0
	mov bx, 10
	div bx

	add ax, 48
	add dx, 48

	mov [.sol], dx
	mov [.sol+1], ax
	mov [.sol+2], byte 0

	popad
	mov cx, word [.sol]
	ret

	.sol: dw 0