FUNCTION ZDBE_VMASS_QAGR_PREPARE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_CALLED_BY_EXEC) TYPE  BOOLE_D
*"  TABLES
*"      VLCAPO_ET TYPE  /DBE/VLC_AC_PO_T OPTIONAL
*"      VLCPORDER_ET STRUCTURE  VLCPORDER OPTIONAL
*"  CHANGING
*"     REFERENCE(VLCACTDATA_CS) TYPE  VLCACTDATA
*"  EXCEPTIONS
*"      ACTION_PREPARE_NOT_PERFORMED
*"--------------------------------------------------------------------
  DATA :lt_vlc_adc_cancel TYPE TABLE OF /DBE/vlc_ac_po,
        lt_vlc_adc_cancel2 TYPE TABLE OF /DBE/vlc_ac_po,
        lt_vlc_adc_pending TYPE TABLE OF /DBE/vlc_ac_po,
        lt_vlc_adc_pending2 TYPE TABLE OF /DBE/vlc_ac_po,
        lt_vlc_adc TYPE TABLE OF /DBE/vlc_ac_po.

  DATA : ls_vlc_adc TYPE  /DBE/vlc_ac_po.
  DATA : ls_vlcguid TYPE vlcguid.
  DATA : lt_vlcguid TYPE TABLE OF vlcguid.

  DATA: lv_vlcporder TYPE i,
        lv_vlc_adc TYPE i,
        lv_index TYPE sy-tabix VALUE 1.

  DATA: lt_return           TYPE TABLE OF bapiret2,
        ls_po_item          TYPE bapiekpo,
        lt_po_items         TYPE TABLE OF bapiekpo.

  CONSTANTS:
          lc_po_status_success  TYPE c VALUE 'S',
          lc_gr_status_pending  TYPE c VALUE 'P',
          lc_inv_status_pending  TYPE c VALUE 'P',
          lc_gr_status_cancel   TYPE c VALUE 'C',
          lc_inv_status_initial TYPE c VALUE 'N',
          lc_inv_status_cancel TYPE c VALUE 'C'.

  FIELD-SYMBOLS : <ls_actdata_item> LIKE LINE OF vlcactdata_cs-actdata_item,
                 <fs_vlcporder> TYPE vlcporder.

  LOOP AT vlcactdata_cs-actdata_item ASSIGNING <ls_actdata_item> .
    ls_vlcguid-vguid = <ls_actdata_item>-vguid.
    APPEND ls_vlcguid TO lt_vlcguid.
  ENDLOOP.

*start Updating history tables
  CALL FUNCTION 'VELO14_READ_PORDERS_WITH_VGUID'
    EXPORTING
*     latest_iv        = abap_true
      actdoctype_iv    = /DBE/if_vms_constants=>c_qapo
      no_xgore         = abap_true
      no_xiniv         = abap_true
    TABLES
      vlcguid_it       = lt_vlcguid
      vlcporder_et     = vlcporder_et
    EXCEPTIONS
      no_data_received = 1
      nothing_found    = 2
      OTHERS           = 3.

  IF sy-subrc <> 0 AND iv_called_by_exec = abap_true.
    RAISE action_prepare_not_performed.
  ENDIF.
