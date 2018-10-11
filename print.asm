_print:
      push ax
      cld
.prn:
      lodsb             ; Ucitavati znakove sve do nailaska prve nule
      or   al,al     
      jz  .end          ; Kraj stringa
      mov  ah,0eh       ; BIOS 10h: ah = 0eh (Teletype Mode), al = znak koji se ispisuje
      int  10h          ; BIOS prekid za rad sa ekranom
      jmp .prn     
.end:
      pop  ax
      ret   