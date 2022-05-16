
    include "project_config.inc"

    extern  arg1

    global zamien_na_hex

LETTERS_CODE   CODE
;change_to_hex
zamien_na_hex
;jezeli po odjeciu 0a jest niezanaczony bit C
;to znaczy ze dodaj 
         movwf    arg1
         movlw    0x0a
         subwf    arg1,w
         btfss    STATUS,C
         goto     cyfry_0_9
         movf     arg1,w
         addlw    0x37
         return
cyfry_0_9         
         movf     arg1,w
         addlw    0x30
         return


         end
