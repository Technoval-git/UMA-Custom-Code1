FUNCTION zsd_getinv_qrdata .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(L_VBELN) TYPE  VBELN
*"     REFERENCE(L_VAT_AMT) TYPE  ANY
*"     REFERENCE(L_TOTAL) TYPE  ANY
*"  EXPORTING
*"     REFERENCE(LS_QR) TYPE  STRING
*"----------------------------------------------------------------------


*break tech2.
  DATA: lv_seller  TYPE string,
        lv_vat_no  TYPE string,
        lv_timestm TYPE string,
        lv_net     TYPE string,
        lv_vat     TYPE string,
        lv_ts      TYPE timestamp,
        lv_vbeln   TYPE vbrk-vbeln.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = l_vbeln                 " C field
    IMPORTING
      output = lv_vbeln.                 " Internal display of INPUT, any category

* break tech2.
  SELECT SINGLE fkdat, erzet, bukrs FROM vbrk
    INTO @DATA(ls_vbrk)
    WHERE vbeln = @lv_vbeln.

  IF sy-subrc EQ 0.

*    SELECT SINGLE low FROM tvarvc CLIENT SPECIFIED
*    INTO @DATA(lv_low)
*    WHERE mandt = '000'
*      AND name = 'ZEINVPHASE2_BUKRS'
*      AND low = @ls_vbrk-bukrs.
*    SELECT SINGLE * FROM edosaintactdate INTO @DATA(ls_efind) WHERE bukrs = @ls_vbrk-bukrs AND act_date LE @sy-datum.
    SELECT SINGLE * FROM edosaintactdate INTO @DATA(ls_efind) WHERE bukrs = @ls_vbrk-bukrs AND act_date LE @ls_vbrk-fkdat. "changing this to billing date we need it for old invoices QRcode
    IF sy-subrc NE 0.
      CONVERT DATE ls_vbrk-fkdat TIME ls_vbrk-erzet INTO TIME STAMP lv_ts TIME ZONE sy-zonlo.
      lv_timestm = lv_ts.

      SELECT SINGLE adrnr, stceg FROM t001 INTO ( @DATA(lv_adrnr) ,
        @DATA(lv_stceg) )
        WHERE bukrs = @ls_vbrk-bukrs.
      IF sy-subrc = 0.
        IF lv_adrnr IS NOT INITIAL.
          SELECT SINGLE name1, name2 FROM adrc INTO (@DATA(lv_name1),@DATA(lv_name2))
            WHERE addrnumber = @lv_adrnr AND nation EQ @space
            AND date_to GT @sy-datum.
          IF sy-subrc EQ 0.
            IF ls_vbrk-bukrs NE '2100'.
              lv_seller = |{ lv_name1 } { lv_name2 }|.
            ELSE.
              lv_seller =  lv_name1 .
            ENDIF.

          ENDIF.
        ENDIF.
        lv_vat_no = lv_stceg.
      ENDIF.


      lv_net = l_total.
      lv_vat = l_vat_amt.

      CALL FUNCTION 'ZSD_GET_EINVOICE_TLV_FORMAT'
        EXPORTING
          iv_seller     = lv_seller
          iv_vatno      = lv_vat_no
          iv_timestamp  = lv_timestm
          iv_inv_amt    = lv_net
          iv_vat_amt    = lv_vat
        IMPORTING
          ev_tlv_format = ls_qr.


***************************************************************************
    ELSE.  "E-invoicing phase 2 QR code logic

      DATA: lv_source_key TYPE edoc_source_key,
            lv_edoc_guid  TYPE edoc_guid,
            lv_qr_code_x  TYPE edoc_sa_xstring,
            lv_qr_code    TYPE string.
      "Get Data from eDocument Table for SD/FI Source Document
      "For SD Invoice, use the below code snippet for populating variable
      "lv_source_key
      "Fill this variable with relevant Billing Document Number
      "along with leading zeros
      cl_edoc_source_sd_invoice=>pack_key(
       EXPORTING
       iv_vbeln = lv_vbeln
       IMPORTING
       ev_key = lv_source_key ).

      "Also eDocument should be in GeneratedAndStored or SentToCustomer Status
      SELECT SINGLE edoc_guid FROM edocument INTO lv_edoc_guid
       WHERE source_key = lv_source_key
       AND proc_status <> 'CREATED'.
      "Get QR Code Data from KSA Specific Database Table using eDocument GUID
      SELECT SINGLE qr_code FROM edosainv INTO lv_qr_code_x
       WHERE edoc_guid = lv_edoc_guid.
      lv_qr_code = cl_http_utility=>if_http_utility~encode_x_base64(
       unencoded = lv_qr_code_x ).
      ls_qr = lv_qr_code .

*      cl_rstx_barcode_renderer=>qr_code(EXPORTING i_module_size=lc_module_sizei_mode=lc_modei_error_correction=lc_error_correctioni_barcode_text=lv_qr_codeIMPORTINGe_bitmap=lv_bitmap).


    ENDIF.
  ENDIF.

  IF 1 = 2.   "Faisal: Added to check the size of string QR code can print, by changing it from debugger.
    DATA: lv_string TYPE string.
    CONCATENATE ls_qr lv_string INTO ls_qr.
  ENDIF.

ENDFUNCTION.
