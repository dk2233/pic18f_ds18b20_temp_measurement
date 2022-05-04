;procedura mnozy dowolną liczbe
;zapisana w ;
;mnozonah i mnozona 
;ulamki w ulamekh i ulamekl
;przez zawrtosc
;rejestru operandl
;i operandh
;wynik obejmuje rowniez ulamki


;6 bajtowy wynik


;mnozenie działaniem

;  mnozonah:mnozona * operandh:operand

; wynik3:wynika = 

mnozenie 
         
         clrf     wynik
         clrf     wynik1
         clrf     wynik2
         clrf     wynik3
         clrf     wynik01
         clrf     wynik001

mnozenie_l
;mnozona*operand 
         ;decf    operandl,f
         
         movf     operandl,w
         mulwf    mnozonal         
         movff    PRODH,wynik1
         movff    PRODL,wynik
         

;mnozonah*operandh* 2^16
         
         movf     operandh,w
         mulwf    mnozonah
         movff    PRODH,wynik3
         movff    PRODL,wynik2


         movf     operandh,w
         mulwf    mnozonal
         ;movff    PRODH,wynik3
         movf     PRODL,w
         addwf    wynik1,f
         movf     PRODH,w
         addwfc   wynik2,f
         clrf     WREG
         addwfc   wynik3,f
         

         
         movf     operandl,w
         mulwf    mnozonah
         ;movff    PRODH,wynik3
         movf     PRODL,w
         addwf    wynik1,f
         movf     PRODH,w
         addwfc   wynik2,f
         clrf     WREG
         addwfc   wynik3,f
         
                          
         return