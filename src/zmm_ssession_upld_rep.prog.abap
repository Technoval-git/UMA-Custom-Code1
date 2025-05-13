*&---------------------------------------------------------------------*
*& Include          ZMM_SSESSION_UPLD_REP
*&---------------------------------------------------------------------*

*ALV DECLERATIONS
DATA: lt_fieldcat TYPE slis_t_fieldcat_alv.
DATA: lwa_fieldcat TYPE slis_fieldcat_alv.

  SELECT matnr, seqnr, datfr, inttype, piccode
    FROM picps
    INTO TABLE @DATA(lt_matnr)
    WHERE matnr IN @s_matnr.

  SORT lt_matnr BY matnr seqnr.

  IF sy-subrc = 0.


    lwa_fieldcat-row_pos = 1.
    lwa_fieldcat-col_pos = 1.
    lwa_fieldcat-fieldname = 'MATNR'.
    lwa_fieldcat-tabname = 'lt_matnr'.
    lwa_fieldcat-outputlen = 40.
    lwa_fieldcat-seltext_m = 'Material No'.
    APPEND lwa_fieldcat TO lt_fieldcat.
    CLEAR: lwa_fieldcat.

    lwa_fieldcat-row_pos = 1.
    lwa_fieldcat-col_pos = 2.
    lwa_fieldcat-fieldname = 'SEQNR'.
    lwa_fieldcat-tabname = 'lt_matnr'.
    lwa_fieldcat-outputlen = 4.
    lwa_fieldcat-seltext_m = 'SEQNR'.
    APPEND lwa_fieldcat TO lt_fieldcat.
    CLEAR: lwa_fieldcat.

    lwa_fieldcat-row_pos = 1.
    lwa_fieldcat-col_pos = 3.
    lwa_fieldcat-fieldname = 'DATFR'.
    lwa_fieldcat-tabname = 'lt_matnr'.
    lwa_fieldcat-outputlen = 8.
    lwa_fieldcat-seltext_m = 'DATFR'.
    APPEND lwa_fieldcat TO lt_fieldcat.
    CLEAR: lwa_fieldcat.

    lwa_fieldcat-row_pos = 1.
    lwa_fieldcat-col_pos = 4.
    lwa_fieldcat-fieldname = 'INTTYPE'.
    lwa_fieldcat-tabname = 'lt_matnr'.
    lwa_fieldcat-outputlen = 1.
    lwa_fieldcat-seltext_m = 'INTTYPE'.
    APPEND lwa_fieldcat TO lt_fieldcat.
    CLEAR: lwa_fieldcat.

    lwa_fieldcat-row_pos = 1.
    lwa_fieldcat-col_pos = 5.
    lwa_fieldcat-fieldname = 'PICCODE'.
    lwa_fieldcat-tabname = 'lt_matnr'.
    lwa_fieldcat-outputlen = 4.
    lwa_fieldcat-seltext_m = 'PICCODE'.
    APPEND lwa_fieldcat TO lt_fieldcat.
    CLEAR: lwa_fieldcat.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        it_fieldcat   = lt_fieldcat
      TABLES
        t_outtab      = lt_matnr
      EXCEPTIONS
        program_error = 1
        OTHERS        = 2.

  ELSE.
    MESSAGE 'Please enter the right range!' TYPE 'I'.
  ENDIF.
