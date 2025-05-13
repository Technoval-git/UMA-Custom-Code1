*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI65 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SHOW_F4_HELP_FOR_MBLNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_f4_help_for_mblnr .

  DATA: flag(1).
  flag  = 'X'.
  EXPORT flag TO MEMORY ID 'MB51_FLAG'.


  AUTHORITY-CHECK OBJECT 'S_TCODE'
           ID 'TCD' FIELD 'MB51'.
  IF sy-subrc <> 0.
    MESSAGE s321(/DBE/service) WITH 'MB51'. "#NOTEXT.
* No Authority for Transaction &1
    EXIT.
  ENDIF.
  CALL TRANSACTION 'MB51'.
*  GET PARAMETER ID 'MBN' FIELD vlcgreceipt-mblnr. "mblnr. "rm07m-mblnr.

ENDFORM.                    " SHOW_F4_HELP_FOR_MBLNR
