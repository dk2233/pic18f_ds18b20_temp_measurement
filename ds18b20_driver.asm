
    include "project_config.inc"
    include "ds18b20_driver.inc"


    Global bajt_CRC
    Global status_ds18b20

GPR_DATA   UDATA
n_ds18b20   RES   1
bajt_CRC    RES   1
jak_duzo_bajtow_odbieram_z_ds   RES   1
polecenie_wysylane   RES  1
status_ds18b20       RES  1




    Global inicjacja_ds1820_1
    Global petla_wysylania_rozkazu_1
    Global petla_odbioru_rozkazu_1
    Global check_CRC_DS

DS18B20_CODE    CODE    
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
         
         ;there is some error
         ;lets mark error and finish
         
         bsf    status_ds18b20, initialization_not_ok
         return
         
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
         movwf     n_ds18b20
         
petla_sending_pomiar_1

        btfss     polecenie_wysylane,0
        call      send_zero_1
        btfsc     polecenie_wysylane,0
        call      send_one_1
        bsf       latch_ds1820,czujnik_ds1820_1
        
        bcf       STATUS,C
        rrcf       polecenie_wysylane,f
        
        decfsz    n_ds18b20,f
        goto      petla_sending_pomiar_1
         
        goto       petla_wysylania_rozkazu_1


        
        
        

        
        
        


      
      
      
      
      
      
      
      
      
      
      
      
      




      
    
        
petla_odbioru_rozkazu_1
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
        movwf     n_ds18b20
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
        
        decfsz    n_ds18b20,f
        goto      petla_stan_odebranego_bitu_1
        incf      FSR1L,f
        
;czy juz przeszly wszystkie bajty z DS
        decfsz    jak_duzo_bajtow_odbieram_z_ds,f
        goto      petla_odbioru_z_ds1820_1

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
         
         decfsz n_ds18b20,f 
         goto check_CRC_DS_loop         
                     

         ;movwf bajt_CRC         
 

         return         
         


         end
