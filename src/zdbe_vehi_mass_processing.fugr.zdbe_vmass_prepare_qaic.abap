FUNCTION ZDBE_VMASS_PREPARE_QAIC.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(INCOMING_ACTION_IS) TYPE  VLCC_CVLC03_PS
*"     REFERENCE(ELEMENTARY_ACTION_IS) TYPE  VLCC_CVLC03_PS
*"  TABLES
*"      ET_ADCVEH_INV TYPE  /DBE/VLC_AC_PO_T OPTIONAL
*"  CHANGING
*"     REFERENCE(VLCACTDATA_CS) TYPE  VLCACTDATA
*"  EXCEPTIONS
*"      PREPARE_FAILED
*"--------------------------------------------------------------------
  CONSTANTS:  lc_po_status_success  TYPE c VALUE 'S',
              lc_gr_status_success  TYPE c VALUE 'S',
              lc_inv_status_success TYPE c VALUE 'S'.
  DATA :
           lv_first_flag TYPE abap_bool,
           lt_vlcactdata_act TYPE vlcactdata_item_t,
           ls_vlcactdata_act TYPE vlcactdata_item_s.

  DATA:   lt_vlcguid            TYPE TABLE OF vlcguid,
          ls_vlcapo             TYPE /DBE/vlc_ac_po,
          lt_vlcadc_veh         TYPE STANDARD TABLE OF /DBE/vlc_ac_po,
          lt_vlcadc_veh_pending TYPE STANDARD TABLE OF /DBE/vlc_ac_po,
          lt_vlcadc_veh_cancle  TYPE STANDARD TABLE OF /DBE/vlc_ac_po.

  DATA:   lt_return           TYPE TABLE OF bapiret2,           "N:2753894
          ls_po_item          TYPE bapiekpo,
          lt_po_items         TYPE TABLE OF bapiekpo.

  DATA:   ls_lfm1               TYPE lfm1,
          lv_bukrs              TYPE bkpf-bukrs,
          lv_werks              TYPE werks.
  FIELD-SYMBOLS:
                 <fs_vlcveh>    TYPE /DBE/vlc_ac_po ,
                 <fs_vlcactdata_actcs> TYPE vlcactdata_item_s.

clear : lt_vlcguid, lt_vlcactdata_act, lt_vlcadc_veh, lt_vlcadc_veh_cancle, lt_vlcadc_veh_pending.

* Prepare data for creating purchase order
  LOOP AT vlcactdata_cs-actdata_item ASSIGNING <fs_vlcactdata_actcs>.
    APPEND <fs_vlcactdata_actcs>-vguid TO lt_vlcguid.
  ENDLOOP.

* Read aditional cost table
  CALL FUNCTION '/DBE/VMASS_ADC_READ_DB'
    EXPORTING
      iv_po_status    = lc_po_status_success
      iv_gr_status    = lc_gr_status_success
      iv_inv_status   = lc_inv_status_success
    TABLES
      vlcguid_it      = lt_vlcguid
      vlcapo_et       = lt_vlcadc_veh_pending
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.

  IF sy-subrc <> 0.
    RAISE prepare_failed.
  ENDIF.

  APPEND LINES OF lt_vlcadc_veh_pending TO lt_vlcadc_veh.
  SORT lt_vlcadc_veh BY inv_number po_number creat_date.

*  lt_vlcactdata_act = vlcactdata_cs-actdata_item.

  LOOP AT vlcactdata_cs-actdata_item ASSIGNING <fs_vlcactdata_actcs>.
    lv_first_flag = abap_true.
    LOOP AT lt_vlcadc_veh INTO ls_vlcapo WHERE vguid = <fs_vlcactdata_actcs>-vguid.
*    READ TABLE lt_vlcadc_veh INTO ls_vlcapo WITH KEY vguid = <fs_vlcactdata_actcs>-vguid.
*    IF sy-subrc EQ 0.
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

        vlcactdata_cs-invoicedocnumber               = ls_vlcapo-inv_number.
        vlcactdata_cs-fiscalyear                     = ls_vlcapo-inv_year.
        vlcactdata_cs-werks                          = ls_vlcapo-plant.
*      <fs_vlcactdata_actcs>-ref_doc_year      = ls_vlcapo-inv_tstmp.
        <fs_vlcactdata_actcs>-/dbe/fi_belnr          = ls_vlcapo-inv_number.
        <fs_vlcactdata_actcs>-/dbe/fi_gjahr          = ls_vlcapo-inv_year.

        <fs_vlcactdata_actcs>-budat          = ls_vlcapo-budat.

      "The actual net price should be read from PO                          "N:2753894
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
*      ls_vlcactdata_act-ref_doc_year           = ls_vlcapo-inv_tstmp.
        ls_vlcactdata_act-/dbe/fi_belnr          = ls_vlcapo-inv_number.
        ls_vlcactdata_act-/dbe/fi_gjahr          = ls_vlcapo-inv_year.
        ls_vlcactdata_act-werks                  = ls_vlcapo-plant.
        APPEND ls_vlcactdata_act TO lt_vlcactdata_act.
      ENDIF.
      APPEND ls_vlcapo TO et_adcveh_inv.
*    ENDIF.
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
********* Start : Get Payment terms, company code and TAX Procedure************
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
********* End : Get Payment terms, company code and TAX Procedure************

  LOOP AT et_adcveh_inv ASSIGNING <fs_vlcveh>.
    <fs_vlcveh>-comp_code = vlcactdata_cs-comp_code.
    <fs_vlcveh>-pmnttrms = vlcactdata_cs-pmnttrms.
    <fs_vlcveh>-kalsm = vlcactdata_cs-kalsm.
  ENDLOOP.

ENDFUNCTION.
