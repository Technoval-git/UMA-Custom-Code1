FUNCTION ZDBE_VMASS_ADC_READ_SER_MAT_DB.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_SERVICE_TYPE) TYPE  /DBE/STYPE_TP
*"     REFERENCE(IV_PLANT) TYPE  WERKS_D
*"  EXPORTING
*"     REFERENCE(EV_SERVICE_MAT) TYPE  MATNR
*"  EXCEPTIONS
*"      NO_RECORD_FOUND
*"      DATA_INCOS
*"--------------------------------------------------------------------
  DATA:lt_serv_mat type table of /DBE/servmat,
        ls_serv_mat type /DBE/servmat,
        lines type i.

  SELECT * FROM /DBE/servmat into table lt_serv_mat WHERE werks = iv_plant AND service_type = iv_service_type.
  if sy-subrc <> 0.
    raise NO_RECORD_FOUND.
  else.
    DESCRIBE TABLE lt_serv_mat LINES lines.
    if lines GT 1.
      raise DATA_INCOS.
    else.
      read table lt_serv_mat into ls_serv_mat INDEX 1.
      ev_SERVICE_MAT = ls_serv_mat-matnr.
    endif.

  endif.


ENDFUNCTION.
