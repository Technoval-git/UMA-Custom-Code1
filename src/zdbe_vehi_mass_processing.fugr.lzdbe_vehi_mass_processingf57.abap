*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF57 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ENTRY_EKGRP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_entry_ekgrp .

  CALL FUNCTION 'T024_SINGLE_READ'
     EXPORTING
*     KZRFB            = ' '
       t024_ekgrp       = vlcactdata_head_s-ekgrp
*   IMPORTING
*     WT024            =
     EXCEPTIONS
       not_found        = 1
*     OTHERS           = 2
             .

  IF sy-subrc <> 0.
    MESSAGE e058(00) WITH vlcactdata_head_s-ekgrp '' '' 'T024'.
  ENDIF.
ENDFORM.                    " F_CHECK_ENTRY_EKGRP
