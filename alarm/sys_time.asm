_print_sys_time:
	ret
	pusha

; 	;call _get_time
	
; 	cmp eax, 0
; 	je .done

; 	mov cx, 0
; 	;call _print_date
; .done:
; 	popa
; 	ret

; _get_time:
; 	mov ah, 2Dh

; 	cmp al, 0
; 	jne .error
	
; 	;check if should
; 	int 21h

; 	mov eax, 0
; 	mov [.tmp], ch
; 	mov eax, dword [.tmp]
; 	mov [.tmp], dword 60
; 	mul dword [.tmp]
; 	mov [.tmp], cl
; 	add eax, dword [.tmp]
; 	mov [.tmp], dword 60
; 	mul dword [.tmp]
; 	mov [.tmp], dh
; 	add eax, dword [.tmp]
; 	ret

; 	.tmp: dd 0

; .error:
; 	mov eax, 0
; 	ret