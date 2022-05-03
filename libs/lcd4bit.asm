;funkcja zamieniajaca dane 8 bitowe na dwie polowki 4bitowe
;wysylane po kolei
;wersja 2011-03-09

;dla czestotliwosci 20 MHz

;dla procesora 

wait
      ;mamy 256*256*4*4/20e6 = 52 ms
        
        ;ustawiam tmr0 na mnoznik *4
        btfss   INTCON,T0IF      
        goto    wait
        bcf     INTCON,T0IF      
        return
        
         
;funkcja wysy?aj?ca
;LCD
;;;;;;;;;;;;;;;;;;;;;;;;;


;przed wywolaniem funkcji umiesc w Wreg dane do wyslania
send4bit
send
;np PORTA bity 0-3  sa uzywane przez 4 bitowy ekran lcd
;najpierw wysylane sa 4bity gorne

         movwf    dane_lcd
         
         ;bsf      port_lcd_e,enable
         
      IF (polozenie_danych_lcd == 0) 
;jezli linia LCD jest na dolnych bitach portu przypisanego do LCD, wtedy to co jest
;wysylane musi byc najpierw starsze wyslane, wiec to co jest w rejestrze dane_lcd musi byc obrocone tak by starsze bity znalazly sie na miejscy mlodszych (dolnych)
         swapf    dane_lcd,f
		 movlw	0xf0
		 andwf	 latch_lcd,f 
                 ; i wyczyszczone aktualne bity w nim
      ENDIF
            
      IF (polozenie_danych_lcd == 1)        
;jesli linia LCD jest podlaczona do gornych linii portu LCD nie na razie nie obracam
            
         movlw	0x0f
	 andwf	 latch_lcd,f 
      ENDIF
		  

         movlw    ktore_bity_uzywane_na_lcd
         andwf    dane_lcd,w
         addwf    latch_lcd,f
         
         bsf      latch_lcd_e,enable
         nop
         nop
         bcf      latch_lcd_e,enable

         

;jesli linia LCD jest podlaczona do gornych linii portu LCD, to wysylajac w drugiej kolejnosci mlodsze bity
;musze teraz obrcocic polowki bajtu, by dolne bity byly w miejscy starszych
         swapf    dane_lcd,f

  IF (polozenie_danych_lcd == 0) 
;jezli linia LCD jest na dolnych bitach portu przypisanego do LCD, wtedy to co jest
;wysylane musi byc najpierw starsze wyslane, wiec to co jest w rejestrze dane_lcd musi byc obrocone tak by starsze bity znalazly sie na miejscy mlodszych (dolnych)
        
		 movlw	0xf0
		 andwf	 latch_lcd,f 
      ENDIF
            
      IF (polozenie_danych_lcd == 1)        
;jesli linia LCD jest podlaczona do gornych linii portu LCD nie na razie nie obracam
            
         movlw	0x0f
	 andwf latch_lcd,f 
      ENDIF

         movlw    ktore_bity_uzywane_na_lcd
         andwf    dane_lcd,w
         addwf    latch_lcd,f
         
         bsf      latch_lcd_e,enable
         nop
         nop
         bcf      latch_lcd_e,enable
            
         
         return

         
         
         
         
         
         
         
;funkcja pisz?ca na ekranie
write_lcd

         
         bsf      latch_lcd_rs,rs
         
         call     send4bit
         
         bcf      latch_lcd_rs,rs
         return

;funkcja czyszcz?ca ekran

cmd_off

         
         bcf      port_lcd_rs,rs
         bcf      port_lcd_rw,rw
         
        return
         


;funkcja czysci cala linie
; przed jej wywolaniem w W umi#1esc adres linii
;po zakonczeniu z powrotem w niej umieszcza adres
;stara wersja - dziala na cala linie

clear_line_old
         movwf    n
         bcf      port_lcd_rs,rs
         
         movf     n,w
         movwf    tmp_lcd
         call     send
         movlw    ile_znakow
         movwf    tmp7
         addlw    0xff
         movwf    tmp
clear_line_old2
         call     check_busy4bit
         movlw    " "
         movwf    tmp_lcd
         call     write_lcd
         
         decfsz   tmp7,f
         goto     clear_line_old2
         
         call     cmd_off
         movf     n,w
         return
         
clear_line
;przed wywolaniem do n trzeba wrzucic ilosc kasowanych znakow
;a w W musi byc adres linii         
         movwf    dane_lcd
         call     send
         
