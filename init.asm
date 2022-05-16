
    include "project_config.inc"

    extern  odebrano_liter
    extern  markers2
    extern  jak_duzo_bajtow_odbieram_z_ds
    extern  ktore_zliczenie_tmr3_do_pomiar
    extern ile_zliczen_TMR3_do_sekundy

    global init_main

START_SECTION  CODE
init_main
;prescaling set to 1:256
	
	movlw    b'11111101'
    movwf    PMD0
	
         
	;movlw	b'11111111'
	;movwf	 TRISC
         
    movlw	b'1111111'
	movwf	 TRISE

    movlw	b'11111111'
	movwf	 TRISB
      
    movlw	b'11011111'
    movwf	 TRISA

    movlw    b'11110000'
    movwf    TRISC

    movlw    b'10011111'
    movwf    TRISD

    IF  czy_lampka_miga == 1
    bcf	TRISD,lampka_bit
    bcf      TRISD,wyjscie2
    ENDIF
         
         ;bf	TRISD,wyjscie2
         
     clrf     LATD
     clrf     LATA
     clrf     LATB
     clrf     LATC
     clrf     LATE
     
     clrf     PORTA
     clrf     PORTB
     clrf     PORTC
     clrf     PORTD
     clrf     PORTE
     
     ;OFF pwm
     clrf	CCP1CON
     clrf     CCP2CON
     clrf     CCP3CON
     clrf     CCP4CON
     clrf     CCP5CON

     ;freq set 16MHz
     bcf      OSCCON,IDLEN  ;7
     bsf      OSCCON,IRCF0
     bsf      OSCCON,IRCF1
     bsf      OSCCON,IRCF2  ;4

     bsf      OSCCON,OSTS ;3
     bsf      OSCCON,HFIOFS ;2
     bsf      OSCCON,SCS1
     bcf      OSCCON,SCS0
      
     ;movlw    b'01111110'
     ;movwf    OSCCON
     
     ;ustawienie czestotliwosci 2         
     movlw b'01011011'
     movwf OSCCON2         
     
     movlw   b'00000000'         
     movwf   OSCTUNE
     
     
     bcf      PSPCON,PSPMODE
     
     clrf     PSPCON
     ;wylaczam prace synchroniczna
     clrf     SSPCON1
     clrf     SSPCON2
     bcf      SSPCON1,SSPEN
     clrf     SSPSTAT
         ;wylaczam prace obydwu portow szeregowych
         ;BSF      RCSTA1,SPEN
         ;movlw    b'10010000'
         ;movwf    RCSTA1
         
         clrf     RCSTA2
         clrf     RCSTA1
         ;BSF      RCSTA2,SPEN
         
         
         
         ;ustawienia comparatora - wylaczenie
         movlw    b'00000000'
         movwf    CVRCON
         ;komparator wylaczony
         ;movlw    b'00000111'
         bcf    CM1CON,CON
         bcf    CM2CON,CON
         
         bcf      CTMUCONH,CTMUEN
         
         ;wylaczam przerwania
         
         ;clrf     INTCON
         
         
         ;movlw   b'00000000'       ;wszystkie linie na wysoko
         ;ovwf    PORTB
         clrf     SPBRGH2
         clrf     SPBRGH1
         clrf     SPBRG2
         ;#103  = 0x67
         ;9600 baudow dla 4 MHz
         ;movlw    0x67
         ;9600 baudow dla 4.194304 MHz
         ;movlw    0x6c
         movlw    0x6a
         movwf    SPBRG1
         
         ;wylaczam modul ecan
         ;clrf     CANCON
         movlw    b'11100000'
         movwf    CANCON
         
         
         movlw    b'10000000'
         movwf    CANSTAT
         ;modul modulatora
         
         
         
         clrf     TXSTA1
         clrf     TXSTA2
         
         bsf      TXSTA1,BRGH
         bsf      TXSTA1,TXEN
         ;bsf      TXSTA2,TXEN
         movlw    b'00001000'
         movwf    BAUDCON1
         
         
         
         ;wylaczam analogowy
         clrf     ADCON0
         
         clrf     WREG
         movff    WREG, ANCON0
         movff    WREG, ANCON1
         
         ;        bsf      PIE1,TXIE
         ;bcf      STATUS,RP0
         ;movlw    b'10010000'
         ;movwf    RCSTA1
         
         
         
CCP_init         
         movlw    0
         movwf    CCP1CON
         movwf    CCP2CON
         ;BCF     
         
         ;zegary         
         ;movlw	b'10000001'
         movlw	b'10000001'
         ;mnoznik * 4 wtedy jedno zliczenie to 52 ms         
         movwf	T0CON
         
         clrf     T1CON
         clrf     T2CON
         clrf     T3CON
         
Timer3_init                      
           ;ustawienie zegara tmr3
           
           
           ;zegar odpowiada za przyciski
            movlw       b'01110001'
            movwf       T3CON
            movlb     ile_zliczen_TMR3
            movlw       ile_zliczen_TMR3
            movwf ile_zliczen_TMR3_do_sekundy
            
            
            movlw       ile_zliczen_TMR3_do_pomiaru
            movlb       ktore_zliczenie_tmr3_do_pomiar
            movwf       ktore_zliczenie_tmr3_do_pomiar
            
            
         movlw    b'01111011'
         movwf    T4CON
         
         movlb  odebrano_liter
         clrf     odebrano_liter
         movlb  markers2
         clrf     markers2
         
         ;wlaczam przerwania
         clrf     PIR1
         clrf     PIE1
         ;usart
         bcf      PIE1,RC1IE
         
         ;timer4
         bcf      PIE4,TMR4IE
         bsf      PIE2,TMR3IE
         ;timer4
         bcf      PIE4,TMR4IE
         
         bcf      INTCON,TMR0IE
         
         ;ustawienia ds18b20            
         movlb  jak_duzo_bajtow_odbieram_z_ds
         movlw    8
         movwf    jak_duzo_bajtow_odbieram_z_ds

         return

         end

