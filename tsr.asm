_find_tsr:
	pusha
	pushad

    mov     [func_id], byte 0       ;Initialize func_id to zero.
    mov     cx, 0FFh
.SearchLoop:
	mov     ah, cl
    push    cx
    mov     al, 0

    int     2Fh

    pop     cx
    cmp     al, 0
    je      .TryNext

    cli
    push 	cx
    mov 	cx, 5
    mov 	si, taken_msg

    repe cmpsb
    pop 	cx
    je      .installed

    loop    .SearchLoop      
    jmp     .notinstalled

	popa
	popad
	ret

.TryNext:
	mov     [func_id], cl      ; Save possible function ID if this
    loop    .SearchLoop      ; identifier is not in use.
    jmp     .notinstalled

.installed:
	popa
	popad
	mov ax, 1
	ret

.notinstalled:
	popa
	popad
	mov ax, 0
	ret



_start_tsr:
	pusha
	pushad

	call _find_tsr

	cmp ax, 1
	je .AlreadyThere
	cmp ax, 0
	je .NotInstalled

.AlreadyThere:
	mov 	si, already_there_msg
	call _print
	popa
	popad
	ret

.NotInstalled:   
	push 	cx
	mov 	cx, [func_id]
	cmp     cx, 0       ; If there are no available IDs, this
	pop 	cx
	jne     .GoodID          ; will still contain zero.

	mov 	si, too_many_TSRs_msg
	call _print
	popa
	popad
	ret

.GoodID:
	;install all handlers
	push  bx
	mov bl ,[func_id]
	mov [my_func_id], bl
	pop bx

	call _Novi2F
	call _Novi1C
	call _novi_09

    mov ah, 31h
    mov dx, 0FFh
    int 21h

    mov si, start_msg
    call _print

	popa
	popad
	ret



_stop_tsr:
	pusha
	pushad

	call _find_tsr

	cmp ax, 0
	je .not_installed
	cmp ax, 1
	je .remove

.not_installed:
	mov si, no_remove_msg
	call _print
	popa
	popad
	ret

.remove:
	mov bx, es
	mov ds, bx
	call _Stari2F
	call _Stari1C
	call _stari_09

	call _clear

	mov si, removed_msg
	call _print

	popa
	popad
	ret

_Novi2F:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:2fh*4]
	mov [cs:old_2f_off], bx 
	mov bx, [es:2fh*4+2]
	mov [cs:old_2f_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, MyInt2F
	mov [es:2Fh*4], dx
	mov ax, cs
	mov [es:2Fh*4+2], ax
	sti   
	ret

_Stari2F:
	cli
	xor ax, ax
	mov es, ax
	mov ax, [ds:old_2f_seg]
	mov [es:2Fh*4+2], ax
	mov dx, [ds:old_2f_off]
	mov [es:2Fh*4], dx
	sti
	ret

MyInt2F:
    cmp ah, [cs:my_func_id]   ;Is this call for us?
    je ItsUs
    jmp TryOtherFunc

ItsUs:          
	cmp     al, 0           ;Verify presence call?
    jne     TryOtherFunc
    mov     al, 0FFh        ;Return "present" value in AL.
	mov di, taken_msg
	mov dx, cs
	mov es, dx

    iret                    ;Return to caller.

TryOtherFunc:
	push word [cs:old_2f_seg]
	push word [cs:old_2f_off]
	retf

_Novi1C:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:1Ch*4]
	mov [cs:old_1c_off], bx 
	mov bx, [es:1Ch*4+2]
	mov [cs:old_1c_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, _update_time
	mov [es:1Ch*4], dx
	mov ax, cs
	mov [es:1Ch*4+2], ax
	push ds		; sacuvati sadrazaj DS jer ga INT 0x08 menja u DS = 0x0040
	pop gs		; (BIOS Data Area) i sa tako promenjenim DS poziva INT 0x1C
	sti         
	ret

_Stari1C:
	cli
	xor ax, ax
	mov es, ax
	mov ax, [ds:old_1c_seg]
	mov [es:1Ch*4+2], ax
	mov dx, [ds:old_1c_off]
	mov [es:1Ch*4], dx
	sti
	ret

_novi_09:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:09h*4]
	mov [cs:old_09_off], bx 
	mov bx, [es:09h*4+2]
	mov [cs:old_09_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, my_09h
	mov [es:09h*4], dx
	mov ax, cs
	mov [es:09h*4+2], ax
	sti         
	ret

; Vratiti stari vektor prekida 0x09
_stari_09:
	cli
	xor ax, ax
	mov es, ax
	mov ax, [ds:old_09_seg]
	mov [es:09h*4+2], ax
	mov dx, [ds:old_09_off]
	mov [es:09h*4], dx
	sti
	ret

my_09h:
	pusha

; Obrada tastaturnog prekida 
	in al, 060h
	mov bx, 0B800h
	mov es, bx
	mov bx, 460
	cmp al, 3Bh
	je .f1
	cmp al, 3Ch
	je .f2
	jmp izlaz
.f1:
	mov bl, [cs:is_alarm]
	cmp bl, 1
	jne izlaz

	mov eax, [cs:alarm_time]
	add eax, dword 10
	mov [cs:alarm_time], eax
	call _clear_alarm
	jmp izlaz
.f2:
	mov eax, [cs:alarm_time]
	sub eax, dword 5
	mov [cs:alarm_time], eax
	jmp izlaz
izlaz:
	popa
	
	push word [cs:old_09_seg]
	push word [cs:old_09_off]
	retf

segment .data

taken_msg: db "Ogi's TSR", 0
already_there_msg: db 'Alarm already set.', 0
too_many_TSRs_msg: db 'There are too many TSRs already installed.', 0
removed_msg: db 'Alarm removed.', 0
no_remove_msg: db 'No alarm to remove.', 0
start_msg: db 'Alarm started', 0

func_id: db 0

old_2f_seg: dw 0
old_2f_off: dw 0
old_1c_seg: dw 0
old_1c_off: dw 0
old_09_seg: dw 0
old_09_off: dw 0