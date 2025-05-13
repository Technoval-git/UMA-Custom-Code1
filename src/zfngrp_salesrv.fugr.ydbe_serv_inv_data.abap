*&**********************************************************************
*& FM Definition : FM to fill header & item data to generate oTF data  *                                    *
*&**********************************************************************
FUNCTION ydbe_serv_inv_data.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_BILLING_DOC) TYPE  VBELN_VF OPTIONAL
*"     REFERENCE(IV_SF_SHOW) TYPE  BOOLEAN OPTIONAL
*"     REFERENCE(IV_PRINT) TYPE  CRMT_BOOLEAN OPTIONAL
*"     REFERENCE(IV_PROFORMA) TYPE  CRMT_BOOLEAN OPTIONAL
*"     REFERENCE(IV_ALL) TYPE  BOOLEAN OPTIONAL
*"     REFERENCE(IV_ARABIC) TYPE  CRMT_BOOLEAN OPTIONAL
*"     REFERENCE(IV_LANGU) TYPE  SY-LANGU
*"  EXPORTING
*"     REFERENCE(ET_OTF) TYPE  TSFOTF
*"     REFERENCE(ET_RETURN) TYPE  BAPIRET2_TAB
*"     REFERENCE(ET_HEADER) TYPE  YPRFINV_HEAD_VSS_TT
*"     REFERENCE(ET_LABOR_DETAILS) TYPE  YSERV_INV_ITEM_PDF_TT
*"     REFERENCE(ET_PARTS_DETAILS) TYPE  YSERV_INV_ITEM_PDF_TT
*"     REFERENCE(ET_CONSUMAB_DETAILS) TYPE  YSERV_INV_ITEM_PDF_TT
*"     REFERENCE(ET_ADDITION_DETAILS) TYPE  YSERV_INV_ITEM_PDF_TT
*"     REFERENCE(EV_TAX_PERC) TYPE  STRING
*"----------------------------------------------------------------------
  DATA:
    gt_header           TYPE yprfinv_head_vss_tt,
    it_labor_details    TYPE yserv_inv_item_pdf_tt,
    it_parts_details    TYPE yserv_inv_item_pdf_tt,
    it_consumab_details TYPE yserv_inv_item_pdf_tt,
    it_addition_details TYPE yserv_inv_item_pdf_tt,
    lv_salesorderno     TYPE /dbe/vbeln_va,
    lv_string           TYPE string,
    lv_vbeln            TYPE char10.

  DATA: lt_invoice_list TYPE ycl_dbe_vss_invoice_form_util=>tt_vbeln,
        ls_invoice      LIKE LINE OF lt_invoice_list.

  FIELD-SYMBOLS: <fs_header>           TYPE yprfinv_head_vss_st,
                 <fs_labor_details>    TYPE yserv_inv_item_pdf_st,
                 <fs_parts_details>    TYPE yserv_inv_item_pdf_st,
                 <fs_consumab_details> TYPE yserv_inv_item_pdf_st,
                 <fs_addition_details> TYPE yserv_inv_item_pdf_st,
                 <fs_value>            TYPE any.

  "Get invoice number if it exists
  IF iv_all = abap_true.
    lv_vbeln = iv_billing_doc.
    SHIFT lv_vbeln LEFT DELETING LEADING '0'.

    CONCATENATE '%' lv_vbeln '%' INTO lv_string.
    IF iv_proforma = abap_true.
      SELECT vbeln , zuonr FROM vbrk INTO TABLE @DATA(lt_vbrk)
        WHERE zuonr LIKE @lv_string
        AND vbtyp = 'U'
        AND fkart = 'F5'
        AND fksto = ''.
      IF sy-subrc = 0 AND lt_vbrk IS NOT INITIAL.
*        DATA(lt_vbrk_temp) = lt_vbrk.
        SORT lt_vbrk BY zuonr vbeln DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_vbrk COMPARING zuonr.
        lt_invoice_list = CORRESPONDING #( lt_vbrk ).
      ENDIF.
    ELSE.
      SELECT vbeln FROM vbrk INTO TABLE lt_invoice_list
        WHERE zuonr LIKE lv_string
        AND vbtyp = 'M'
        AND fkart = 'YSER'
        AND fksto = ''.
    ENDIF.
  ELSE.
    ls_invoice-vbeln = iv_billing_doc.
    APPEND ls_invoice TO lt_invoice_list.
  ENDIF.

*  lv_billd_doc = iv_billing_doc.

