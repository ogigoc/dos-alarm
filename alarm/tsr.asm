_start_tsr:
	pusha
	pushad

    mov     [FuncID], byte 0       ;Initialize FuncID to zero.
    mov     cx, 0FFh
.SearchLoop:     

    push ax
	mov ax,[cs:old_2f_seg] 
	cmp ax, 0
	pop ax

	mov     ah, cl
    push    cx
    mov     al, 0
    int     2Fh
    pop     cx
    cmp     al, 0
    je      .TryNext

    cli
    push 	cx
    mov 	cx, 7
    mov 	si, TakenMsg

    repe cmpsb
    pop 	cx
    je      .AlreadyThere

    loop    .SearchLoop      
    jmp     .NotInstalled

	popa
	popad
	ret

.TryNext:
	mov     [FuncID], cl      ; Save possible function ID if this
    loop    .SearchLoop      ; identifier is not in use.
    jmp     .NotInstalled

.AlreadyThere:
	mov 	si, AlreadyThereMsg
	call _print
	popa
	popad
	ret

.NotInstalled:   
	push 	cx
	mov 	cx, [FuncID]
	cmp     cx, 0       ; If there are no available IDs, this
	pop 	cx
	jne     .GoodID          ; will still contain zero.

	mov 	si, TooManyTSRsMsg
	call _print
	popa
	popad
	ret

.GoodID:
	;install all handlers
	push  bx
	mov bl ,[FuncID]
	mov [MyFuncID], bl
	pop bx

	call _Novi2F
	call _Novi1C
	call _novi_09

	popa
	popad
	ret

_stop_tsr:
	ret



_Novi2F:
	pusha

	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:2fh*4]
	mov [old_2f_off], bx 
	mov bx, [es:2fh*4+2]
	mov [old_2f_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, MyInt2F
	mov [es:2Fh*4], dx
	mov ax, cs
	mov [es:2Fh*4+2], ax
	sti 

	popa       
	ret

_Stari2F:
	cli
	xor ax, ax
	mov es, ax
	mov ax, [old_2f_seg]
	mov [es:2Fh*4+2], ax
	mov dx, [old_2f_off]
	mov [es:2Fh*4], dx
	sti
	ret

MyInt2F:
	call _toto1
    cmp ah, [cs:MyFuncID]   ;Is this call for us?
    je ItsUs
    call _toto2
    jmp TryOtherFunc

ItsUs:          
	cmp     al, 0           ;Verify presence call?
    jne     TryOtherFunc
    mov     al, 0FFh        ;Return "present" value in AL.
	mov di, TakenMsg
	mov dx, cs
	mov es, dx
    iret                    ;Return to caller.

TryOtherFunc:
	push word [cs:old_2f_seg]
	push word [cs:old_2f_off]
	retf

_toto1:
	push si
	mov si, TOTO1
	call _print
	pop si
	ret

_toto2:
	push si
	mov si, TOTO2
	call _print
	pop si
	ret

_Novi1C:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:1Ch*4]
	mov [old_1c_off], bx 
	mov bx, [es:1Ch*4+2]
	mov [old_1c_seg], bx

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
	mov ax, [old_1c_seg]
	mov [es:1Ch*4+2], ax
	mov dx, [old_1c_off]
	mov [es:1Ch*4], dx
	sti
	ret

_novi_09:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:09h*4]
	mov [old_09_off], bx 
	mov bx, [es:09h*4+2]
	mov [old_09_seg], bx

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
	mov ax, [old_09_seg]
	mov [es:09h*4+2], ax
	mov dx, [old_09_off]
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

MyFuncID: db 0
FuncID: db 0
TakenMsg: db "Ogi's TSR", 0
TOTO1: db "TOTO1 ", 0
TOTO2: db "TOTO2 ", 0
AlreadyThereMsg: db 'Alarm already set.', 0
TooManyTSRsMsg: db 'There are too many TSRs already installed.', 0

old_2f_seg: dw 0
old_2f_off: dw 0
old_1c_seg: dw 0
old_1c_off: dw 0
old_09_seg: dw 0
old_09_off: dw 0