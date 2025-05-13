FUNCTION ZDBE_VMASS_PREPARE_QAIN.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_CALLED_IN_EXE) TYPE  BOOLEAN
*"     REFERENCE(INCOMING_ACTION_IS) TYPE  VLCC_CVLC03_PS OPTIONAL
*"  TABLES
*"      VLCAPO_ET TYPE  /DBE/VLC_AC_PO_T OPTIONAL
*"      VLCPORDER_ET STRUCTURE  VLCPORDER OPTIONAL
*"  CHANGING
*"     REFERENCE(VLCACTDATA_CS) TYPE  VLCACTDATA
*"  EXCEPTIONS
*"      PREPARE_FAILED
*"--------------------------------------------------------------------


  DATA:   lt_vlcguid TYPE TABLE OF vlcguid,
          ls_vlcapo TYPE /DBE/vlc_ac_po,
          lt_vlcapo TYPE STANDARD TABLE OF /DBE/vlc_ac_po,
          lt_vlcapo_pending TYPE STANDARD TABLE OF /DBE/vlc_ac_po,
          lt_vlcapo_cancle TYPE STANDARD TABLE OF /DBE/vlc_ac_po.


  DATA:  lfm1_ls        TYPE lfm1,
         lv_bukrs       TYPE bkpf-bukrs,
         lv_werks       TYPE werks.

  DATA: lv_vlcporder TYPE i,
        lv_vlcapo TYPE i,
        lv_index TYPE sy-tabix VALUE 1.

  DATA: lt_return           TYPE TABLE OF bapiret2,
        ls_po_item          TYPE bapiekpo,
        lt_po_items         TYPE TABLE OF bapiekpo.


  CONSTANTS:  lc_po_status_success  TYPE c VALUE 'S',
              lc_gr_status_success  TYPE c VALUE 'S',
              lc_inv_status_pending TYPE c VALUE 'P',
              lc_inv_status_cancle  TYPE c VALUE 'C'.

  FIELD-SYMBOLS: <fs_vlcactdata_actcs> TYPE vlcactdata_item_s,
                 <fs_vlcporder> TYPE vlcporder.


* Prepare data for creating purchase order

  LOOP AT vlcactdata_cs-actdata_item ASSIGNING <fs_vlcactdata_actcs>.
    APPEND <fs_vlcactdata_actcs>-vguid TO lt_vlcguid.
  ENDLOOP.

*  IF incoming_action_is-intrlk = abap_true.
*start Updating history tables

    CALL FUNCTION 'VELO14_READ_PORDERS_WITH_VGUID'
      EXPORTING
*        latest_iv        = abap_true
        no_xgore         = abap_false
        no_xiniv         = abap_true
        actdoctype_iv    = /DBE/if_vms_constants=>c_qapo
      TABLES
        vlcguid_it       = lt_vlcguid
        vlcporder_et     = vlcporder_et
      EXCEPTIONS
        no_data_received = 1
        nothing_found    = 2
        OTHERS           = 3.
*  ENDIF.
  IF sy-subrc <> 0 AND iv_called_in_exe EQ abap_true.
    RAISE prepare_failed.
  ENDIF.
* end Updating history tables

  CALL FUNCTION '/DBE/VMASS_ADC_READ_DB'
    EXPORTING
      iv_po_status    = lc_po_status_success
      iv_gr_status    = lc_gr_status_success
      iv_inv_status   = lc_inv_status_pending
    TABLES
      vlcguid_it      = lt_vlcguid
      vlcapo_et       = lt_vlcapo_pending
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.



  CALL FUNCTION '/DBE/VMASS_ADC_READ_DB'
    EXPORTING
      iv_po_status    = lc_po_status_success
      iv_gr_status    = lc_gr_status_success
      iv_inv_status   = lc_inv_status_cancle
    TABLES
      vlcguid_it      = lt_vlcguid
      vlcapo_et       = lt_vlcapo_cancle
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.

  APPEND LINES OF lt_vlcapo_pending TO lt_vlcapo.
  APPEND LINES OF lt_vlcapo_cancle TO lt_vlcapo.

  IF lt_vlcapo IS INITIAL.
    IF iv_called_in_exe EQ abap_true.
      RAISE prepare_failed.
    ENDIF.
  ENDIF.

