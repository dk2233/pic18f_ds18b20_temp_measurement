



    ;.file "data.inc"
        

    global ile_zliczen_TMR3_do_sekundy
    global ktore_zliczenie_tmr3_do_pomiar
    global odebrano_liter
    global markers2
    Global tmp_lcd
    Global dane_lcd
    Global n_lcd
    Global arg1
    
    

    
GPR_MAIN_DATA   UDATA    0x60 
ktore_zliczenie_tmr3_do_pomiar    RES  1
w_temp       RES   1
status_temp  RES   1
bsr_temp     RES   1
fsrl_temp    RES   1
fsrh_temp    RES   1
fsrl1_temp   RES   1
fsrh1_temp   RES   1
czas         RES   1
markers      RES   1
markers2   RES  1
markers_pomiary  RES  1 
odebrano_liter   RES  1

tmp    RES   1
tmp7    RES   1


n    RES  1

zliczanie_pomiaru   RES  1

temp_100    RES   1
temp_10     RES   1
temp_1      RES   1
temp_ulamek RES   1

reszta_operacji  RES  1

wynik3   RES   1
wynik2   RES   1
wynik1   RES   1
wynik    RES   1
wynik01  RES  1
wynik001   RES  1

dec100    RES  1
dec10     RES  1
dec1      RES  1

dzielonah  RES  1
dzielona   RES  1

ulamekh RES  1
ulamekl RES  1

operandh RES  1
operandl RES  1

mnozonah RES  1
mnozonal RES  1

ile_zliczen_TMR3_do_sekundy  RES 1


;lcd variables
dane_lcd    RES 1
tmp_lcd    RES 1
n_lcd    RES 1


arg1    RES   1