clear_line_petla
         call     check_busy4bit
         movlw    " "
         movwf    dane_lcd
         call     write_lcd
         
         decfsz   n,f
         goto     clear_line_petla
         
         call     cmd_off
        
         return

         







         
check_busy4bit

      IF (polozenie_danych_lcd == 1)        
;czyszcze bity gorne, a dolne bez zmian
         movlw    0x0f         
         andwf    port_lcd,f
      ENDIF


      IF (polozenie_danych_lcd == 0)        
;czyszcze bity dolne
         movlw    0xf0         
         andwf    port_lcd,f
      ENDIF
       
        
         
         movf     tris_lcd,w
         iorlw    ktore_bity_lcd_tris
         movwf    tris_lcd    
         
        
         
         
                  
         bsf      latch_lcd_rw,rw
         bcf      latch_lcd_rs,rs

check
         
         bsf      latch_lcd_e,enable
         nop
         nop
         
         bcf      latch_lcd_e,enable
         
         
         
      IF (polozenie_danych_lcd == 0) 
;jezli linia LCD jest na dolnych bitach portu przypisanego do LCD, wtedy to co jest najpierw (starsze) trzeba przesunac na starsze bity
         swapf    port_lcd,w
         andlw    0xf0   
      ENDIF
            
      IF (polozenie_danych_lcd == 1)        
;jesli na gorze bitow port d
            
         movf    port_lcd,w
         andlw    0xf0   
      ENDIF
         
         
         movwf    tmp_lcd
         
         
            
         nop
         nop
         
         bsf      latch_lcd_e,enable
         
          nop
         nop
         
         bcf      port_lcd_e,enable  
         
      IF (polozenie_danych_lcd == 1) 
;jesli na gorze bitow port d
         swapf    port_lcd,w
      ENDIF
            
      IF (polozenie_danych_lcd == 0)        

            
         movf    port_lcd,w
      ENDIF         
         
           
         ;bo mlodsza polowke zapisuje
         andlw    0x0f
         
         addwf    tmp_lcd,f
         
         
            
         btfsc    tmp_lcd,7
         goto     check
        
         movlw   normalne_ustawienie_tris_lcd
         movwf    tris_lcd
         
         
         bcf      latch_lcd_rw,rw
         bcf      latch_lcd_rs,rs
         return



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                           
;pocz?tek dzia?ania ekranu

lcd_init_hitachi
         call     cmd_off
         clrf     port_lcd
;wylaczam przerwanie
        
         clrf     TMR0L
         clrf     TMR0H
         bcf    INTCON,T0IE
	bcf	INTCON,T0IF
;wylaczam przerwania tmr0         
         movlw    3
         movwf    tmp
        call     wait     ;fosc/4/256/256 (tak jest ustawiony tmr0) dla 4Mhz 64 ms dla 8 Mhz 32 ms
		;dwa bity nizsze musza byc zaznaczone przez okolo 64ms

            ;dla PIC18F46K80 mamy 256*256*4*1/20e6 - 13 ms
            
lcd_init_3_petla
         
         


     IF (polozenie_danych_lcd == 0) 
;jezli linia LCD jest na dolnych bitach portu przypisanego do LCD, wtedy to co jest
;wysylane musi byc najpierw starsze wyslane, wiec to co jest w rejestrze dane_lcd musi byc obrocone tak by starsze bity znalazly sie na miejscy mlodszych (dolnych)
         movlw    b'00000011'
	addwf	  port_lcd,f

      ENDIF
           
 
      IF (polozenie_danych_lcd == 1)        
;jesli linia LCD jest podlaczona do gornych linii portu LCD nie na razie nie obracam
         movlw    b'00110000'
         addwf	  port_lcd,f
            
         
      ENDIF

 	bsf      latch_lcd_e,enable
         nop
         nop
         bcf      latch_lcd_e,enable
        
        
         
         
         clrf     TMR0L
         clrf     TMR0H ;64 ms
 	bcf    INTCON,T0IE
	bcf	INTCON,T0IF
         call     wait
         
         clrf     TMR0L
         clrf     TMR0H ;64 ms
 	bcf    INTCON,T0IE
	bcf	INTCON,T0IF
         call     wait
         
         decfsz   tmp,f
         goto     lcd_init_3_petla

         IF (polozenie_danych_lcd == 0) 
