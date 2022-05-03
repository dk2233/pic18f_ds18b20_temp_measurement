; program obsluguje komunikacje z czujnikiem DS

;

;po wlaczeniu caly czas komunikuje sie z czujnikiem DS

;odczytuje z niego dane o ID oraz zawartosc pamieci wewnetrznej





;        TMR0  - lampka1
;        TMR1     -       
;        TMR2     -
;        TMR3     - u¿yty do obslugi LEDa oraz procesu pomiaru temperatury i wyswietlania danych uzyskanych z ds
;        TMR4     - "miganie" wyjscia testowego



        LIST   P=PIC18F46K80
        include  "p18f46k80.inc"

         CONFIG RETEN=OFF, XINST=OFF, FOSC=INTIO2, CANMX=PORTB, SOSCSEL=DIG, WDTEN = OFF, MSSPMSK = MSK5 ,MCLRE = ON
         ;,DEBUG=ON
         
         ;INTIO2 - wewnetrzny RC
         ;HS1  - dla 20 MHz
         ;__CONFIG _CONFIG2L, _BOR_ON_2L & _BORV_45_2L & _PWRT_ON_2L
         ;__CONFIG _CONFIG2H, _WDT_OFF_2H
         ;__CONFIG _CONFIG3H, _PBAD_DIG_3H & _MCLRE_ON_3H
         ;__CONFIG _CONFIG4L, _DEBUG_OFF_4L & _LVP_OFF_4L & _STVR_OFF_4L
	
	

 

czy_lampka_miga    equ   0
 
lampka_port	equ	PORTD
wyjscie_led       equ         0   
lampka_port	equ	PORTD
port_wyjscie2     equ      PORTD
latch_ds1820      equ      LATD
port_ds1820      equ      PORTD
latch_klawisz1    equ      LATE
port_klawisz1    equ      PORTE
port_przekaznika  equ         PORTB

czujnik_ds1820_1  equ      1
czujnik_ds1820_2  equ      2
czujnik_ds1820_3  equ      3


port_klawiszy     equ      4
klawisz1          equ      0
przekaznik11       equ         0
przekaznik12       equ         1
przekaznik21       equ         2
przekaznik22       equ         3
przekaznik31       equ         4
przekaznik32       equ         5





;;                                1, DL (1 - 8 bit, 0 -4 bit), N - ilosc linii (1 - 2 linie), F = font   
set_4bit		  equ      b'00100000' ;  4bit, 2 linie,font 5x8
;;;                                 DCB  D = display 0 -wylacz, Cursor = 1/0 Blinking=1/0 
display_set         equ      b'00001100' ;ustawia blinking,cursor,

;;;ustawiam entry                           I,S 
set_entry           equ             b'00000110' ;increment I=1, Shift = 1/0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;						ustawienie LCD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;definicja bitow uzywanych w 4 bitowym przesylaniu 0 - uzywany 1 - nieuzywany
;zwiazane z opcja kasowania
ktore_bity_uzywane_na_lcd     equ   0x0f
ktore_bity_lcd_tris           equ   0x0f
normalne_ustawienie_tris_lcd  equ   b'11110000'

;dolne bity PORTC
polozenie_danych_lcd          equ   0

ile_znakow        equ      16
port_lcd          equ         PORTC
latch_lcd               equ     LATC     
port_lcd_e        equ      PORTD
latch_lcd_e             equ    LATD
port_lcd_rw       equ      PORTD
latch_lcd_rw             equ    LATD
port_lcd_rs       equ      PORTA
latch_lcd_rs             equ    LATA

tris_lcd          equ      TRISC
Tris_ds1820       equ      TRISD


ile_zliczen_TMR3        equ     0x10
;equ   0x05

ile_zliczen_TMR3_do_pomiaru       equ 0x20
; equ   0x20

enable            equ      6
rs                equ      5
rw                equ      5



lampka_bit	equ	0
wyjscie2 	equ	4
czy_wysylac_on    equ      0
czy_wysylac_off    equ      1

;polozenie w banku 2
dane_odebraneH    equ      2
dane_odebraneL    equ      0 


znak_lf           equ      0x0a

linia_pierwsza	equ	0x80
linia_gorna	equ	0x80

linia_dolna	equ	0xc0
linia_druga	equ	0xc0


display_clear     	equ	b'00000001'

