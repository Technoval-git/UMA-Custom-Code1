FUNCTION zsd_get_einvoice_tlv_format.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_SELLER) TYPE  STRING
*"     REFERENCE(IV_VATNO) TYPE  STRING
*"     REFERENCE(IV_TIMESTAMP) TYPE  STRING
*"     REFERENCE(IV_INV_AMT) TYPE  STRING
*"     REFERENCE(IV_VAT_AMT) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(EV_TLV_FORMAT) TYPE  STRING
*"----------------------------------------------------------------------

  DATA: lv_seller    TYPE string,
        lv_vatno     TYPE string,
        lv_timestamp TYPE timestamp,
        lv_inv_amt   TYPE string,
        lv_vat_amt   TYPE string.

  DATA: lv_seller_lbl  TYPE string,
        lv_vatno_lbl   TYPE string,
        lv_tmstmp_lbl  TYPE string,
        lv_amt_lbl     TYPE string,
        lv_vat_lbl     TYPE string,
        lv_wo_encd     TYPE string,
        lv_date_format TYPE string.

  DATA: lv_x_seller    TYPE xstring,
        lv_x_vatno     TYPE xstring,
        lv_x_timestamp TYPE xstring,
        lv_x_inv       TYPE xstring,
        lv_x_vat       TYPE xstring.

  DATA: lv_seller_len    TYPE xstring,
        lv_vatno_len     TYPE xstring,
        lv_timestamp_len TYPE xstring,
        lv_inv_len       TYPE xstring,
        lv_vat_len       TYPE xstring.

  DATA: lv_inv_amt_c TYPE wrbtr,
        lv_vat_amt_c TYPE wrbtr,
        lv_char      TYPE c LENGTH 20,
        lv_strlen    TYPE i,
        lv_year      TYPE string,
        lv_mon       TYPE string,
        lv_date      TYPE string,
        lv_hour      TYPE string,
        lv_min       TYPE string,
        lv_sec       TYPE string,
        lv_ts        TYPE string,
        lv_dats      TYPE dats,
        lv_time      TYPE tims.

  DATA: lv_tag TYPE xstring.

  DATA: lv_final_xstring TYPE xstring.

  lv_seller     = iv_seller.
  lv_vatno      = iv_vatno.
  lv_timestamp  = iv_timestamp.
  lv_inv_amt    = iv_inv_amt.
  lv_vat_amt    = iv_vat_amt.

  TRANSLATE lv_inv_amt USING '٠0١1٢2٣3٤4٥5٦6٧7٨8٩9'.
  TRANSLATE lv_vat_amt USING '٠0١1٢2٣3٤4٥5٦6٧7٨8٩9'.

  lv_inv_amt_c = lv_inv_amt.
  lv_vat_amt_c = lv_vat_amt.

  SELECT * FROM zsd_einv_param_c INTO TABLE @DATA(lt_einv_param).
  IF sy-subrc = 0.
    LOOP AT lt_einv_param INTO DATA(ls_param).
      CASE ls_param-param_name.
        WHEN 'SELLER_LBL'.
          lv_seller_lbl  = ls_param-param_value.
        WHEN 'VATNO_LBL'.
          lv_vatno_lbl   = ls_param-param_value.
        WHEN 'TMSTMP_LBL'.
          lv_tmstmp_lbl  = ls_param-param_value.
        WHEN 'AMOUNT_LBL'.
          lv_amt_lbl     = ls_param-param_value.
        WHEN 'VAT_LBL'.
          lv_vat_lbl     = ls_param-param_value.
        WHEN 'DATE_FORMT'.
          lv_date_format = ls_param-param_value.
        WHEN 'TLV_WO_ENC'.
          lv_wo_encd     = ls_param-param_value.
      ENDCASE.
    ENDLOOP.
  ENDIF.

  WRITE lv_inv_amt_c CURRENCY 'SAR' TO lv_char.
  lv_inv_amt = lv_char.
  WRITE lv_vat_amt_c CURRENCY 'SAR' TO lv_char.
  lv_vat_amt = lv_char.

  CONDENSE:  lv_seller   ,
             lv_vatno    ,
*             lv_timestamp,
             lv_inv_amt  ,
             lv_vat_amt  ,
             lv_seller_lbl,
             lv_vatno_lbl,
             lv_tmstmp_lbl,
             lv_amt_lbl,
             lv_vat_lbl,
             lv_date_format,
             lv_wo_encd.

  CONVERT TIME STAMP lv_timestamp TIME ZONE sy-zonlo INTO DATE lv_dats TIME lv_time.
  TRY .
      lv_year = lv_dats(4).
      lv_mon  = lv_dats+4(2).
      lv_date = lv_dats+6(2).
      lv_hour = lv_time(2).
      lv_min  = lv_time+2(2).
      lv_sec  = lv_time+4(2).
