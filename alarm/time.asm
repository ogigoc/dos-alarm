_update_time:
	pusha
	pushad

	mov ebx, [cs:alarm_time]
	call _get_time
	cmp eax, 0
	je .done

	mov ebx, [cs:alarm_time]
	cmp eax, ebx
	jge .over_time

	sub ebx, eax
	mov eax, ebx
	mov cx, 160
	call _print_date

	mov cx, 0
	mov eax, [cs:alarm_time]
	call _print_date
	mov [cs:is_alarm], byte 0

	jmp .done

.over_time:
	sub eax, ebx
	cmp eax, 5
	jl .alarm_time

	mov [cs:is_alarm], byte 2
	jmp .done
	;call _end_alarm

.alarm_time:
	mov [cs:is_alarm], byte 1
	call _print_alarm
	jmp .done

.done:
	popa
	popad
	iret

_get_time:
	mov ah, 2Ch

	;check if should
	int 21h

	mov [.tmp2], dh
	;mov bh, dh

	mov eax, 0
	mov [.tmp], dword eax

	
	mov eax, 0
	mov [.tmp], ch
	mov eax, dword [.tmp]
	mov [.tmp], dword 60
	mul dword [.tmp]
	mov [.tmp], cl
	add eax, dword [.tmp]
	mov [.tmp], dword 60
	mul dword [.tmp]
	;mov [.tmp], bh
	add eax, dword [.tmp2]

	mov [.tmp], eax
	mov eax, [.tmp]
	ret

	.tmp: dd 0
	.tmp2: dd 0