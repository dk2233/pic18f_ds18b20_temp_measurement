


    include "times.inc"
    ;.file "times.asm"

WAIT_CODE       CODE
czekaj_2_sekundy
;ustawiam TMR0 - na maks zliczanie
;256*256*256*4/20e6
      movlw	b'10000111'
;1,67 s
      movwf	T0CON
      
      bcf   INTCON,TMR0IE
      bcf   INTCON,TMR0IF
czekaj_2_sekundy_petla
      btfss       INTCON,TMR0IF
      goto        czekaj_2_sekundy_petla
      return

    end
