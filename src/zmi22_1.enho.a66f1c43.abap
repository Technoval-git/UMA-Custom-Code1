"Name: \PR:RM07IMAT\FO:PREPARE_FIELDCAT_DETAIL_ALV\SE:END\EI
ENHANCEMENT 0 ZMI22_1.
*
     LOOP AT fieldcat_4 INTO fieldcat_4_s.
       IF fieldcat_4_s-fieldname EQ 'LGPBE'.
         fieldcat_4_s-no_out = 'X'.
         MODIFY fieldcat_4 FROM fieldcat_4_s.
       ENDIF.
     ENDLOOP.

     LOOP AT yiseg1 ASSIGNING FIELD-SYMBOL(<wa_YISEG1>).
       SELECT SINGLE lgpbe FROM mard INTO <wa_YISEG1>-lgpbe WHERE matnr = <wa_YISEG1>-matnr
                                                              AND werks = <wa_YISEG1>-werks
                                                              AND lgort = <wa_YISEG1>-lgort.
     ENDLOOP.
ENDENHANCEMENT.