display_off 	      equ	b'00001000' 








;zalezne od czestotliwosci zegara
;zeby miec 60us dla

;dla4MHZ
;t2con_dla_60us           equ   b'00000100'
;t2con_dla_480us          equ   b'00001100' 

;dla 20MHz
;*5
t2con_dla_60us           equ   b'00100100'
;*10
t2con_dla_480us          equ   b'01001100'

;0x3f - dla 4 MHz
;
;movlw   
;movwf    T2CON
czas_oczekiwania_60us         equ   0x3c
czas_oczekiwania_480us        equ   0xf0





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;markers
;/*wyswietl */     
sprawdz_odebrane   equ      0
czy_wysylanie_OK     equ      1
pomiary_zrobione  equ      2  ;znacznik tego czy pomiary zostaly skonczone
inicjuj_pomiary   equ         3
czy_wysylac_pomiary_serial    equ       4
czy_wyswietlam_temp     equ   5  
rokaz_ds_bez_odbioru_danych    equ    6
czy_rozkaz            equ   7
             
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;markers_pomiary     

czy_wykonuje_pomiar_DS1                equ      0
czy_wywoluje_inicjacje_ds_call               equ      1              
czy_czytam_ID_DS1             equ   2     
czekam_na_odczyt_DS1          equ   3        
odczytaj_pomiar_DS1           equ   4
             
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;markers2
czy_wlaczyc_przekaznik        equ   0             
             
             
	cblock		0x60
	
         w_temp
         status_temp
         bsr_temp
         fsrl_temp
         fsrh_temp
         fsrl1_temp
         fsrh1_temp
         
       czas
	ile_zliczen_tmr3_do_sekundy
      ktore_zliczenie_tmr3_do_pomiar
      
	
         markers
         markers2
         markers_pomiary   
         
         odebrano_liter
         
         tmp
         tmp7
         
         czas_oczekiwania_przy_wysylanie_DS
         jak_duzo_bajtow_odbieram_z_ds
         polecenie_wysylane
         
         
         n
         n1
         liczba1
         
         
         zliczanie_pomiaru
         
         bajt_CRC
         
         temp_100
         temp_10
         temp_1
         temp_ulamek
         
         reszta_operacji
         
         wynik3
         wynik2
         wynik1
         wynik
         wynik01
         wynik001
         
         dec100
         dec10
         dec1
         
         dzielonah
         dzielona
         
         ulamekh
         ulamekl
         
         operandh
         operandl
         
         mnozonah
         mnozonal
         
         dane_lcd 
         tmp_lcd
         
         bajt_ds
         
         
         
	endc

         
         cblock    0x200
         dane_odebrane
         
         endc
         
         
         
         
         cblock   0x300
         dane_odebrane_z_ds
         endc 
         
         cblock   0x330
         id_czujnika_ds
         
         endc

         org      0x000
         
         goto     begin


	org      0x0008
         
         ;przerwania
         
przerwanie
         ;zachowuje rejestr W
         movwf    w_temp
         movff    STATUS,status_temp
         movff    BSR,bsr_temp
         
         movf     FSR0L,w
         movwf    fsrl_temp
         movf     FSR0H,w
         movwf    fsrh_temp
         
         movf     FSR1L,w
         movwf    fsrl1_temp
         movf     FSR1H,w
         movwf    fsrl1_temp
         
;po to by wszystkie ustawienia banki itd byly na 0    
        
         ;btfss    PIE1,RCIE
         ;goto     przerwanie_1
         
        
         ;btfsc    PIR1,RCIF
         ;goto     wykryto_odbior    

przerwanie_1
         ;bsf      STATUS,RP0
         
         btfss    INTCON,TMR0IE
         goto     przerwanie_2
         
         ;bcf      STATUS,RP0
        btfsc    INTCON,TMR0IF
        goto     wykryto_t0

przerwanie_2
        
przerwanie_3        
         btfss    PIE4,TMR4IE
         goto     przerwanie_4
         
         ;bcf      STATUS,RP0
         btfsc    PIR4,TMR4IF
         goto     wykryto_t4   
         
przerwanie_4

          btfss    PIE2,TMR3IE
         goto     przerwanie_5
                  
         btfsc    PIR2,TMR3IF
         goto     wykryto_timer3   
