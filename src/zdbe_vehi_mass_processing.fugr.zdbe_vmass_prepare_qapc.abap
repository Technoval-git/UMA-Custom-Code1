FUNCTION ZDBE_VMASS_PREPARE_QAPC.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_INCOMING_ACTION) TYPE  VLCC_CVLC03_PS OPTIONAL
*"  TABLES
*"      VLCAPO_ET TYPE  /DBE/VLC_AC_PO_T OPTIONAL
*"  CHANGING
*"     REFERENCE(VLCACTDATA_CS) TYPE  VLCACTDATA
*"  EXCEPTIONS
*"      PREPARE_FAILED
*"      OTHERS
*"--------------------------------------------------------------------

  "Data Declaration
  DATA:   lt_vlcguid    TYPE TABLE OF vlcguid,
          ls_vlcapo     TYPE /DBE/vlc_ac_po,
          lt_vlcapo     TYPE STANDARD TABLE OF /DBE/vlc_ac_po,
          lt_vlcapo_pending TYPE STANDARD TABLE OF /DBE/vlc_ac_po,
          lt_vlcapo_cancle  TYPE STANDARD TABLE OF /DBE/vlc_ac_po,
          lt_vlcapo_initial TYPE STANDARD TABLE OF /DBE/vlc_ac_po,
          lv_first_flag     TYPE abap_bool,
          lt_vlcactdata_act TYPE vlcactdata_item_t,
          ls_vlcactdata_act TYPE vlcactdata_item_s.
  DATA:  lc_po_status_success  TYPE c VALUE 'S',
         lc_gr_status_pending   TYPE c VALUE 'P',
         lc_gr_status_cancle   TYPE c VALUE 'C',
         lc_inv_status_cancle  TYPE c VALUE 'C',
         lc_inv_status_initial  TYPE c VALUE 'N'.

  DATA:   lt_return           TYPE TABLE OF bapiret2,           "N:2753894
          ls_po_item          TYPE bapiekpo,
          lt_po_items         TYPE TABLE OF bapiekpo.

  FIELD-SYMBOLS: <fs_vlcactdata_actcs> TYPE vlcactdata_item_s.

  CLEAR : lt_vlcapo, lt_vlcactdata_act, lt_vlcapo_cancle, lt_vlcapo_pending, lt_vlcapo_initial, lt_vlcguid.
  "Prepare data for creating purchase order
  LOOP AT vlcactdata_cs-actdata_item ASSIGNING <fs_vlcactdata_actcs>.
    APPEND <fs_vlcactdata_actcs>-vguid TO lt_vlcguid.
  ENDLOOP.

  "Get all the vehilces for cancelation based on correct status and PO
  CALL FUNCTION '/DBE/VMASS_ADC_READ_DB'
    EXPORTING
      iv_po_status    = lc_po_status_success
      iv_gr_status    = lc_gr_status_cancle
      iv_inv_status   = lc_inv_status_cancle
    TABLES
      vlcguid_it      = lt_vlcguid
      vlcapo_et       = lt_vlcapo_cancle
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    "nothing to do here
  ENDIF.

  CALL FUNCTION '/DBE/VMASS_ADC_READ_DB'
    EXPORTING
      iv_po_status    = lc_po_status_success
      iv_gr_status    = lc_gr_status_pending
      iv_inv_status   = lc_inv_status_initial
    TABLES
      vlcguid_it      = lt_vlcguid
      vlcapo_et       = lt_vlcapo_pending
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    "nothing to do here
  ENDIF.

  CALL FUNCTION '/DBE/VMASS_ADC_READ_DB'            "N:2767191
    EXPORTING
      iv_po_status    = lc_po_status_success
      iv_gr_status    = lc_gr_status_cancle
      iv_inv_status   = lc_inv_status_initial
    TABLES
      vlcguid_it      = lt_vlcguid
      vlcapo_et       = lt_vlcapo_initial
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    "nothing to do here
  ENDIF.

  APPEND LINES OF lt_vlcapo_pending TO lt_vlcapo.
  APPEND LINES OF lt_vlcapo_cancle TO lt_vlcapo.
  APPEND LINES OF lt_vlcapo_initial TO lt_vlcapo.

  IF lt_vlcapo IS INITIAL.
    IF is_incoming_action-intrlk = abap_false.
      RAISE prepare_failed.
    ELSE.
      EXIT.
    ENDIF.

  ENDIF.

  SORT lt_vlcapo BY po_number creat_date.

  LOOP AT vlcactdata_cs-actdata_item ASSIGNING <fs_vlcactdata_actcs>.
    lv_first_flag = abap_true.
    LOOP AT lt_vlcapo INTO ls_vlcapo WHERE vguid = <fs_vlcactdata_actcs>-vguid.
      IF lv_first_flag EQ abap_true.
        <fs_vlcactdata_actcs>-po_number              = ls_vlcapo-po_number.
        <fs_vlcactdata_actcs>-po_item                = ls_vlcapo-po_item.
        <fs_vlcactdata_actcs>-item_amount            = ls_vlcapo-cost.
        <fs_vlcactdata_actcs>-item_currency          = ls_vlcapo-currency.
        <fs_vlcactdata_actcs>-/dbe/ext_service_type  = ls_vlcapo-service_type.
        <fs_vlcactdata_actcs>-/dbe/serv_tax_code     = ls_vlcapo-tax_code.
        <fs_vlcactdata_actcs>-/dbe/ext_service_lifnr = ls_vlcapo-vendor.
        <fs_vlcactdata_actcs>-/dbe/cost              = ls_vlcapo-cost.
        <fs_vlcactdata_actcs>-ref_doc                = ls_vlcapo-gr_number.
        <fs_vlcactdata_actcs>-ref_doc_year           = ls_vlcapo-gr_year.

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
          <fs_vlcactdata_actcs>-/dbe/cost = ls_po_item-net_price.
        ENDIF.
      ENDIF.

        lv_first_flag = abap_false.
      ELSE.
        ls_vlcactdata_act                        = <fs_vlcactdata_actcs>.
        ls_vlcactdata_act-po_number              = ls_vlcapo-po_number.
        ls_vlcactdata_act-po_item                = ls_vlcapo-po_item.
        ls_vlcactdata_act-item_amount            = ls_vlcapo-cost.
        ls_vlcactdata_act-item_currency          = ls_vlcapo-currency.
        ls_vlcactdata_act-/dbe/ext_service_type  = ls_vlcapo-service_type.
        ls_vlcactdata_act-/dbe/serv_tax_code     = ls_vlcapo-tax_code.
        ls_vlcactdata_act-/dbe/ext_service_lifnr = ls_vlcapo-vendor.
        ls_vlcactdata_act-/dbe/cost              = ls_vlcapo-cost.
        ls_vlcactdata_act-ref_doc                = ls_vlcapo-gr_number.
        ls_vlcactdata_act-ref_doc_year           = ls_vlcapo-gr_year.
        APPEND ls_vlcactdata_act TO lt_vlcactdata_act.
      ENDIF.
      APPEND ls_vlcapo TO vlcapo_et.
    ENDLOOP.
  ENDLOOP.

*APPEND LINES OF lt_vlcactdata_act TO vlcactdata_cs-actdata_item.
  LOOP AT lt_vlcactdata_act INTO ls_vlcactdata_act.
    READ TABLE vlcactdata_cs-actdata_item TRANSPORTING NO FIELDS
      WITH KEY po_number  = ls_vlcactdata_act-po_number
               vguid      = ls_vlcactdata_act-vguid.
    IF sy-subrc <> 0.
      APPEND ls_vlcactdata_act TO vlcactdata_cs-actdata_item.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
