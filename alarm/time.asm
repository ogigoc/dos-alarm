_update_time:
	pusha
	pushad

	mov cx, 0
	call _print_date

	mov ebx, eax
	call _get_time
	cmp eax, 0
	je .done

	sub ebx, eax
	mov eax, ebx
	mov cx, 160
	call _print_date
.done:
	popa
	popad
	ret

_get_time:
	pushad
	mov ah, 2Ch

	; cmp al, 0
	; jne .error
	
	;check if should
	int 21h

	mov bl, dh

	mov eax, 0
	mov [.tmp], ch
	mov eax, dword [.tmp]
	mov [.tmp], dword 60
	mul dword [.tmp]
	mov [.tmp], cl
	add eax, dword [.tmp]
	mov [.tmp], dword 60
	mul dword [.tmp]
	mov [.tmp], bl
	add eax, dword [.tmp]

	mov [.tmp], eax
	popad
	mov eax, [.tmp]
	ret

	.tmp: dd 0