*  IF sy-subrc = 0."If invoice exists
  "setting the header data
  ycl_dbe_vss_invoice_form_util=>set_header_data(
    EXPORTING
      it_billing_doc  = lt_invoice_list    " DBM Order Number
      iv_proforma     = iv_proforma     "proforma data
      iv_langu        = iv_langu
    IMPORTING
      ev_salesorderno = lv_salesorderno
    CHANGING
      ct_header       = gt_header
      ct_return       = et_return    " Error Messages
  ).

  "Setting the item data
  ycl_dbe_vss_invoice_form_util=>set_item_data_pdf(
    EXPORTING
      it_billing_doc      = lt_invoice_list    " DBM Order Number
    IMPORTING
      ev_tax_perc         = ev_tax_perc
    CHANGING
      ct_header           = gt_header
      ct_labor_details    = it_labor_details
      ct_addition_details = it_addition_details
      ct_consumab_details = it_consumab_details
      ct_parts_details    = it_parts_details
*     ct_return           = ET_RETURN    " Error Messages
  ).

  LOOP AT gt_header ASSIGNING <fs_header>.
    <fs_header>-gross_labour_nt  = <fs_header>-gross_labour.
    <fs_header>-gross_parts_nt   = <fs_header>-gross_parts.
    <fs_header>-oil_nt           = <fs_header>-oil.
    <fs_header>-paint_nt         = <fs_header>-paint.
    <fs_header>-sublet_nt        = <fs_header>-sublet.
    <fs_header>-bought_out_nt    = <fs_header>-bought_out.
    <fs_header>-addition_serv_nt = <fs_header>-addition_servic.
    <fs_header>-cconsumables_nt  = <fs_header>-cconsumables.
    <fs_header>-netpr_nt         = <fs_header>-netpr.
    <fs_header>-discount_nt      = <fs_header>-discount.
    <fs_header>-netwr_nt         = <fs_header>-netwr.
    <fs_header>-deposit_amt_nt   = <fs_header>-deposit_amount.
    <fs_header>-debuctibale_nt   = <fs_header>-debuctibale.
    <fs_header>-tax_nt           = <fs_header>-tax.
    <fs_header>-net_payable_nt   = <fs_header>-net_payable.
    <fs_header>-total_nt         = <fs_header>-total.
    <fs_header>-gross_labor2_nt  = <fs_header>-gross_labor2.
    <fs_header>-gross_parts2_nt  = <fs_header>-gross_parts2.
    <fs_header>-gross_consm2_nt  = <fs_header>-gross_consm2.
    <fs_header>-gross_addtn2_nt  = <fs_header>-gross_addtn2.
    <fs_header>-discount_perc = ( <fs_header>-discount_nt / <fs_header>-netpr_nt ) * 100.
    CONCATENATE <fs_header>-discount_perc '%' INTO <fs_header>-discount_perc .
    CONDENSE <fs_header>-meter_reading NO-GAPS.
  ENDLOOP.

  LOOP AT it_labor_details ASSIGNING <fs_labor_details>.
    <fs_labor_details>-unit_price_nt = <fs_labor_details>-unit_price.
    <fs_labor_details>-gross_price_nt = <fs_labor_details>-gross_price.
    CONCATENATE <fs_labor_details>-tax_rate '%' INTO <fs_labor_details>-tax_rate.
  ENDLOOP.

  LOOP AT it_addition_details ASSIGNING <fs_addition_details>.
    <fs_addition_details>-unit_price_nt = <fs_addition_details>-unit_price.
    <fs_addition_details>-gross_price_nt = <fs_addition_details>-gross_price.
    CONCATENATE <fs_addition_details>-tax_rate '%' INTO <fs_addition_details>-tax_rate.
  ENDLOOP.

  LOOP AT it_consumab_details ASSIGNING <fs_consumab_details>.
    <fs_consumab_details>-unit_price_nt = <fs_consumab_details>-unit_price.
    <fs_consumab_details>-gross_price_nt = <fs_consumab_details>-gross_price.
    CONCATENATE <fs_consumab_details>-tax_rate '%' INTO <fs_consumab_details>-tax_rate.
  ENDLOOP.

  LOOP AT it_parts_details ASSIGNING <fs_parts_details>.
    <fs_parts_details>-unit_price_nt = <fs_parts_details>-unit_price.
    <fs_parts_details>-gross_price_nt = <fs_parts_details>-gross_price.
    CONCATENATE <fs_parts_details>-tax_rate '%' INTO <fs_parts_details>-tax_rate.
  ENDLOOP.

  IF iv_arabic = abap_true.
    LOOP AT gt_header ASSIGNING <fs_header>.
      CALL FUNCTION 'YVSS_CONVERT_STRUC_NUM_TO_AR'
        CHANGING
          cs_struc = <fs_header>.
    ENDLOOP.

    LOOP AT it_labor_details ASSIGNING <fs_labor_details>.
      CALL FUNCTION 'YVSS_CONVERT_STRUC_NUM_TO_AR'
        CHANGING
          cs_struc = <fs_labor_details>.
    ENDLOOP.

    LOOP AT it_addition_details ASSIGNING <fs_addition_details>.
      CALL FUNCTION 'YVSS_CONVERT_STRUC_NUM_TO_AR'
        CHANGING
          cs_struc = <fs_addition_details>.
    ENDLOOP.

    LOOP AT it_consumab_details ASSIGNING <fs_consumab_details>.
      CALL FUNCTION 'YVSS_CONVERT_STRUC_NUM_TO_AR'
        CHANGING
          cs_struc = <fs_consumab_details>.
    ENDLOOP.

    LOOP AT it_parts_details ASSIGNING <fs_parts_details>.
      CALL FUNCTION 'YVSS_CONVERT_STRUC_NUM_TO_AR'
        CHANGING
          cs_struc = <fs_parts_details>.
    ENDLOOP.
  ENDIF.

  IF iv_sf_show = abap_true OR iv_print = abap_true.
    "calling the smartform

    IF ev_tax_perc IS INITIAL.
      ev_tax_perc = '0'.
    ENDIF.
    DATA: lv_tax_int TYPE int4.
    lv_tax_int = ev_tax_perc.
    ev_tax_perc = lv_tax_int.

*    ycl_dbm_jet_invoice_form_util=>display_sf(
*      EXPORTING
*        it_header    = gt_header
*        iT_LABOR_DETAILS = iT_LABOR_DETAILS
*        it_addition_details = it_addition_details
*        it_consumab_details = it_consumab_details
*        it_parts_details = it_parts_details
*        iv_print = iv_print
*        iv_proforma  = iv_proforma
*        iv_tax_perc = ev_tax_perc
*      CHANGING
*        ct_otf    = et_otf    " Smart Forms: Table OTF
*        ct_return = et_return  ).   " Error Messages

  ENDIF.

  et_header = gt_header.
  et_labor_details = it_labor_details.
  et_addition_details = it_addition_details.
  et_consumab_details = it_consumab_details.
  et_parts_details = it_parts_details.
*  ENDIF.
ENDFUNCTION.