przerwanie_5
wyjscie_przerwanie

         movff    bsr_temp,BSR         
         movf     fsrl_temp,w
         movwf    FSR0L
         movf     fsrh_temp,w
         movwf    FSR0H
         
         movf     fsrl1_temp,w
         movwf    FSR1L
         movf     fsrh1_temp,w
         movwf    FSR1H         
         movf     w_temp,w
         movff    status_temp,STATUS

         retfie
         

         
         


wykryto_t0
;uzywam do wykrywania czy juz zrobic pomiar

         bcf      INTCON,TMR0IF
         ;bcf      INTCON,TMR0IE
         
         ;incf    do_sekundy,f

;tu wstawiam ile razy ma byc powtarzana petla co decyduje o ilosci czasu na wlaczenie i wylaczenie - procedura timera
         decf    zliczanie_pomiaru
	;movlw	10h
         
;dla 4 Mhz - po 10h	(16*250*256=1024000 cykle czyli 1,000 s) zeruj czas2

;dla 8 Mhz - 20h = 32 * 256*256 = 2097152 czyli oko-o 1s


	retfie
         
         
         
       
wykryto_t4
;uzywam do wykrywania czy juz zrobic pomiar

         bcf      PIR4,TMR4IF
   	
	btfsc	PORTD,wyjscie2
	goto	wylacz4

	bsf	PORTD,wyjscie2
       
         
         
         
	retfie
         
wylacz4
	bcf	LATD,wyjscie2
         
	retfie  
         
         
         
         goto     wyjscie_przerwanie


         
wykryto_timer3
         
         bcf      PIR2,TMR3IF

            
         decf     ktore_zliczenie_tmr3_do_pomiar,f
         btfss    STATUS,Z
         goto     wykryto_timer3_led
      
         
         movlw       ile_zliczen_TMR3_do_pomiaru
         movwf       ktore_zliczenie_tmr3_do_pomiar
         
         
         ;jezeli mam ustawiony bit ze wykonuje pomiary to
         btfss    markers_pomiary,czy_wykonuje_pomiar_DS1
         bsf      markers_pomiary,czy_czytam_ID_DS1
         
         btfsc    markers_pomiary,czy_wykonuje_pomiar_DS1
         bsf      markers_pomiary,odczytaj_pomiar_DS1
         
         
wykryto_timer3_led             
         decf     ile_zliczen_tmr3_do_sekundy,f
         btfss    STATUS,Z
         retfie
         
      movlw       ile_zliczen_TMR3
      movwf ile_zliczen_tmr3_do_sekundy
      
            ;clrf  T3CON
            
      btfsc	LATD,wyjscie_led
	goto	wylacz_led_timer3

	bsf	LATD,wyjscie_led
       
         
         
         
	retfie
         
wylacz_led_timer3
	bcf	LATD,wyjscie_led
      
	retfie
         

         
        
         INCLUDE  "libs/lcd4bit.asm"
        
         
         
         
begin
;prescaling ustawiony na 1:256
	
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
         
         ;wylaczam pwm
	clrf	CCP1CON
         clrf     CCP2CON
         clrf     CCP3CON
         clrf     CCP4CON
         clrf     CCP5CON
         ;ustawienie czestotliwosci
         
         ;movlw    b'01011100'
         movlw    b'01111110'
         movwf    OSCCON
                  
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
	movlw       ile_zliczen_TMR3
      movwf ile_zliczen_tmr3_do_sekundy
      
      
      movlw       ile_zliczen_TMR3_do_pomiaru
      movwf       ktore_zliczenie_tmr3_do_pomiar
      
      
         movlw    b'01111011'
         movwf    T4CON
	
         
         
         
         clrf     odebrano_liter
         
         
         
         
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
         
        
         
     
            call     lcd_init_KS066
           

;ustawienia ds18b20            
            movlw    8
         movwf    jak_duzo_bajtow_odbieram_z_ds
         
         
         movlw    czas_oczekiwania_60us
         movwf    czas_oczekiwania_przy_wysylanie_DS
                     
            

           
            call     check_busy4bit
            movlw    linia_gorna
            call  send
          
         
         movlw       HIGH tablica_znakow1
      movwf       TBLPTRH
      
      movlw       LOW tablica_znakow1
      movwf       TBLPTRL
      
      call     check_busy4bit
      
