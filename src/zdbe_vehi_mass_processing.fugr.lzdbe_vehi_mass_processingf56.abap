*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF56 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ENTRY_EKORG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_entry_ekorg .
  CALL FUNCTION 'T024E_SINGLE_READ'
     EXPORTING
*     KZRFB             = ' '
       t024e_ekorg       = vlcactdata_head_s-ekorg
*   IMPORTING
*     WT024E            =
     EXCEPTIONS
       not_found         = 1
*     OTHERS            = 2
             .
  IF sy-subrc <> 0.
    MESSAGE e058(00) WITH vlcactdata_head_s-ekorg '' '' 'T024E'.
  ENDIF.
ENDFORM.                    " F_CHECK_ENTRY_EKORG
