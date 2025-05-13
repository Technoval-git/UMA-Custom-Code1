*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF23 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_TRANSFER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_transfer_data .

  DATA: lo_veh_buf        TYPE REF TO /DBE/cl_veh_buf,
        lo_vehicle        TYPE REF TO /DBE/cl_veh_dbmvehicle,
        lt_bob            TYPE /DBE/t_veh_bob,
        ls_bob            TYPE /DBE/s_veh_bob,
        lr_data           TYPE REF TO data,
        lr_item_data      TYPE REF TO data,
        ls_ac_post        TYPE /DBE/vmass_adc,
        lr_vlcactdata_head      TYPE REF TO vlcactdata_head_s,
        lr_vlcactdata_item      TYPE REF TO vlcactdata_item_s,
        ls_invoice_info         TYPE tty_invoice_info.

* Header data
  MOVE-CORRESPONDING vlcactdata_head_s TO gs_vlcactdata_head.
* Item data
  MOVE-CORRESPONDING vlcactdata_item_s TO gs_vlcactdata_item.

* Move screen IObject single structures to the buffer
  PERFORM iobj_single_move USING gc_1.
* Get Buffer instance
  lo_veh_buf = /DBE/cl_veh_buf=>get_instance( ).
  TRY.
    CALL METHOD lo_veh_buf->get_all
      RECEIVING
        rt_bob = lt_bob.
  ENDTRY.

  LOOP AT lt_bob INTO ls_bob .
    lo_vehicle ?= ls_bob-bobref.
    TRY.
        lr_data = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
      CATCH /DBE/cx_veh_layer_not_found .
    ENDTRY.
    IF lr_data IS BOUND.
      lr_vlcactdata_head ?= lr_data.
      IF gv_action = /DBE/if_vms_constants=>c_qgcb OR gv_action = /DBE/if_vms_constants=>c_qirb.
        MOVE vlcactdata_head_s-pstng_date TO  lr_vlcactdata_head->*-pstng_date.
        MOVE vlcactdata_head_s-budat TO  lr_vlcactdata_head->*-budat.
        MOVE vlcactdata_head_s-revreason TO  lr_vlcactdata_head->*-revreason.
      ELSE.
        MOVE-CORRESPONDING vlcactdata_head_s TO  lr_vlcactdata_head->*.
      ENDIF.
      IF gv_action NE /DBE/if_vms_constants=>c_qinb.
        "Netprice should be blank at header level while creating invoice
        MOVE vlcactdata_item_s-netpr TO lr_vlcactdata_head->*-netpr.
*      ELSE.
*        CLEAR  lr_vlcactdata_head->*-netpr.
      ENDIF.
    ENDIF.
    TRY.
        lr_item_data  = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
      CATCH /DBE/cx_veh_layer_not_found .
    ENDTRY.
    IF lr_item_data IS BOUND.
      lr_vlcactdata_item ?= lr_item_data.
*       MOVE-CORRESPONDING vlcactdata_item_s TO  lr_vlcactdata_head->*.
*        APPEND lr_vlcactdata_item->* TO gt_vlcactdata_item.
    ENDIF.

*   Store vehicle net price for incoming invoice process            "N.2051187
    READ TABLE gt_ininvoice_info INTO ls_invoice_info
      WITH KEY vhcle = lr_vlcactdata_item->*-vhcle.
    IF sy-subrc = 0.
      lr_vlcactdata_item->*-item_amount   = ls_invoice_info-netpr.
      lr_vlcactdata_item->*-item_currency = ls_invoice_info-currency.
    ENDIF.

*    LOOP AT gt_ac_post INTO ls_ac_post.
*      IF lr_vlcactdata_item->*-vguid  =  ls_ac_post-vguid.
*        lr_vlcactdata_item->*-cost    = ls_ac_post-cost.
*      ENDIF.
**        MOVE vlcactdata_item_s-cost TO lr_vlcactdata_item->*-cost.
**        READ TABLE gt_ac_post INTO ls_ac_post
**              WITH KEY vguid = ls_bob-guid.
**        lr_vlcactdata_item->*-cost = ls_ac_post-cost.
*    ENDLOOP.

* for PO of same delivery date
    IF has_same_delv_date EQ abap_true ."AND lr_vlcactdata_item->*-vguid  = gs_vlcactdata_item-vguid.
*      lr_vlcactdata_item->*-eindt_changed = gs_vlcactdata_item-eindt_changed.
      lr_vlcactdata_item->*-eindt_changed = vlcactdata_head_s-eindt.
      lr_vlcactdata_item->*-netpr = vlcactdata_item_s-netpr.
    ENDIF.

*for PO of diff delivery date
*    IF has_diff_delv_date EQ abap_true.
*      LOOP AT lt_po_item_diff_delv INTO ls_po_item_diff_delv.
*        IF lr_vlcactdata_item->*-vguid  =  ls_po_item_diff_delv-vlc_guid.
**           lr_vlcactdata_item->*-netpr = ls_po_item_diff_delv-netpr.
*          lr_vlcactdata_item->*-eindt_changed = ls_po_item_diff_delv-eindt.
*        ENDIF.
*      ENDLOOP.
**      CLEAR  has_diff_delv_date.
*    ENDIF.

  ENDLOOP.

* Set data in Vehicle buffer
  TRY.
      CALL METHOD lo_veh_buf->set_all.
    CATCH /DBE/cx_veh_error_occured .
    CATCH cx_static_check.
  ENDTRY.

ENDFORM.                    " F_TRANSFER_DATA