petla_napis1
      TBLRD       *+
      
      movf        TABLAT,w
      ;jezeli 0 to skocz do wyswietlania slowa z linii 2
      bz          koncze_wyswietlac
      
      call        write_lcd
      call        check_busy4bit 
         
      goto         petla_napis1
         ; call     check_busy4bit
            ; movlw    linia_dolna
koncze_wyswietlac    


        
          
      movlw       HIGH tablica_znakow2
      movwf       TBLPTRH
      
      movlw       LOW tablica_znakow2
      movwf       TBLPTRL
      call     check_busy4bit
            movlw    linia_dolna
            call  send
      call     check_busy4bit
      
petla_napis2
      TBLRD       *+
      
      movf        TABLAT,w
     bz          koncze_wyswietlac2
      
      call        write_lcd
      call        check_busy4bit 
      goto         petla_napis2
      
koncze_wyswietlac2            
     

       bsf      INTCON,GIE
      bsf      INTCON,PEIE
     

     
      call     czekaj_2_sekundy


         
         
tablica_znakow1
        ;db      "abcd 678 1 2 3 4",0
         ;db      "kocham Olusie ",0

         db       " pomiar temp ",0
         
         
tablica_znakow2
         db      "....",0


         
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
      
      
      ;czyszcze ekran
      
      movlw       display_clear
      call        send
            
      call        check_busy4bit 
      
      
      ;ustawienia TMR0
    movlw	b'10000011'	
	movwf	T0CON
      
      
      goto        main
      
      
      
 



 
      
      
      
      
      
      
      
      
      
	
;g-owny program

;glowna petla
main

         
         
      btfsc       markers_pomiary,czy_czytam_ID_DS1
      call      rokaz_transferu_numeru_id_1
      
      btfsc       markers_pomiary,odczytaj_pomiar_DS1
      call      odbierz_pomiary_temp
       
         
	goto	main



      
      
      
      
      
      
      
      
      
      
      

;

PIN_HI_1
        ;input
        BSF     Tris_ds1820, czujnik_ds1820_1           ; high impedance
        
        
        RETURN

PIN_LO_1
         ;output
        BCF     latch_ds1820,czujnik_ds1820_1
        ;bcf       latch_ds1820,czujnik_ds1820_1
        
        BCF     Tris_ds1820, czujnik_ds1820_1          ; low impedance zero
        
        
        RETURN
        
send_one_1
         clrf     TMR2
         bcf      PIR1,TMR2IF
         call     PIN_LO_1
         nop
         call     PIN_HI_1
        
petla_send_one_1
         btfss    PIR1,TMR2IF        
         goto     petla_send_one_1
         
         return

send_zero_1
        
         call     PIN_LO_1
         clrf     TMR2
         nop
         
         bcf      PIR1,TMR2IF
         
         bcf      latch_ds1820,czujnik_ds1820_1
petla_send_zero_1
         btfss    PIR1,TMR2IF        
         goto     petla_send_zero_1
         call     PIN_HI_1
         
         return

    



       






       
blad_inicjacji_ds
         
      call     check_busy4bit
         movlw    linia_dolna
         call  send
         ;jezeli nie jest 0
         movlw       HIGH napis_inicjacja_not_OK
         movwf       TBLPTRH
      
         movlw       LOW napis_inicjacja_not_OK
         movwf       TBLPTRL
      
wysylac_blad_inicjacji_ds_loop        
        call     check_busy4bit
            
      ;czytam aktualny adres i zwiekszam
         TBLRD       *+
      
         movf        TABLAT,w
         
      ;jezeli 0 to koncz i powrót
         btfsc    STATUS,Z
         return
     
         call     write_lcd
     
         goto        wysylac_blad_inicjacji_ds_loop
















    
         
      
inicjacja_ds1820_1

 
         ;bcf      RCSTA1,CREN
         
         
         
         bcf      Tris_ds1820,czujnik_ds1820_1
       
         
;ustawiam tmr2 na zliczanie 2 
         movlw    czas_oczekiwania_480us
         
         movwf    PR2
         
;ustawiam 480us         
         movlw    t2con_dla_480us
         movwf    T2CON
         
         bcf      PIR1,TMR2IF
