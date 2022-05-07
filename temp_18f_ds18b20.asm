; program obsluguje komunikacje z czujnikiem DS

;

;po wlaczeniu caly czas komunikuje sie z czujnikiem DS

;odczytuje z niego dane o ID oraz zawartosc pamieci wewnetrznej


;        TMR0  - lampka1
;        TMR1     -       
;        TMR2     -
;        TMR3     - u¿yty do obslugi LEDa oraz procesu pomiaru temperatury i wyswietlania danych uzyskanych z ds
;        TMR4     - "miganie" wyjscia testowego


    include "project_config.inc"
    include "data.inc"
    include "ds18b20_driver.inc"
    ;INCLUDE  "libs/lcd.inc"
    include "libs/lcd_if.inc"
    include "ds18b20_driver_if.inc"

 CONFIG RETEN=OFF, XINST=OFF, FOSC=INTIO2, CANMX=PORTB, SOSCSEL=DIG, WDTEN = OFF, MSSPMSK = MSK5 ,MCLRE = ON
 ;,DEBUG=ON
 
 ;INTIO2 - wewnetrzny RC
 ;HS1  - dla 20 MHz
 ;__CONFIG _CONFIG2L, _BOR_ON_2L & _BORV_45_2L & _PWRT_ON_2L
 ;__CONFIG _CONFIG2H, _WDT_OFF_2H
 ;__CONFIG _CONFIG3H, _PBAD_DIG_3H & _MCLRE_ON_3H
 ;__CONFIG _CONFIG4L, _DEBUG_OFF_4L & _LVP_OFF_4L & _STVR_OFF_4L
	
	

    extern czekaj_2_sekundy
    extern init_main

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
      
	
         markers
         markers_pomiary   
         
         odebrano_liter
         
         tmp
         tmp7
         
         czas_oczekiwania_przy_wysylanie_DS
         
         
         n
         n1
         
         
         zliczanie_pomiaru
         
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
         decf    zliczanie_pomiaru,f
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
         decf     ile_zliczen_TMR3_do_sekundy,f
         btfss    STATUS,Z
         retfie
         
      movlw       ile_zliczen_TMR3
      movwf ile_zliczen_TMR3_do_sekundy
      
            ;clrf  T3CON
            
      ;btfsc	LATD,wyjscie_led
	;goto	wylacz_led_timer3

	;bsf	LATD,wyjscie_led
       
         
         
         
	retfie
         
wylacz_led_timer3
	bcf	LATD,wyjscie_led
      
	retfie

        
         

begin
    call init_main

         
board_start         
        call     lcd_init_KS066
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
         
      ;czyszcze ekran
      
      movlw       display_clear
      call        send
            
      call        check_busy4bit 
      
      
      ;ustawienia TMR0
    movlw	b'10000011'	
	movwf	T0CON
    goto        main

tablica_znakow1
         db       " pomiar temp ",0
         
         
tablica_znakow2
         db      "....",0


         
      
      
      
      
      
	
;g-owny program

;glowna petla
main

         
         
      btfsc       markers_pomiary,czy_czytam_ID_DS1
      call      rokaz_transferu_numeru_id_1
      
      btfsc       markers_pomiary,odczytaj_pomiar_DS1
      call      odbierz_pomiary_temp
       
         
	goto	main



      
      
      
      
      
      
blad_inicjacji_ds
         
      btfss    status_ds18b20,initialization_not_ok
      return
      bcf   status_ds18b20,initialization_not_ok

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

         movlw    how_many_bytes_receives_ds18
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

         call   blad_inicjacji_ds
         
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
         movlw    how_many_bytes_receives_ds18
         movwf     n

         LFSR     FSR2, id_czujnika_ds
         
petla_kopiowania_bajt_ID
         movff    POSTINC1,POSTINC2
         
         decfsz   n,f
         goto     petla_kopiowania_bajt_ID
         
         

         LFSR     FSR1, dane_odebrane_z_ds
         movlw    how_many_bytes_receives_ds18
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
