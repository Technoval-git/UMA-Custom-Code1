"Name: \FU:/SCWM/RF_IVCOUN_MATID_CHECK\SE:END\EI
ENHANCEMENT 0 ZRF_MATNR_VALID2.

 CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
   EXPORTING
     input  = ivmat-matnr_verif
   IMPORTING
     output = ivmat-matnr_verif.

 IF ivmat-matnr+0(2) NE ivmat-matnr_verif+0(2).
   CONCATENATE ivmat-matnr+0(2) ivmat-matnr_verif INTO  ivmat-matnr_verif.
   IF ivmat-matnr = ivmat-matnr_verif.
     ev_flg_verified = 'X'.
     LOOP AT ivmattab ASSIGNING FIELD-SYMBOL(<iivmattab>).
       <iivmattab>-matnr_verif = ivmat-matnr_verif.
     ENDLOOP.
   ENDIF.
 ENDIF.


ENDENHANCEMENT.