;wlaczam przerwanie Tmr2
         ;bsf      STATUS,RP0
         ;bsf      PIE1,TMR2IE2
         ;bcf      STATUS,RP0
         call     PIN_HI_1
         call     PIN_LO_1
;daje znacznik ze dotyczy to inicjacji ds1820
         ;bsf      znaczniki_ds,inicjacja
;petla czekania na koniec inicjacji
petla_inicjacji1_1
         
         btfss    PIR1,TMR2IF
         goto     petla_inicjacji1_1
;teraz przelaczam sie na odbior danych z ds1820
         
         bsf      Tris_ds1820,czujnik_ds1820_1
         
         nop
         bcf      PIR1,TMR2IF
;sprawdzam czy w ciagu 480us pojawilo sie 0 na porcie czujnika
petla_inicjacji2_1

         btfss    port_ds1820,czujnik_ds1820_1
         goto     petla_inicjacji3_1
         
         btfss    PIR1,TMR2IF         
         goto     petla_inicjacji2_1
         
         goto     blad_inicjacji_ds
         
         
petla_inicjacji3_1
         btfsc    port_ds1820,czujnik_ds1820_1
         goto     inicjacja_ok_1
         btfss    PIR1,TMR2IF
         goto     petla_inicjacji3_1
         
inicjacja_ok_1
         ;btfsc    markers_pomiary,czy_wywoluje_inicjacje_ds_call
         ;return
         
         ;btfsc    markers,czy_rozkaz
         ;goto     wysylanie_danych_rozkaz_1

         ;btfsc    markers,czy_wysylanie_OK
         ;goto     napisz_ok
         
         
         return
         
         
      











         
         
;DS18B20
petla_wysylania_rozkazu_1
         TBLRD       *+
      
         movf        TABLAT,w
         btfsc    STATUS,Z
         return                     
         
         ;jezeli 0 to skocz do wyswietlania slowa z linii 2
         movwf     polecenie_wysylane
         
         movlw     czas_oczekiwania_60us      
         ;ustawiam TMR2 na odbieranie
         movwf    PR2
         
;ustawiam 60us         
         movlw    t2con_dla_60us
         movwf    T2CON
         bcf      PIR1,TMR2IF
         clrf      TMR2
         movlw     8
         movwf     n
         
petla_sending_pomiar_1

        btfss     polecenie_wysylane,0
        call      send_zero_1
        btfsc     polecenie_wysylane,0
        call      send_one_1
        bsf       latch_ds1820,czujnik_ds1820_1
        
        bcf       STATUS,C
        rrcf       polecenie_wysylane,f
        
        decfsz    n,f
        goto      petla_sending_pomiar_1
         
        goto       petla_wysylania_rozkazu_1


        
        
        

        
        
        


      
      
      
      
      
      
      
      
      
      
      
      
      




      
    
        
petla_odbioru_rozkazu_1
         movf     jak_duzo_bajtow_odbieram_z_ds,w
         movwf    liczba1
            
         movlw     czas_oczekiwania_60us
         movwf    PR2
         movlw    t2con_dla_60us
         movwf    T2CON
         clrf     TMR2
         bcf      PIR1,TMR2IF   
        
;procedura sprawdza czy ds1820 cos wysyla jezeli tak to sprawdza przez 60 us czy jest choc na chwile 0
;normalnie jezeli ds1820 nic nie wysyla to jest caly czas 1 bez rzadnych zmian
petla_odbioru_z_ds1820_1
        movlw     8
        movwf     n
        clrf      TMR2
        clrf      INDF1
        bcf       PIR1,TMR2IF
        
petla_stan_odebranego_bitu_1
         
         call     PIN_LO_1
        
         nop
         nop
         nop
         
         call     PIN_HI_1
         
         
         nop
         nop
         nop
         nop
         nop
         nop
         nop
         nop
         nop
         nop
         nop
         nop
         nop
         nop
         nop
         
         btfss    port_ds1820,czujnik_ds1820_1
         bcf      STATUS,C
         btfsc    port_ds1820,czujnik_ds1820_1
         bsf      STATUS,C
         rrcf     INDF1,f
         
czekam_na_kolejny_bit_DS_1
        btfss    PIR1,TMR2IF
        goto      czekam_na_kolejny_bit_DS_1
        
        bcf       PIR1,TMR2IF
        
        decfsz    n,f
        goto      petla_stan_odebranego_bitu_1
        incf      FSR1L,f
        