* end Updating history tables



  CALL FUNCTION '/DBE/VMASS_ADC_READ_DB'
    EXPORTING
      iv_po_status    = lc_po_status_success
      iv_gr_status    = lc_gr_status_pending
      iv_inv_status   = lc_inv_status_initial
    TABLES
      vlcguid_it      = lt_vlcguid
      vlcapo_et       = lt_vlc_adc_pending
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.

  CALL FUNCTION '/DBE/VMASS_ADC_READ_DB'
    EXPORTING
      iv_po_status    = lc_po_status_success
      iv_gr_status    = lc_gr_status_cancel
      iv_inv_status   = lc_inv_status_cancel
    TABLES
      vlcguid_it      = lt_vlcguid
      vlcapo_et       = lt_vlc_adc_cancel
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.

  CALL FUNCTION '/DBE/VMASS_ADC_READ_DB'
    EXPORTING
      iv_po_status    = lc_po_status_success
      iv_gr_status    = lc_gr_status_cancel
      iv_inv_status   = lc_inv_status_pending
    TABLES
      vlcguid_it      = lt_vlcguid
      vlcapo_et       = lt_vlc_adc_pending2
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.

  CALL FUNCTION '/DBE/VMASS_ADC_READ_DB'        "N:2767191
    EXPORTING
      iv_po_status    = lc_po_status_success
      iv_gr_status    = lc_gr_status_cancel
      iv_inv_status   = lc_inv_status_initial
    TABLES
      vlcguid_it      = lt_vlcguid
      vlcapo_et       = lt_vlc_adc_cancel2
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.


  APPEND LINES OF lt_vlc_adc_pending2 TO lt_vlc_adc.
  APPEND LINES OF lt_vlc_adc_pending TO lt_vlc_adc.
  APPEND LINES OF lt_vlc_adc_cancel TO lt_vlc_adc.
  APPEND LINES OF lt_vlc_adc_cancel2 TO lt_vlc_adc.

  IF lt_vlc_adc IS INITIAL  AND iv_called_by_exec = abap_true.
    RAISE action_prepare_not_performed.
  ENDIF.


  IF vlcactdata_cs-bwart IS INITIAL.
    vlcactdata_cs-bwart = '101'.
  ENDIF.
  IF vlcactdata_cs-budat IS INITIAL.
    vlcactdata_cs-budat = sy-datum.
  ENDIF.
  IF vlcactdata_cs-bldat IS INITIAL.
    vlcactdata_cs-bldat = sy-datum.
  ENDIF.

**Cross check the data with history table
*  DESCRIBE TABLE lt_vlc_adc LINES lv_vlc_adc.
*  DESCRIBE TABLE vlcporder_et LINES lv_vlcporder.
*  IF lv_vlc_adc NE lv_vlcporder.
*    RAISE action_prepare_not_performed.
*  ELSE.
*    SORT lt_vlc_adc BY po_number po_item.
*    SORT vlcporder_et BY ebeln ebelp.
*    LOOP AT vlcporder_et ASSIGNING <fs_vlcporder>.
*      READ TABLE lt_vlc_adc TRANSPORTING NO FIELDS WITH KEY vguid = <fs_vlcporder>-vguid po_number = <fs_vlcporder>-ebeln po_item = <fs_vlcporder>-ebelp.
*      IF sy-subrc <> 0.
*        RAISE action_prepare_not_performed.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
**Cross check the data with history table



  LOOP AT vlcactdata_cs-actdata_item ASSIGNING <ls_actdata_item> .
    READ TABLE lt_vlc_adc INTO ls_vlc_adc WITH KEY vguid = <ls_actdata_item>-vguid.
    IF sy-subrc = 0 .
      <ls_actdata_item>-po_number              = ls_vlc_adc-po_number.
      <ls_actdata_item>-po_item                = ls_vlc_adc-po_item.
*      <ls_actdata_item>-ekgrp                 = ls_vlc_adc-pur_group.
      <ls_actdata_item>-/dbe/ext_service_lifnr = ls_vlc_adc-vendor.
      <ls_actdata_item>-/dbe/ext_service_type  = ls_vlc_adc-service_type.
      <ls_actdata_item>-/dbe/ext_service_matnr = ls_vlc_adc-service_mat.
      <ls_actdata_item>-/dbe/cost              = ls_vlc_adc-cost.
      <ls_actdata_item>-item_currency          = ls_vlc_adc-currency.
      "The actual net price should be read from PO                          "N:2739899
      CALL FUNCTION 'BAPI_PO_GETDETAIL' "#EC CI_USAGE_OK[2438131]
                                        "#EC CI_USAGE_OK[1803189]
        EXPORTING
          purchaseorder           = ls_vlc_adc-po_number
        TABLES
          po_items                = lt_po_items
          return                  = lt_return.
      IF sy-subrc IS INITIAL.
        READ TABLE lt_po_items INTO ls_po_item
          WITH KEY po_number = ls_vlc_adc-po_number
                   po_item = ls_vlc_adc-po_item.
        IF sy-subrc IS INITIAL.
          <ls_actdata_item>-/dbe/cost = ls_po_item-net_price.
        ENDIF.
      ENDIF.

      APPEND ls_vlc_adc TO vlcapo_et.
    ENDIF.
  ENDLOOP.


  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            RAISING action_prepare_not_performed.
  ENDIF.

ENDFUNCTION.
