put_tsr:
        call   _novi_09
        mov dx, 00FFh
        mov ah, 31h
        int 21h
        
        ;ret

; Sacuvati originalni vektor prekida 0x1C, tako da kasnije mozemo da ga vratimo
_novi_09:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:1Ch*4]
	mov [old_int_off], bx 
	mov bx, [es:1Ch*4+2]
	mov [old_int_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, _update_time
	mov [es:1Ch*4], dx
	mov ax, cs
	mov [es:1Ch*4+2], ax
	sti         
	ret

old_int_seg: dw 0
old_int_off: dw 0