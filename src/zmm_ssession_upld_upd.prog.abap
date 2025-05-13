*&---------------------------------------------------------------------*
*& Include          ZMM_SSESSION_UPLD_UPD
*&---------------------------------------------------------------------*



DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.

CLEAR bdcdata[].
CLEAR bdcdata.
bdcdata-program  = 'SAPLPIC01'.
bdcdata-dynpro   = '0100'.
bdcdata-dynbegin = 'X'.
APPEND bdcdata.

CLEAR bdcdata.
bdcdata-fnam = 'BDC_CURSOR'.
bdcdata-fval = 'RM61R-MATNR'.
APPEND bdcdata.
CLEAR bdcdata.
bdcdata-fnam = 'RM61R-MATNR'.
bdcdata-fval = p_matnr.
APPEND bdcdata.
CLEAR bdcdata.
bdcdata-fnam = 'BDC_OKCODE'.
bdcdata-fval = '=SUPS'.
APPEND bdcdata.

CALL TRANSACTION 'PIC01'  USING bdcdata MODE 'E'.