**Cross check the data with history table
*  DESCRIBE TABLE lt_vlcapo LINES lv_vlcapo.
*  DESCRIBE TABLE vlcporder_et LINES lv_vlcporder.
*  IF lv_vlcapo NE lv_vlcporder.
*    RAISE prepare_failed.
*  ELSE.
*    SORT lt_vlcapo BY po_number po_item.
*    SORT vlcporder_et BY ebeln ebelp.
*    LOOP AT vlcporder_et ASSIGNING <fs_vlcporder>.
*      READ TABLE lt_vlcapo TRANSPORTING NO FIELDS WITH KEY vguid = <fs_vlcporder>-vguid po_number = <fs_vlcporder>-ebeln po_item = <fs_vlcporder>-ebelp.
*      IF sy-subrc <> 0.
*        RAISE prepare_failed.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
**Cross check the data with history table


  SORT lt_vlcapo BY creat_date.
  LOOP AT vlcactdata_cs-actdata_item ASSIGNING <fs_vlcactdata_actcs>.
    READ TABLE lt_vlcapo INTO ls_vlcapo WITH KEY vguid = <fs_vlcactdata_actcs>-vguid.
    IF sy-subrc EQ 0.

      <fs_vlcactdata_actcs>-po_number = ls_vlcapo-po_number.
      <fs_vlcactdata_actcs>-po_item = ls_vlcapo-po_item.
      <fs_vlcactdata_actcs>-item_amount = ls_vlcapo-cost.
      <fs_vlcactdata_actcs>-item_currency = ls_vlcapo-currency.
      <fs_vlcactdata_actcs>-/dbe/ext_service_lifnr = ls_vlcapo-vendor.
      <fs_vlcactdata_actcs>-/dbe/cost = ls_vlcapo-cost.
      <fs_vlcactdata_actcs>-item_currency = ls_vlcapo-currency.
      <fs_vlcactdata_actcs>-ref_doc = ls_vlcapo-gr_number.
      <fs_vlcactdata_actcs>-ref_doc_year = ls_vlcapo-gr_year.
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
      APPEND ls_vlcapo TO vlcapo_et.
    ENDIF.
  ENDLOOP.

*  IF vlcactdata_cs-ebeln IS INITIAL.
*    vlcactdata_cs-ebeln = ls_vlcapo-po_number.
*  ENDIF.

  IF vlcactdata_cs-ekorg IS INITIAL.
    vlcactdata_cs-ekorg = ls_vlcapo-purch_org.
  ENDIF.

  IF vlcactdata_cs-ekgrp IS INITIAL.
    vlcactdata_cs-ekgrp = ls_vlcapo-pur_group.
  ENDIF.

  IF vlcactdata_cs-pmnttrms IS INITIAL.
    vlcactdata_cs-pmnttrms = ls_vlcapo-pmnttrms.
  ENDIF.

  IF vlcactdata_cs-comp_code IS INITIAL.
    vlcactdata_cs-comp_code = ls_vlcapo-comp_code.
  ENDIF.

  IF vlcactdata_cs-kalsm IS INITIAL.
    vlcactdata_cs-kalsm = ls_vlcapo-kalsm.
  ENDIF.

  IF vlcactdata_cs-budat IS INITIAL.
    vlcactdata_cs-budat = sy-datum.
  ENDIF.

  IF vlcactdata_cs-bldat IS INITIAL.
    vlcactdata_cs-bldat = sy-datum.
  ENDIF.



ENDFUNCTION.