;czy juz przeszly wszystkie bajty z DS
        decfsz    liczba1,f
        goto      petla_odbioru_z_ds1820_1

         return      



wysylac_napis_CRC_notOK
      call     check_busy4bit
         movlw    linia_dolna
         call  send
         ;jezeli nie jest 0
         movlw       HIGH napis_CRC_no_OK
         movwf       TBLPTRH
      
         movlw       LOW napis_CRC_no_OK
         movwf       TBLPTRL
      
wysylac_napis_CRC_notOK_loop        
        call     check_busy4bit
            
      ;czytam aktualny adres i zwiekszam
         TBLRD       *+
      
         movf        TABLAT,w
         
      ;jezeli 0 to koncz i powrót
         btfsc    STATUS,Z
         return
     
         call     write_lcd
     
         goto        wysylac_napis_CRC_notOK_loop

         
         


rokaz_transferu_numeru_id_1
;najpierw wysy³am polecenie odczytu numeru id z jednego ds-a

      bcf         markers_pomiary,czy_czytam_ID_DS1

      call        check_busy4bit 
        movlw       display_clear
        call        send
            
      call        check_busy4bit 
      
      
         ;wylaczam mozliwosc odbioru danych z portu szeregowego
         bcf      RCSTA1,CREN

         movlw    8
         movwf    jak_duzo_bajtow_odbieram_z_ds
         
         movlw       HIGH rozkac_id
         movwf       TBLPTRH
      
         movlw       LOW rozkac_id
         movwf       TBLPTRL
         
         ;najpierw wyœlij rozkaz pomiaru
         ;wykorzystuje procedury które dzia³aj¹ po wybraniu wysy³ania danych przez polecenie
         ;
         ;        "*D1scc44"
         
         bcf    markers,czy_rozkaz
         bcf      markers,czy_wysylanie_OK
         
         bsf      markers_pomiary,czy_wywoluje_inicjacje_ds_call
         
         call     inicjacja_ds1820_1
         
         call     petla_wysylania_rozkazu_1
         
         bcf    markers,czy_rozkaz
         
         
                  
         LFSR     FSR1,dane_odebrane_z_ds
        
         
         call     petla_odbioru_rozkazu_1

         ;sprawdz CRC
         LFSR     FSR2, dane_odebrane_z_ds
         ;tylko 8 bajtów bo 8 to CRC
         movlw    8
         movwf     n
         
         call     check_CRC_DS
         
         movf     bajt_CRC,w
         ;jezeli 0 to jest ok
         bz      rokaz_send_id_1

         call    wysylac_napis_CRC_notOK     
         
         
rokaz_send_id_1
         LFSR     FSR1, dane_odebrane_z_ds
         movf     jak_duzo_bajtow_odbieram_z_ds,w
         movwf     n

         LFSR     FSR2, id_czujnika_ds
         
petla_kopiowania_bajt_ID
         movff    POSTINC1,POSTINC2
         
         decfsz   n,f
         goto     petla_kopiowania_bajt_ID
         
         

         LFSR     FSR1, dane_odebrane_z_ds
         movf     jak_duzo_bajtow_odbieram_z_ds,w
         movwf     n
         
         call     check_busy4bit
         movlw    linia_gorna
         call  send
         
         call     petla_wyswietlania_odebr_bajt
         
         
         bsf      markers_pomiary,czy_wykonuje_pomiar_DS1
         goto     wykonaj_pomiar_czujnikiem_DS
         return
         






        
wykonaj_pomiar_czujnikiem_DS
        

         movlw    9
         movwf    jak_duzo_bajtow_odbieram_z_ds
         
         movlw       HIGH rozkaz_pomiaru
         movwf       TBLPTRH
      
         movlw       LOW rozkaz_pomiaru
         movwf       TBLPTRL
         
         ;najpierw wyœlij rozkaz pomiaru
         ;wykorzystuje procedury które dzia³aj¹ po wybraniu wysy³ania danych przez polecenie
         ;
         ;        "*D1scc44"
         
         bcf    markers,czy_rozkaz
         
         
         call     inicjacja_ds1820_1
         
         call     petla_wysylania_rozkazu_1

         
         ;pozniej czekaj 1 s
         
         bsf      markers_pomiary,czekam_na_odczyt_DS1
         
         return

         
         
         
         

