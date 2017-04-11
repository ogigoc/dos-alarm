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
	cmp eax, 0
	je .invalid_time

	mov cx, 0
	call _print_date
	cmp cx, 0
	je .invalid_date

	call _update_time

	jmp .start
	ret

.stop:
	; TODO STOP
	mov si, stop_msg
	call _print
	ret

.start:
	; TODO START
	mov si, start_msg
	call _print
	ret

.invalid_command:
	mov si, invalid_command_msg
	call _print
	ret

.invalid_time:
	mov si, invalid_time_msg
	call _print
	ret

.invalid_date:
	mov si, invalid_date_msg
	call _print
	ret

%include "psp.asm"
%include "print.asm"
%include "screen.asm"
%include "time.asm"

segment .data

stop_msg: db 'Stop successful.', 0
start_msg: db 'Start successful.', 0
invalid_command_msg: db 'Invalid command.', 0
invalid_time_msg: db 'Invalid time.', 0
invalid_date_msg: db 'Invalid date.', 0