;jezli linia LCD jest na dolnych bitach portu przypisanego do LCD, wtedy to co jest
;wysylane musi byc najpierw starsze wyslane, wiec to co jest w rejestrze dane_lcd musi byc obrocone tak by starsze bity znalazly sie na miejscy mlodszych (dolnych)
         
         movlw    b'00000010'
	 movwf  latch_lcd

      ENDIF
           
 
      IF (polozenie_danych_lcd == 1)        
;jesli linia LCD jest podlaczona do gornych linii portu LCD nie na razie nie obracam
         movlw    b'00100000'
         movwf	  port_lcd
            
         
      ENDIF
         
         
         
         
         bsf      latch_lcd_e,enable
         nop
         nop
         bcf      latch_lcd_e,enable
         
         clrf     TMR0L
         clrf     TMR0H;64 ms
         call     wait       
         

		call     check_busy4bit

         movlw   set_4bit
         
         call     send4bit
         
         call     check_busy4bit
         
         ;movlw    display_clear
         
         movlw    display_set
         
         
         call     send4bit
        
        call     check_busy4bit
        
         movlw    display_clear
         call     send4bit
        
        call     check_busy4bit
        
         movlw   set_entry
         
         call     send4bit
        
        call     check_busy4bit
        return
        
        
        
        
       


       
       
       
       
       
       
;dla ekranu na sterowniku KS066       

lcd_init_KS066
         call     cmd_off
         clrf     port_lcd
;wylaczam przerwanie
        
         clrf     TMR0L
         clrf     TMR0H
         bcf    INTCON,T0IE
	bcf	INTCON,T0IF
;wylaczam przerwania tmr0         
         
        call     wait  
    
         


     IF (polozenie_danych_lcd == 0) 
;jezli linia LCD jest na dolnych bitach portu przypisanego do LCD, wtedy to co jest
;wysylane musi byc najpierw starsze wyslane, wiec to co jest w rejestrze dane_lcd musi byc obrocone tak by starsze bity znalazly sie na miejscy mlodszych (dolnych)
         
         movlw    b'00000011'
	movwf	  latch_lcd

      ENDIF
           
 
      IF (polozenie_danych_lcd == 1)        
;jesli linia LCD jest podlaczona do gornych linii portu LCD nie na razie nie obracam
         
         movlw    b'00110000'
         movwf	  latch_lcd
            
         
      ENDIF
;1
 	bsf      latch_lcd_e,enable
         nop
         nop
         bcf      latch_lcd_e,enable
        
        
         
         clrf     TMR0L
         clrf     TMR0H  	
         call     wait
         
;2         
        bsf      latch_lcd_e,enable
         nop
         nop
         bcf      latch_lcd_e,enable
         
        clrf     TMR0L
         clrf     TMR0H  	
         call     wait


;3         
         bsf      latch_lcd_e,enable
         nop
         nop
         bcf      latch_lcd_e,enable
         
         
          IF (polozenie_danych_lcd == 0) 
;jezli linia LCD jest na dolnych bitach portu przypisanego do LCD, wtedy to co jest
;wysylane musi byc najpierw starsze wyslane, wiec to co jest w rejestrze dane_lcd musi byc obrocone tak by starsze bity znalazly sie na miejscy mlodszych (dolnych)
         
         movlw    b'00000010'
	movwf	  latch_lcd

      ENDIF
           
 
      IF (polozenie_danych_lcd == 1)        
;jesli linia LCD jest podlaczona do gornych linii portu LCD nie na razie nie obracam
         
         movlw    b'00100000'
         movwf	  latch_lcd
            
         
      ENDIF
      
      bsf      latch_lcd_e,enable
         nop
         nop
         bcf      latch_lcd_e,enable
         
         
   
         movlw    set_4bit        
         
         call     send4bit
         
          ;dla timer0
      ;52 ms
         ; clrf     TMR0L
         ; clrf     TMR0H
 	; call     wait
         
        call     check_busy4bit
         movlw    set_4bit
         call     send4bit
         
         
        call     check_busy4bit
         movlw    display_off
         call     send4bit
         
                
        call     check_busy4bit
         movlw    display_clear
         call     send4bit
         
         
         
         call     check_busy4bit
         movlw    display_set        
         call     send4bit
         
         
        call     check_busy4bit
         movlw   set_entry
         call     send4bit
        
        
        return  