odbierz_pomiary_temp

       bcf  markers_pomiary,odczytaj_pomiar_DS1
       bcf  markers_pomiary,czekam_na_odczyt_DS1
       bcf  markers_pomiary,czy_wykonuje_pomiar_DS1

         movlw       HIGH rozkaz_odczytu
         movwf       TBLPTRH
      
         movlw       LOW rozkaz_odczytu
         movwf       TBLPTRL
         
         
         
         
         ;najpierw wyœlij rozkaz pomiaru
         ;wykorzystuje procedury które dzia³aj¹ po wybraniu wysy³ania danych przez polecenie
         ;
         ;        "*D1sccbe"
         bcf    markers,czy_rozkaz
         
         
         call     inicjacja_ds1820_1
         
         
         ;LFSR     FSR0, dane_odebrane_z_ds
         
         call     petla_wysylania_rozkazu_1
         
         LFSR     FSR1,dane_odebrane_z_ds
        
         
         call     petla_odbioru_rozkazu_1
         
         
         ;sprawdz CRC
         LFSR     FSR2, dane_odebrane_z_ds
         
         ;9 bajt to CRC
         movlw    9
         movwf     n
         
         call     check_CRC_DS
         
         movf     bajt_CRC,w
         ;jezeli 0 to jest ok
         bz      odbierz_pomiary_temp_show_data
         
         
         call    wysylac_napis_CRC_notOK
        
        
        
         return

      
odbierz_pomiary_temp_show_data
         
         ;LFSR     FSR2, dane_odebrane_z_ds
         ;call     zamien_dane_na_temp

         LFSR     FSR1, dane_odebrane_z_ds
         movf     jak_duzo_bajtow_odbieram_z_ds,w
         movwf     n
         
         call     check_busy4bit
         movlw    linia_dolna
         call  send
         
         call     petla_wyswietlania_odebr_bajt
         
         return













         
         
zamien_na_hex
;jezeli po odjeciu 0a jest niezanaczony bit C
;to znaczy ze dodaj 
         movwf    tmp7
         movlw    0x0a
         subwf    tmp7,w
         btfss    STATUS,C
         goto     cyfry_0_9
         movf     tmp7,w
         addlw    0x37
         return
cyfry_0_9         
         movf     tmp7,w
         addlw    0x30
         return
         

petla_wyswietlania_odebr_bajt        
        
          
         call        check_busy4bit 
          
         swapf    INDF1,w
         andlw    0x0f
         call     zamien_na_hex
         
         call     write_lcd
         
         
         call        check_busy4bit 
         movf     INDF1,w
         andlw    0x0f
         call     zamien_na_hex
        call     write_lcd
         
         
            
         incf     FSR1L,f
         decfsz   n,f
         goto     petla_wyswietlania_odebr_bajt
         
         
         
         
         
        return






        
        
        
        
        
        
        
        
        

check_CRC_DS 
         clrf  bajt_CRC
         ;movlw    
   
;tablica danych DS18b20 musi byc w FSR2
check_CRC_DS_loop
         movf POSTINC2,w   
         xorwf bajt_CRC,f       
         movlw 0     
         
         btfsc bajt_CRC,0 
         xorlw 0x5e       
         
         btfsc bajt_CRC,1 
         xorlw 0xbc 
         
         btfsc bajt_CRC,2 
         xorlw 0x61 
         
         btfsc bajt_CRC,3 
         xorlw 0xc2 
         
         btfsc bajt_CRC,4 
         xorlw 0x9d 
         
         btfsc bajt_CRC,5 
         xorlw 0x23 
         
         btfsc bajt_CRC,6 
         xorlw 0x46 
         
         btfsc bajt_CRC,7 
         xorlw 0x8c 
         
         movwf bajt_CRC   
         
         decfsz n,f 
         goto check_CRC_DS_loop         
                     

         ;movwf bajt_CRC         
 

         return         




       
         
         
         
         
         
         
         
rozkaz_pomiaru         
         db   0xcc,0x44,0x00

rozkaz_odczytu
         db   0xcc,0xbe,0x00
         
rozkac_id
         db       0x33,0x00
         
napis_CRC_no_OK
         db       "CRC not OK",0

napis_inicjacja_not_OK
         db       "Inicjacja not OK",0













         
	end		
