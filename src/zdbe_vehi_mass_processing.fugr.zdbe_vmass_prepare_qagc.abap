FUNCTION ZDBE_VMASS_PREPARE_QAGC.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(INCOMING_ACTION_IS) TYPE  VLCC_CVLC03_PS
*"     REFERENCE(ELEMENTARY_ACTION_IS) TYPE  VLCC_CVLC03_PS
*"  TABLES
*"      ET_VLCVEH_QAGC TYPE  /DBE/VLC_AC_PO_T OPTIONAL
*"  CHANGING
*"     REFERENCE(VLCACTDATA_CS) TYPE  VLCACTDATA
*"  EXCEPTIONS
*"      PREPARE_FAILED
*"--------------------------------------------------------------------
  CONSTANTS:  lc_po_status_success  TYPE c VALUE 'S',
              lc_gr_status_success  TYPE c VALUE 'S',
              lc_inv_status_pending TYPE c VALUE 'P',
              lc_inv_status_cancled TYPE c VALUE 'C'.

  DATA:   lt_vlcguid            TYPE TABLE OF vlcguid,
          ls_vlcapo             TYPE /DBE/vlc_ac_po,
          lt_vlcadc_veh         TYPE STANDARD TABLE OF /DBE/vlc_ac_po,
          lt_adc_status         TYPE /DBE/vlc_adc_status_t,
          ls_adc_status         TYPE /DBE/vlc_adc_status_s,
          ls_lfm1               TYPE lfm1,
          lv_bukrs              TYPE bkpf-bukrs,
          lv_werks              TYPE werks,
          lv_first_flag         TYPE abap_bool,
          lt_vlcactdata_act     TYPE vlcactdata_item_t,
          ls_vlcactdata_act     TYPE vlcactdata_item_s.

 DATA:    lt_return           TYPE TABLE OF bapiret2,           "N:2739899
          ls_po_item          TYPE bapiekpo,
          lt_po_items         TYPE TABLE OF bapiekpo.

  FIELD-SYMBOLS:
          <fs_vlcveh>           TYPE /DBE/vlc_ac_po ,
          <fs_vlcactdata_actcs> TYPE vlcactdata_item_s.

  CLEAR : lt_vlcguid , lt_adc_status ,lt_vlcadc_veh,lt_vlcactdata_act,et_vlcveh_qagc.
* Prepare data for creating purchase order
  LOOP AT vlcactdata_cs-actdata_item ASSIGNING <fs_vlcactdata_actcs>.
    APPEND <fs_vlcactdata_actcs>-vguid TO lt_vlcguid.
  ENDLOOP.

  SORT lt_vlcguid BY vguid.
  DELETE ADJACENT DUPLICATES FROM lt_vlcguid.

  ls_adc_status-po_status = lc_po_status_success.
  ls_adc_status-gr_status = lc_gr_status_success.
  ls_adc_status-inv_status = lc_inv_status_pending.
  APPEND ls_adc_status TO lt_adc_status.

  ls_adc_status-po_status = lc_po_status_success.
  ls_adc_status-gr_status = lc_gr_status_success.
  ls_adc_status-inv_status = lc_inv_status_cancled.
  APPEND ls_adc_status TO lt_adc_status.

