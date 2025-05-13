*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF88 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PREPARE_GR_CREATE_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_gr_create_info .

  DATA : lt_bob TYPE /DBE/t_veh_bobget ,
            ls_bob TYPE /DBE/s_veh_bobget ,
            lt_bob_all TYPE /DBE/t_veh_bob,"/DBE/t_veh_bobget,
            ls_bob_all TYPE /DBE/s_veh_bob,
            lt_bob_details TYPE /DBE/t_veh_bob,
            ls_bob_details TYPE /DBE/s_veh_bob,
            lr_vlcactdata_head TYPE REF TO vlcactdata_head_s,
            lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
            lo_veh_buf TYPE REF TO /DBE/cl_veh_buf,
            lo_vehicle TYPE REF TO /DBE/cl_veh_dbmvehicle,
            ls_vlcactdata_head  TYPE  vlcactdata_head_s,
            ls_vlcactdata_item  TYPE  vlcactdata_item_s,
            ls_gr_create  TYPE  ty_gr_create.

  lo_veh_buf = /DBE/cl_veh_buf=>get_instance( ).

  TRY.
    CALL METHOD lo_veh_buf->get_all
      RECEIVING
        rt_bob = lt_bob_details.
  ENDTRY.

  CLEAR gt_gr_create.
  LOOP AT gt_vsresult_selection INTO gs_selection.
    READ TABLE lt_bob_details INTO ls_bob_details WITH KEY guid = gs_selection-vguid.
    IF sy-subrc = 0 .
      lo_vehicle ?= ls_bob_details-bobref.
      TRY.
          lr_vlcactdata_head ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_head_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.

      ls_vlcactdata_head = lr_vlcactdata_head->*.
      MOVE-CORRESPONDING ls_vlcactdata_head TO ls_gr_create.
      ls_gr_create-po_number = ls_vlcactdata_head-ebeln .

      TRY.
          lr_vlcactdata_item ?= lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
        CATCH /DBE/cx_veh_layer_not_found .
      ENDTRY.
      ls_vlcactdata_item = lr_vlcactdata_item->*.
      MOVE ls_vlcactdata_item-vguid TO ls_gr_create-vguid.
      MOVE ls_vlcactdata_item-vhcle TO ls_gr_create-vhcle.
      MOVE ls_vlcactdata_item-werks TO ls_gr_create-werks.
      IF ls_vlcactdata_item-po_number IS NOT INITIAL.
        MOVE ls_vlcactdata_item-po_number TO ls_gr_create-po_number.
      ENDIF.
      MOVE ls_vlcactdata_item-po_item TO ls_gr_create-po_item.
      APPEND ls_gr_create TO gt_gr_create.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " PREPARE_GR_CREATE_INFO
