org 100h
segment .code

main: 
	cld
	mov cx, 0080h
	mov di, 81h
	mov al, ' '
	repe scasb

	dec di
	mov si, di

	mov al, 0dh
	repne scasb
	mov byte [di-1], 0

	mov ax, si
	call _parse_stop
	cmp ax, 1
	je .stop

	mov ax, si
	call _parse_start
	cmp ax, 0
	je .invalid_command

	mov di, si
	mov al, ' '
	repne scasb
	mov ax, di
	call _parse_time
	mov eax, [alarm_time]
	cmp eax, 0
	je .invalid_time

	push es
	call .get_flag
	pop es

	jmp .start
	ret

.get_flag:
	pusha
	pushad

	mov ah, 34h
	int 21h
	mov [flag_seg], es
	mov [flag_off], bx

	popa
	popad
	ret

.stop:
	call _stop_tsr
	ret

.start:
	call _start_tsr
	ret

.invalid_command:
	mov si, invalid_command_msg
	call _print
	ret

.invalid_time:
	mov si, invalid_time_msg
	call _print
	ret

%include "psp.asm"
%include "print.asm"
%include "screen.asm"
%include "time.asm"
%include "tsr.asm"

segment .data

stop_msg: db 'Stop successful.', 0
invalid_command_msg: db 'Invalid command.', 0
invalid_time_msg: db 'Invalid time.', 0

alarm_time: dd 0
is_alarm: db 0
flag_seg: dw 0
flag_off: dw 0

my_func_id: db 0