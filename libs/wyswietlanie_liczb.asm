;przed uruchomieniem nale¿y umieœciæ w WREG

;liczbê do przetworzenia


;wymaga do dzia³ania wyœwietlania lcd

wyswietl_liczbe_1bajtowa
         
         call     hex2dec
                 
         
         call     check_busy4bit
         
         movf     dec100,w         
         btfss    STATUS,Z
         goto     Znajdz_wartosc_opcji_100
         
Znajdz_wartosc_100_zero
         bsf    markers,poprzednio_cyfra_zero
         movlw    _puste
         goto     Znajdz_wartosc_100_pisz
         
         

Znajdz_wartosc_opcji_100 
         bcf    markers,poprzednio_cyfra_zero         
         addlw    0x30

Znajdz_wartosc_100_pisz                 
         call     write_lcd
         
         call     check_busy4bit
         
         movf     dec10,w
         btfss    STATUS,Z
         goto     Znajdz_wartosc_opcji_10
         
Znajdz_wartosc_10_zero 
         btfss    markers,poprzednio_cyfra_zero
         goto     Znajdz_wartosc_opcji_10
         
         movlw    _puste
         goto     Znajdz_wartosc_10_pisz

Znajdz_wartosc_opcji_10         
         bcf    markers,poprzednio_cyfra_zero    
         addlw    0x30

Znajdz_wartosc_10_pisz          
         call     write_lcd
         
         call     check_busy4bit
         
         movf     dec1,w
         addlw    0x30
         
         call     write_lcd
         
         
         return