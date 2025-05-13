*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF55 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ENTRY_BSART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form F_CHECK_ENTRY_BSART .
DATA ls_T161   TYPE T161.
  SELECT SINGLE * FROM T161 INTO ls_T161 WHERE bstyp = 'F' AND bsart = VLCACTDATA_HEAD_S-bsart.

  IF SY-SUBRC <> 0.
    MESSAGE e058(00) WITH VLCACTDATA_HEAD_S-bsart '' '' 'T161'.
  ENDIF.
endform.                    " F_CHECK_ENTRY_BSART


*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ENTRY_KOSTL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHECK_ENTRY_KOSTL .
* see also: /DBE/TM_VT_DATA class' CHECK_KOSTL method
  DATA ls_CSKS   TYPE CSKS.
  SELECT SINGLE * FROM CSKS INTO ls_CSKS WHERE kostl = VLCACTDATA_HEAD_S-/dbe/kostl. "#EC *

  IF SY-SUBRC <> 0.
    MESSAGE e058(00) WITH VLCACTDATA_HEAD_S-/dbe/kostl '' '' 'CSKS'.
  ENDIF.
ENDFORM.