*      CONCATENATE lv_date '/' lv_mon '/' lv_year ' ' lv_hour ':' lv_min ':' lv_sec INTO lv_ts RESPECTING BLANKS.
      REPLACE FIRST OCCURRENCE OF 'YYYY' IN lv_date_format WITH lv_year.
      REPLACE FIRST OCCURRENCE OF 'MM' IN lv_date_format WITH lv_mon.
      REPLACE FIRST OCCURRENCE OF 'DD' IN lv_date_format WITH lv_date.
      REPLACE FIRST OCCURRENCE OF 'hh' IN lv_date_format WITH lv_hour.
      REPLACE FIRST OCCURRENCE OF 'mm' IN lv_date_format WITH lv_min.
      REPLACE FIRST OCCURRENCE OF 'ss' IN lv_date_format WITH lv_sec.

      lv_ts = lv_date_format.
      CONDENSE : lv_ts.
    CATCH cx_root.

  ENDTRY.

*  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
*    EXPORTING
*      currency        = 'SAR'                 " Currency
*      amount_internal = lv_inv_amt                 " Currency Amount (SAP): Internal Data Format
*    IMPORTING
*      amount_external = lv_inv_amt_c.                 " Currency Amount: External Data Format
*  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
*    EXPORTING
*      currency        = 'SAR'                 " Currency
*      amount_internal = lv_vat_amt                 " Currency Amount (SAP): Internal Data Format
*    IMPORTING
*      amount_external = lv_vat_amt_c.                 " Currency Amount: External Data Format
*
*  lv_inv_amt = lv_inv_amt_c.
*  lv_vat_amt = lv_vat_amt_C.
*
*  lv_strlen = strlen( lv_inv_amt ).
*  lv_strlen = lv_strlen - 2.
*  lv_inv_amt = lv_inv_amt(lv_strlen).
*
*  lv_strlen = strlen( lv_vat_amt ).
*  lv_strlen = lv_strlen - 2.
*  lv_vat_amt = lv_vat_amt(lv_strlen).

  IF lv_wo_encd IS NOT INITIAL.
    CONCATENATE
    lv_seller_lbl ' '
    lv_seller
    ' ' lv_vatno_lbl ' '
    lv_vatno
    ' ' lv_tmstmp_lbl ' '
    lv_ts
    ' ' lv_amt_lbl ' '
    lv_inv_amt
    ' ' lv_vat_lbl ' '
    lv_vat_amt
    INTO ev_tlv_format RESPECTING BLANKS.

  ELSE.
*..<< Seller >>
    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text     = lv_seller
        mimetype = space
        encoding = '4110'
      IMPORTING
        buffer   = lv_x_seller
      EXCEPTIONS
        failed   = 1
        OTHERS   = 2.

    lv_seller_len = xstrlen( lv_x_seller ).

    lv_tag = '01'.
    CONCATENATE lv_tag lv_seller_len lv_x_seller INTO lv_final_xstring IN BYTE MODE.

*..<< VAT No >>
    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text     = lv_vatno
        mimetype = space
        encoding = '4110'
      IMPORTING
        buffer   = lv_x_vatno
      EXCEPTIONS
        failed   = 1
        OTHERS   = 2.

    lv_vatno_len = xstrlen( lv_x_vatno ).

    lv_tag = '02'.
    CONCATENATE lv_final_xstring lv_tag lv_vatno_len lv_x_vatno INTO lv_final_xstring IN BYTE MODE.


*..<< Timestamp >>
    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text     = lv_ts
        mimetype = space
        encoding = '4110'
      IMPORTING
        buffer   = lv_x_timestamp
      EXCEPTIONS
        failed   = 1
        OTHERS   = 2.

    lv_timestamp_len = xstrlen( lv_x_timestamp ).

    lv_tag = '03'.
    CONCATENATE lv_final_xstring lv_tag lv_timestamp_len lv_x_timestamp INTO lv_final_xstring IN BYTE MODE.

*..<< Invoice Amount >>
    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text     = lv_inv_amt
        mimetype = space
        encoding = '4110'
      IMPORTING
        buffer   = lv_x_inv
      EXCEPTIONS
        failed   = 1
        OTHERS   = 2.

    lv_inv_len = xstrlen( lv_x_inv ).

    lv_tag = '04'.
    CONCATENATE lv_final_xstring lv_tag lv_inv_len lv_x_inv INTO lv_final_xstring IN BYTE MODE.

*..<< Timestamp >>
    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text     = lv_vat_amt
        mimetype = space
        encoding = '4110'
      IMPORTING
        buffer   = lv_x_vat
      EXCEPTIONS
        failed   = 1
        OTHERS   = 2.

    lv_vat_len = xstrlen( lv_x_vat ).

    lv_tag = '05'.
    CONCATENATE lv_final_xstring lv_tag lv_vat_len lv_x_vat INTO lv_final_xstring IN BYTE MODE.

*..<< BASE 64 Conversion >>
    CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
      EXPORTING
        input  = lv_final_xstring
      IMPORTING
        output = ev_tlv_format.

  ENDIF.

ENDFUNCTION.