* Read aditional cost table
  CALL FUNCTION '/DBE/VMASS_ADC_READ_DB'
    EXPORTING
      it_adc_status   = lt_adc_status
    TABLES
      vlcguid_it      = lt_vlcguid
      vlcapo_et       = lt_vlcadc_veh
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.

  IF lt_vlcadc_veh IS INITIAL.
    IF incoming_action_is-intrlk = abap_false.
      RAISE prepare_failed.
    ELSE.
      EXIT.
    ENDIF.
  ENDIF.

  SORT lt_vlcadc_veh BY po_number creat_date.

  LOOP AT vlcactdata_cs-actdata_item ASSIGNING <fs_vlcactdata_actcs>.
    lv_first_flag = abap_true.
    LOOP AT lt_vlcadc_veh INTO ls_vlcapo WHERE vguid = <fs_vlcactdata_actcs>-vguid.
      IF lv_first_flag EQ abap_true.
        <fs_vlcactdata_actcs>-po_number              = ls_vlcapo-po_number.
        <fs_vlcactdata_actcs>-po_item                = ls_vlcapo-po_item.
        <fs_vlcactdata_actcs>-item_amount            = ls_vlcapo-cost.
        <fs_vlcactdata_actcs>-item_currency          = ls_vlcapo-currency.
        <fs_vlcactdata_actcs>-/dbe/serv_tax_code     = ls_vlcapo-tax_code.
        <fs_vlcactdata_actcs>-/dbe/ext_service_lifnr = ls_vlcapo-vendor.
        <fs_vlcactdata_actcs>-/dbe/cost              = ls_vlcapo-cost.
        <fs_vlcactdata_actcs>-ref_doc                = ls_vlcapo-gr_number.
        <fs_vlcactdata_actcs>-ref_doc_year           = ls_vlcapo-gr_year.
        vlcactdata_cs-mat_doc           = ls_vlcapo-gr_number.
        vlcactdata_cs-doc_year          = ls_vlcapo-gr_year.
        vlcactdata_cs-werks              = ls_vlcapo-plant.

   "The actual net price should be read from PO                          "N:2739899
      CALL FUNCTION 'BAPI_PO_GETDETAIL' "#EC CI_USAGE_OK[2438131]
                                        "#EC CI_USAGE_OK[1803189]
        EXPORTING
          purchaseorder               = ls_vlcapo-po_number
        TABLES
          po_items                    = lt_po_items
          return                      = lt_return.
      IF sy-subrc IS INITIAL.
        READ TABLE lt_po_items INTO ls_po_item
          WITH KEY po_number = ls_vlcapo-po_number
                   po_item   = ls_vlcapo-po_item.
        IF sy-subrc IS INITIAL.
          <fs_vlcactdata_actcs>-item_amount = ls_po_item-net_price. "#EC CI_FLDEXT_OK[2610650]
          <fs_vlcactdata_actcs>-/dbe/cost   = ls_po_item-net_price.
        ENDIF.
      ENDIF.
        lv_first_flag = abap_false.
      ELSE.
        ls_vlcactdata_act                        = <fs_vlcactdata_actcs>.
        ls_vlcactdata_act-po_number              = ls_vlcapo-po_number.
        ls_vlcactdata_act-po_item                = ls_vlcapo-po_item.
        ls_vlcactdata_act-item_amount            = ls_vlcapo-cost.
        ls_vlcactdata_act-item_currency          = ls_vlcapo-currency.
        ls_vlcactdata_act-/dbe/serv_tax_code     = ls_vlcapo-tax_code.
        ls_vlcactdata_act-/dbe/ext_service_lifnr = ls_vlcapo-vendor.
        ls_vlcactdata_act-/dbe/cost              = ls_vlcapo-cost.
        ls_vlcactdata_act-ref_doc                = ls_vlcapo-gr_number.
        ls_vlcactdata_act-ref_doc_year           = ls_vlcapo-gr_year.
        APPEND ls_vlcactdata_act TO lt_vlcactdata_act.
      ENDIF.
      APPEND ls_vlcapo TO et_vlcveh_qagc.

    ENDLOOP.
  ENDLOOP.

  LOOP AT lt_vlcactdata_act INTO ls_vlcactdata_act.
    READ TABLE vlcactdata_cs-actdata_item TRANSPORTING NO FIELDS
      WITH KEY po_number  = ls_vlcactdata_act-po_number
               vguid      = ls_vlcactdata_act-vguid.
    IF sy-subrc <> 0.
      APPEND ls_vlcactdata_act TO vlcactdata_cs-actdata_item.
    ENDIF.
  ENDLOOP.

* Get Payment terms, company code and TAX Procedure
  vlcactdata_cs-ekorg = ls_vlcapo-purch_org.
  vlcactdata_cs-ekgrp = ls_vlcapo-pur_group.

  CALL FUNCTION 'LFM1_SINGLE_READ'
    EXPORTING
      i_lifnr   = vlcactdata_cs-lifnr
      i_ekorg   = vlcactdata_cs-ekorg
    IMPORTING
      o_lfm1    = ls_lfm1
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc EQ 0.
    vlcactdata_cs-pmnttrms = ls_lfm1-zterm.
  ENDIF.

* Determine the company code which the plant is assigned to
  lv_werks = vlcactdata_cs-werks.
  CALL FUNCTION 'VELO25_DETERM_BUKRS_FROM_WERKS'
    EXPORTING
      werks_iv  = lv_werks
    IMPORTING
      bukrs_ev  = lv_bukrs
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    vlcactdata_cs-comp_code = lv_bukrs.
  ENDIF.

  IF lv_bukrs IS NOT INITIAL.
* Find the tax spreadsheet assigned to the company code
    CALL FUNCTION 'FIND_TAX_SPREADSHEET'
      EXPORTING
        buchungskreis = lv_bukrs
      IMPORTING
        schema        = vlcactdata_cs-kalsm
      EXCEPTIONS
        not_found     = 1
        OTHERS        = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

  LOOP AT et_vlcveh_qagc ASSIGNING <fs_vlcveh>.
    <fs_vlcveh>-comp_code = vlcactdata_cs-comp_code.
    <fs_vlcveh>-pmnttrms = vlcactdata_cs-pmnttrms.
    <fs_vlcveh>-kalsm = vlcactdata_cs-kalsm.
  ENDLOOP.

ENDFUNCTION.
