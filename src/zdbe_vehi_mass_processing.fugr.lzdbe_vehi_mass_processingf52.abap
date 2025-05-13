*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF52 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PREPARE_PO_DEL_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_po_del_info .
  DATA :     lt_bob               TYPE /DBE/t_veh_bobget ,
             ls_bob               TYPE /DBE/s_veh_bobget ,
             lt_bob_all           TYPE /DBE/t_veh_bob,"/DBE/t_veh_bobget,
             ls_bob_all           TYPE /DBE/s_veh_bob,
             lt_bob_details       TYPE /DBE/t_veh_bob,
             ls_bob_details       TYPE /DBE/s_veh_bob,
             lr_vlcactdata_head    TYPE REF TO vlcactdata_head_s,
             lr_vlcactdata_item    TYPE REF TO vlcactdata_item_s,
             lo_veh_buf            TYPE REF TO /DBE/cl_veh_buf,
             lo_vehicle            TYPE REF TO /DBE/cl_veh_dbmvehicle,
             ls_vlcactdata_head    TYPE  vlcactdata_head_s,
             ls_vlcactdata_item    TYPE  vlcactdata_item_s,
             ls_po_upd_info        TYPE  tty_po_info,
             lr_iobj_single        TYPE REF TO /DBE/iobj_data_single_com_s,
             ls_iobj_single        TYPE  /DBE/iobj_data_single_com_s,
             lr_iobj_multi         TYPE REF TO /dbe/iobj_data_multi_com_s,
             ls_iobj_multi         TYPE  /dbe/iobj_data_multi_com_s.

  lo_veh_buf = /DBE/cl_veh_buf=>get_instance( ).

    CALL METHOD lo_veh_buf->get_all
      RECEIVING
        rt_bob = lt_bob_details.

  CLEAR gt_po_del_info.
  LOOP AT gt_vsresult_selection INTO gs_selection.
    READ TABLE lt_bob_details INTO ls_bob_details WITH KEY guid = gs_selection-vguid.
    IF sy-subrc = 0 .
      lo_vehicle ?= ls_bob_details-bobref.
      TRY.
          lr_vlcactdata_head ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.

      ls_vlcactdata_head = lr_vlcactdata_head->*.
      MOVE-CORRESPONDING ls_vlcactdata_head TO ls_po_del_info.
      ls_po_del_info-po_number = ls_vlcactdata_head-ebeln .
*      ls_po_del_info-currency = ls_vlcactdata_head-currency .
      ls_po_del_info-eindt_changed = ls_vlcactdata_head-eindt .

      TRY.
          lr_vlcactdata_item ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.
      ls_vlcactdata_item = lr_vlcactdata_item->*.
      MOVE ls_vlcactdata_item-vguid TO ls_po_del_info-vguid.
      MOVE ls_vlcactdata_item-vhcle TO ls_po_del_info-vhcle.
      MOVE ls_vlcactdata_item-netpr TO ls_po_del_info-netpr.
      MOVE ls_vlcactdata_item-po_item TO ls_po_del_info-po_item.
      IF ls_vlcactdata_item-eindt_changed IS NOT INITIAL.
        MOVE ls_vlcactdata_item-eindt_changed TO ls_po_del_info-eindt_changed.
      ENDIF.


      IF ls_vlcactdata_item-po_number IS NOT INITIAL.
        MOVE ls_vlcactdata_item-po_number TO ls_po_del_info-po_number.
      ENDIF.
      MOVE ls_vlcactdata_item-po_item TO ls_po_del_info-po_item.
      TRY.
          lr_iobj_single ?=  lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_single_com_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.

      IF lr_iobj_single IS BOUND.
        MOVE-CORRESPONDING  lr_iobj_single->* TO ls_iobj_single.
      ENDIF.
      MOVE ls_iobj_single-/DBE/V_IMODEL-mcodesd TO ls_po_del_info-mcodesd.

      TRY.
          lr_iobj_multi ?=  lo_vehicle->get_data_com( lo_vehicle->gc_iobj_data_multi_com_s ).
          MOVE-CORRESPONDING lr_iobj_multi->* TO ls_iobj_multi.
        CATCH /dbe/cx_veh_layer_not_found .
          CLEAR ls_iobj_multi.
      ENDTRY.

      PERFORM calculate_option_price USING    ls_iobj_multi
                                              ls_po_del_info-currency
                                     CHANGING ls_po_del_info-optpr.

      APPEND ls_po_del_info TO gt_po_del_info.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " PREPARE_PO_DEL_INFO
