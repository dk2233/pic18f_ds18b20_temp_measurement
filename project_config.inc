;here set include to define all processor type symbols
;

    LIST   P=PIC18F46K80
    include  "p18f46k80.inc"


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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;						ustawienie LCD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;configuration of LCD pins
;dolne bity PORTC
polozenie_danych_lcd        equ   0
;definicja bitow uzywanych w 4 bitowym przesylaniu 0 - uzywany 1 - nieuzywany
;zwiazane z opcja kasowania
ktore_bity_uzywane_na_lcd     equ   0x0f
ktore_bity_lcd_tris           equ   0x0f
normalne_ustawienie_tris_lcd  equ   b'11110000'
;;                                1, DL (1 - 8 bit, 0 -4 bit), N - ilosc linii (1 - 2 linie), F = font   
set_4bit		  equ      b'00100000' ;  4bit, 2 linie,font 5x8
;;;                                 DCB  D = display 0 -wylacz, Cursor = 1/0 Blinking=1/0 
display_set         equ      b'00001100' ;ustawia blinking,cursor,

;;;ustawiam entry                           I,S 
set_entry           equ             b'00000110' ;increment I=1, Shift = 1/0


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




enable            equ      6
rs                equ      5
rw                equ      5




czy_lampka_miga             equ 0
ile_zliczen_TMR3        equ   0x05
ile_zliczen_TMR3_do_pomiaru        equ   0x20


;"DS18B20  ---------------------------------------------------
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

how_many_bytes_rec_ds18_id     equ  8
how_many_bytes_rec_ds18_temp     equ  9
how_many_bytes_ds18_temp_show     equ  8

;0x3f - dla 4 MHz
;
;movlw   
;movwf    T2CON
czas_oczekiwania_60us         equ   0x3c
czas_oczekiwania_480us        equ   0xf0
;"---------------------------------------------------
;"---------------------------------------------------
; extern function
