FUNCTION ydbe_vss_prt_crdt_invoice .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_INVOICE_NO) TYPE  VBELN_VF
*"     REFERENCE(IV_SF) TYPE  C OPTIONAL
*"     REFERENCE(IV_LANGU) TYPE  SPRAS OPTIONAL
*"  EXPORTING
*"     REFERENCE(ES_HEADER) TYPE
*"        YCL_DBE_PRT_CRDT_INV_FRM_UTIL=>TY_HEADER
*"     REFERENCE(ET_BODY) TYPE
*"        YCL_DBE_PRT_CRDT_INV_FRM_UTIL=>TT_BODY_STR
*"     REFERENCE(ES_FOOTER) TYPE
*"        YCL_DBE_PRT_CRDT_INV_FRM_UTIL=>TY_FOOTER_STR
*"     REFERENCE(ET_RETURN) TYPE  BAPIRET2_TAB
*"     REFERENCE(ET_OTF) TYPE  TSFOTF
*"----------------------------------------------------------------------
  DATA : ls_header     TYPE ycl_dbe_prt_crdt_inv_frm_util=>ty_header,
         lt_body       TYPE ycl_dbe_prt_crdt_inv_frm_util=>tt_body,
         ls_body       LIKE LINE OF lt_body,
         lt_body_str   TYPE ycl_dbe_prt_crdt_inv_frm_util=>tt_body_str,
         ls_body_str   LIKE LINE OF  lt_body_str,
         ls_footer     TYPE ycl_dbe_prt_crdt_inv_frm_util=>ty_footer,
         ls_footer_str TYPE ycl_dbe_prt_crdt_inv_frm_util=>ty_footer_str,
         lv_salesman   TYPE so_adrnam,
         lv_get_otf    LIKE abap_true.
  DATA lv_partner TYPE bu_partner.
  DATA lt_tax TYPE TABLE OF bus_tax.
  DATA ls_tax TYPE bus_tax.
  "header data
  CALL METHOD ycl_dbe_prt_crdt_inv_frm_util=>header_data
    EXPORTING
      iv_invoice_number = iv_invoice_no
      iv_langu          = iv_langu
    IMPORTING
      es_header_data    = ls_header
      ev_salesman       = lv_salesman.
  "item data
  CALL METHOD ycl_dbe_prt_crdt_inv_frm_util=>items_data
    EXPORTING
      iv_invoice_no = iv_invoice_no   "ls_header-order_no
      iv_langu      = iv_langu
    IMPORTING
      et_items      = lt_body
      es_footer     = ls_footer
    CHANGING
      ct_return     = et_return.



  lv_partner = ls_header-ac_number.
  CALL FUNCTION 'BUPA_TAXNUMBERS_GET'
    EXPORTING
      iv_partner      = lv_partner
    TABLES
      et_taxdetails   = lt_tax    " BP: Data Part for Tax Numbers
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.
  IF sy-subrc = 0.
    READ TABLE lt_tax INTO ls_tax
*      WITH KEY tax_type = 'SAZ0'.
      WITH KEY tax_type = 'SA0'.
    IF sy-subrc = 0.
      ls_header-cus_vat = ls_tax-tax_number.
    ENDIF.
  ENDIF.

  CLEAR lt_tax.
  lv_partner = ls_header-financer.
  CALL FUNCTION 'BUPA_TAXNUMBERS_GET'
    EXPORTING
      iv_partner      = lv_partner
    TABLES
      et_taxdetails   = lt_tax    " BP: Data Part for Tax Numbers
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.
  IF sy-subrc = 0.
    READ TABLE lt_tax INTO ls_tax
*      WITH KEY tax_type = 'SAZ0'.
      WITH KEY tax_type = 'SA0'.      "*Urgent_Change: 7000000152 Tax code hardcoding
    IF sy-subrc = 0.
      ls_header-fin_vat = ls_tax-tax_number.
    ENDIF.
  ENDIF.
****Urgent_Change: 7000000152 Tax code hardcoding | begin
***  IF ls_header-fin_vat is INITIAL.
***  select SINGLE stceg from kna1 INTO @DATA(l_vat) where kunnr = lv_partner.
***    IF sy-subrc eq 0.
***      ls_header-fin_vat = l_vat .
***    ENDIF.
***  ENDIF.
****Urgent_Change: 7000000152 Tax code hardcoding | end

  IF iv_langu = yif_dbm_jet_constants=>gc_lang_ar.
    TRANSLATE ls_header-financer USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
    TRANSLATE ls_header-ac_number USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
    TRANSLATE ls_header-inv_date USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
    TRANSLATE ls_header-inv_number USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
    TRANSLATE ls_header-ordr_date USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
    TRANSLATE ls_header-order_no USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
    TRANSLATE ls_header-cus_vat USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
    TRANSLATE ls_header-fin_vat USING '0٠1١2٢3٣4٤5٥6٦7٧8٨9٩'.
  ENDIF.

  ls_footer-salesman = lv_salesman.
  "if iv_sf == TRUE then otf data wont be returned but smartform will be showed
  "else it will return otf data and will not show smartform.
  IF iv_sf = abap_true.
    lv_get_otf = space.
  ELSE.
    lv_get_otf = abap_true.
  ENDIF.
  "copy items to string table
  LOOP AT lt_body INTO ls_body.
    CLEAR ls_body_str.
    MOVE-CORRESPONDING ls_body TO ls_body_str.
    APPEND ls_body_str TO lt_body_str.
  ENDLOOP.
  "copy footer to string table
  MOVE-CORRESPONDING ls_footer TO ls_footer_str.
  IF iv_sf = abap_true.
    CALL METHOD ycl_dbe_prt_crdt_inv_frm_util=>display_sf
      EXPORTING
        is_header = ls_header
        iv_langu  = iv_langu
        it_body   = lt_body_str
        is_footer = ls_footer_str
        iv_otf    = lv_get_otf
      IMPORTING
        et_otf    = et_otf
      CHANGING
        ct_return = et_return.
  ENDIF.

  es_header = ls_header.
  et_body = lt_body_str.
  es_footer = ls_footer_str.
ENDFUNCTION.
