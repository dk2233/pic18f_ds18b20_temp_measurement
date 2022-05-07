

    Global n_ds18b20
    Global bajt_CRC
    Global polecenie_wysylane
    Global status_ds18b20



GPR_DATA   UDATA
n_ds18b20   RES   1
bajt_CRC    RES   1
jak_duzo_bajtow_odbieram_z_ds   RES   1
polecenie_wysylane   RES  1
status_ds18b20       RES  1


;"---------------------------------------------------;
;bits of status_ds18b20
initialization_not_ok   equ 0

